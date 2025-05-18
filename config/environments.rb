# frozen_string_literal: true

require 'delegate'
require 'roda'
require 'figaro'
require 'logger'
require 'rack/session/redis'
# require 'rack/ssl-enforcer'
require 'rack/session'
require_relative '../require_app'
require_relative '../app/lib/secure_session'
require_relative '../app/lib/secure_message'

require_app('lib')

module UCCMe
  # Configuration for the APP
  class App < Roda
    plugin :environments

    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment:,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    # HTTP Request logging
    configure :development, :production do
      plugin :common_logger, $stdout
    end

    # Custom events logging
    LOGGER = Logger.new($stderr)
    def self.logger = LOGGER

    # Sesssion configuration
    ONE_MONTH = 60 * 60 * 24 * 30
    SecureMessage.setup(ENV.delete('MSG_KEY')) 
    SecureSession.setup(ENV.delete('REDISCLOUD_URL'))

    configure :development, :test do 
      # use Rack::Session::Cookie,
      #   expire_after: ONE_MONTH,
      #   secret: config.SESSION_SECRET

      use Rack::Session::Pool,
        expire_after: ONE_MONTH
    end 

    # Console/Pry configuration
    configure :development, :test do
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end

    configure :production do
      # use Rack::SslEnforcer, hsts: true
      use Rack::Session::Redis, 
        redis_server: config.REDISCLOUD_URL, 
        expire_after: ONE_MONTH
    end
  end
end
