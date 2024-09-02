# README

This README documents the steps necessary to get the application up and running.

## Ruby version

3.3.4

## Database creation

```bash
bin/rails db:create
```

## Database initialization

```bash
bin/rails db:migrate
```

## How to run the test suite

```bash
bin/rails test
```

### Redis

To start Redis, run:

```bash
bin/start-redis
```

### Sidekiq

To start Sidekiq, run:

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

## Deployment instructions

Provide instructions for deploying the application.

## Running the application

To start the application, use the `bin/dev` script. This script will ensure that `foreman` is installed and then start the application using the `Procfile.dev`.

```bash
bin/dev
```

The `Procfile.dev` defines the following processes:

- `web`: Starts the Rails server with debugging enabled.
- `js`: Watches and builds JavaScript files using `yarn`.
- `css`: Watches and builds CSS files using `yarn`.
- `redis`: Starts the Redis server.
- `worker`: Starts the Sidekiq worker.

## Environment setup

Ensure you have the following environment variables set up:

- `RUBY_DEBUG_OPEN`: Set to `true` to enable debugging.
- Any other environment variables required by your application.
