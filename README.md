# Boiler

A deployment-ready Rails 7 (Ruby 3.3.4) backend with React, TailwindCSS, and other goodies.

## Development

1. Copy the .env.sample file to a new .env and set any required environment variables.
2. `bundle install`.
3. `bin/rails db:setup`.

Now start the application with `bin/dev`, and stop it with `Ctrl+C` followed by `bin/stop`.

> You can also run the application using `docker-compose up` to mimic production.

### How development works

`bin/dev` uses `foreman` to start the application using the `Procfile.bindev`, with the following processes:

- `web`: the Rails server (with debugging enabled).
- `js`: uses `yarn` to build JavaScript files (such as [React components](./app/javascript/components)). Auto-rebuilds on file changes.
- `css`: Uses yarn to build [CSS files](./app/assets/stylesheets). Auto-rebuilds on file changes.
- `redis`: Starts a Redis server for storing background jobs.
- `sidekiq`: Starts a Sidekiq worker for processing background jobs.

> In production, the `web` process and the `redis` and `sidekiq` processes (for background jobs) live on a `web` server and an `accessory` server, respectively.

## Testing

Testing is designed to be super-fast and parallelised using [`parallel_tests`](https://github.com/grosser/parallel_tests).

- **End-to-end/system tests** run in a headless browser with `bin/test spec/system`.
- **Unit tests** run with `bin/test spec/<unit-you-want-to-test>_spec.rb`.

Other testing things:

- **Fixtures** are managed using FactoryBot, and you can find them in the `/factories` directory.

## Deployment

Deployment is handled automatically when you merge using git. Boiler apps have both `staging` and `main` branches, which correspond to the environment that is provisioned for each.

1. When you create a Pull Request from any branch to `staging`, a preview environment is provisioned, deployed to, and tested.
2. When you merge to `staging`, a staging environment is (re-)provisioned, and deployed to.
3. When you merge to `main`, a production environment is (re-)provisioned, and deployed to.

To enable this delicious workflow, you need to:

1. Add a [`HETZNER_API_KEY` for a Hetzner Cloud project](https://www.hetzner.com/cloud), [`CLOUDFLARE_API_TOKEN` with read and modify zone permissions](https://dash.cloudflare.com/sign-up/free-trial?utm_source=boiler), [Docker Hub `REGISTRY_PASSWORD`](https://hub.docker.com/) and `GITHUB_USERNAME` to [.env](.env).
2. If you want, update the required infrastructure in [infrastructure.yml](infrastructure.yml).

You're good to go!

> As a fallback, run `bin/teardown` to tear down all provisioned infrastructure. This is permanent!

### Deployment workflows in detail

Here's each of the deployment stages in more detail:

### PREVIEW WORKFLOW

The preview workflow is triggered by a Pull Request from `your-branch` to `staging`. It uses a [Github Action](./.github/workflows/ci.yml) to:

- Provision a new minimum setup of infrastructure as defined in `infrastructure.yml` (by default that's two servers (one `web` for Rails and Sidekiq, another `accessories` for Redis and Postgres), a load balancer, a firewall, and a Cloudflare subdomain.)
- Rebuild the Docker images and push them to Docker Hub with the tag `your-app:preview-<branch-number>`.
- Deploy the app to this preview environment using Kamal.
- Run the tests and report the results in the Pull Request.

> You can visit your preview environment at `https://preview-<branch-number>.yourdomain.com`.

### STAGING_WORKFLOW

The staging workflow is triggered by merging your preview Pull Request into `staging`. It uses a Github Action to:

- Ensure staging environment infrastructure exists as defined in `infrastructure.yml`.
- Rebuild the Docker images and push them to Docker Hub with the tag `your-app:staging-<branch-number>`.
- Deploy the app to this staging environment using Kamal.

> You can visit your staging environment at `https://staging.yourdomain.com`.

### PRODUCTION_WORKFLOW

The production workflow is triggered by merging `staging` into `main`. It uses a Github Action to:

- Ensures production environment infrastructure exists as defined in `infrastructure.yml`.
- Rebuilds the Docker images and pushes them to Docker Hub with the tag `your-app:latest`.
- Deploys the app to this production environment using Kamal.

# Things you might want to do

### Set up Google OAuth2 login

1. Get an account on [Google Cloud](https://console.cloud.google.com/).
2. Create a new project.
3. Create new OAuth client ID and secret for your project.
  i. For the authorised JavaScript origins, add `https://localhost:3000` and your production URL.
  ii. For the authorised redirect URIs, add `https://localhost:3000/users/auth/google_oauth2/callback` and `https://<your-domain>/users/auth/google_oauth2/callback`.
4. Set the following environment variables:

```bash
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret
```

Google login will appear automatically in the combined login/signup page.

> For other OAuth2 providers, set the environment variables as in [the register or sign in view](./app/views/devise/registrations/new_or_sign_in.html.erb).

### Create an admin user

Use `rails c` to create an admin user:

```ruby
User.create!(email: "admin@example.com", password: "password", admin: true)
```

### Schedule a recurring job (cron job)

Boiler uses [sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron) to run cron jobs. cron jobs are defined in `config/schedule.yml`. sidekiq-cron is smart enough to only schedule jobs if they are not already scheduled (even across multiple instances of sidekiq).

### See database analytics

Boiler uses [pghero](https://github.com/ankane/pghero) for database analytics. To access the pghero interface, go to `/pghero` (e.g. `https://techmap.app/pghero`). You need to be an admin user to access this page.

# Useful things to know

### It's all SSL

Boiler's puma webserver is designed to be run with SSL (even locally). If you need to regenerate an SSL certificate for local development, you can do it like this: `openssl req -x509 -sha256 -nodes -newkey rsa:2048 -days 365 -keyout config/development-ssl/localhost.key -out config/development-ssl/localhost.crt`.

### Postgres for the database

Postgres is used for the database. You can connect to the database using the `psql` command-line tool. For example: `psql -d boiler_development`.

### Redis and Sidekiq for background jobs

Redis and Sidekiq are used for background jobs. Redis is used for job queuing, and Sidekiq is used to run jobs.

By default, Sidekiq runs on `localhost:6379` and Redis runs on `localhost:6379/12`.
