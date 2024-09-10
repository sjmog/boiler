# Boiler

A deployment-ready Rails 7 (Ruby 3.3.4) with React, TailwindCSS, and other goodies.

## Development

Add the following to your `.env` file:

```
REDIS_URL="redis://127.0.0.1:6379/12"
```

> Optionally, check the .env.sample file for other environment variables you may want to set.

Set up the database like this:

```bash
bin/rails db:create
bin/rails db:migrate
```

Start the application with `bin/dev`.

`bin/dev` uses `foreman` to start the application using the `Procfile.dev`, with the following processes:

- `web`: the Rails server (with debugging enabled).
- `js`: uses `yarn` to build JavaScript files (such as [React components](./app/javascript/components)). Auto-rebuilds on file changes.
- `css`: Uses yarn to build [CSS files](./app/assets/stylesheets). Auto-rebuilds on file changes.
- `redis`: Starts a Redis server for storing background jobs.
- `sidekiq`: Starts a Sidekiq worker for processing background jobs.

> In production, the `web` process and the `redis` and `sidekiq` processes (for background jobs) live on a `web` server and an `accessory` server, respectively.

You can stop the application with `Ctrl+C`, followed by `bin/stop` to shut down the redis server.

## Testing

Testing is designed to be super-fast.

- **End-to-end tests** run in a headless browser with `bundle exec rspec spec/system`.
- **Unit tests** run with `bundle exec rspec spec`.

## Production

Deployment is handled in two parts: Provisioning and Deployment.

### Provisioning sets up the infrastructure

Run `bin/provision` to prepare the provisioning of the app. You can speed things up by adding the following environment variables:

```bash
HETZNER_API_KEY=your-hetzner-api-key
CLOUDFLARE_API_TOKEN=your-cloudflare-api-token
GITHUB_USERNAME=your-github-username
DOMAIN_NAME=your-domain-name-e.g.-techmap.app
SUBDOMAIN=your-subdomain,-e.g.-boiler
```

> You can run `bin/provision` to add or change infrastructure any time. "It just works™"

Run `bin/teardown` to tear down the infrastructure. This is permanent!

> See the [terraform README](./terraform/README.md) for more.

### Deployment sends your code to production

To get set up for deployment:

1. Get an account on [Docker Hub](https://hub.docker.com/).

Run `kamal deploy` to deploy the app.

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
