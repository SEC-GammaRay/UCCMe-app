require 'redis'
require_relative 'secure_message'


class SecureSession 
    def self.setup(redis_url)
        @redis_url = redis_url 
    end 

    SESSION_SECRET_BYTE = 64

    def self.generate_secret
        SecureMessage.encoded_random_bytes(SESSION_SECRET_BYTE)
    end 

    def self.wipe_redis_sessions 
        redis = Redis.new(url: @redis_url)
        redis.keys.each {|session_id| redis.del session_id}
    end 

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
end 

