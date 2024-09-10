require "uri"
url = URI.parse(ENV["REDIS_URL"])
url.scheme = "rediss"
url.port = Integer(url.port) + 1
$redis = Redis.new(url: url, driver: :ruby, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
