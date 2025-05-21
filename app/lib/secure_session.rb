# frozen_string_literal: true

require_relative 'secure_message'

# Encrypt and Decrypt JSON encoded sessions
class SecureSession
  ## Setup Redis URL
  def self.setup(redis_url)
    raise 'REDISCLOUD_URL is not set' if redis_url.nil? || redis_url.empty?

    @redis = Redis.new(url: redis_url)
  end

  ## Class methods to create and retrieve cookie salt
  SESSION_SECRET_BYTES = 64

  # Generate secret for sessions
  def self.generate_secret
    SecureMessage.encoded_random_bytes(SESSION_SECRET_BYTES)
  end

  ## Instance methods to store and retrieve encrypted session data
  def initialize(session)
    @session = session
  end

  def set(key, value)
    @session[key] = SecureMessage.encrypt(value).to_s
  end

  def get(key)
    return nil unless @session && @session[key]

    SecureMessage.new(@session[key]).decrypt
  end

  def delete(key)
    @session.delete(key)
  end

  ## wipe redis session
  def self.wipe_redis_sessions
    raise 'Redis not initialized' unless @redis

    count = @redis.hlen('rack:session')
    @redis.del('rack:session')
    count
  end
end
