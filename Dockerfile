# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.4
FROM quay.io/evl.ms/fullstaq-ruby:${RUBY_VERSION}-malloctrim-slim as base

# Rails app lives here
WORKDIR /app

# Set default environment to production, can be overridden at build time
ARG RAILS_ENV=production \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    PATH="/usr/local/node/bin:$PATH"

# Install packages needed for deployment and development
RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libpq5 postgresql-client \
    build-essential libpq-dev libyaml-dev node-gyp pkg-config python-is-python3 gcc make

# Update gems and bundler
RUN gem update --system --no-document && \
    gem install -N bundler -v 2.5.17

# Throw-away build stages to reduce size of final image
FROM base as prebuild

# Install packages needed to build gems and node modules
RUN --mount=type=cache,id=dev-apt-cache,sharing=locked,target=/var/cache/apt \
    --mount=type=cache,id=dev-apt-lib,sharing=locked,target=/var/lib/apt \
    apt-get install --no-install-recommends -y build-essential libpq-dev libyaml-dev node-gyp pkg-config python-is-python3 gcc make


FROM prebuild as node

# Install JavaScript dependencies
ARG NODE_VERSION=20.11.1
ARG YARN_VERSION=1.22.22
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install node modules
COPY --link package.json yarn.lock ./
RUN --mount=type=cache,id=bld-yarn-cache,target=/root/.yarn \
    YARN_CACHE_FOLDER=/root/.yarn yarn install --frozen-lockfile


FROM prebuild as build

# Install application gems
COPY --link Gemfile Gemfile.lock ./
RUN --mount=type=cache,id=bld-gem-cache,sharing=locked,target=/srv/vendor \
    bundle config set without 'development' && \
    bundle config set deployment 'true' && \
    bundle config set app_config .bundle && \
    bundle config set path /srv/vendor && \
    bundle install && \
    bundle exec bootsnap precompile --gemfile && \
    bundle clean && \
    mkdir -p vendor && \
    bundle config set path vendor && \
    cp -ar /srv/vendor .

# Copy node modules
COPY --from=node /app/node_modules /app/node_modules
COPY --from=node /usr/local/node /usr/local/node
ENV PATH=/usr/local/node/bin:$PATH

# Copy application code
COPY --link . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY or REDIS_URL
RUN SECRET_KEY_BASE_DUMMY=1 REDIS_URL=redis://dummy:6379 ./bin/rails assets:precompile;


# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /app /app

# Ensure the bundle executable is available and has correct permissions
RUN chmod +x "${BUNDLE_PATH}/bin/bundle"

# Set the PATH to include the bundle executable
ENV PATH="${BUNDLE_PATH}/bin:${PATH}"

# Run and own only the runtime files as a non-root user for security
ARG UID=1000 \
    GID=1000
RUN groupadd -f -g $GID rails && \
    useradd -u $UID -g $GID rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 80
CMD ["bundle", "exec", "thrust", "./bin/rails", "server"]
