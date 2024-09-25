require "uri"

url = URI.parse(ENV.fetch("REDIS_URL") { "redis://127.0.0.1:6379/12" })
url.scheme = "rediss"
url.port = Integer(url.port) + 1
$redis = Redis.new(url: url, driver: :ruby, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
