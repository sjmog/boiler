require "sidekiq"
require "sidekiq-status"
require "honeybadger"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], network_timeout: 5, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  config.error_handlers << proc { |exception, ctx_hash, config| Honeybadger.notify(exception, ctx_hash) } if Rails.env.production?
  Sidekiq::Status.configure_server_middleware config, expiration: 30.minutes.to_i
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes.to_i
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"], network_timeout: 5, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes.to_i
end
