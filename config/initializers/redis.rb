require "redis"

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/1')

# Optionally expose a global client for direct use ($redis), but don't pass it to cache_store
$redis = Redis.new(url: redis_url)

# Configure Rails.cache using the redis_cache_store adapter and an options hash
Rails.application.config.cache_store = :redis_cache_store, {
  url: redis_url,
  connect_timeout: 30,
  read_timeout: 0.2,
  write_timeout: 0.2,
  error_handler: ->(method:, returning:, exception:) {
    Rails.logger.error("Redis cache error (#{method}): #{exception.class} - #{exception.message}")
  }
}
