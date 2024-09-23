require "uri"

if ENV["REDIS_URL"]
  url = URI.parse(ENV["REDIS_URL"])
  url.scheme = "rediss"
  url.port = Integer(url.port) + 1
  $redis = Redis.new(url: url, driver: :ruby, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
else
  # Use a dummy Redis configuration or skip Redis initialization
  puts "REDIS_URL not set. Skipping Redis initialization."
  $redis = nil
end
