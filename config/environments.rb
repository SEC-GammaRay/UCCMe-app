# frozen_string_literal: true

require 'delegate'
require 'roda'
require 'figaro'
require 'logger'
require 'rack/session/redis'
require 'rack/ssl-enforcer'
require 'rack/session'
require_relative '../require_app'

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
    @redis_url = ENV.delete('REDISCLOUD_URL')
    SecureMessage.setup(ENV.delete('MSG_KEY'))
    SecureSession.setup(@redis_url)

    configure :development, :test do
      # Suppresses log info/warning outputs in dev/test environments
      logger.level = Logger::ERROR

      # use Rack::Session::Cookie,
      #   expire_after: ONE_MONTH,
      #   secret: config.SESSION_SECRET

      use Rack::Session::Pool,
          expire_after: ONE_MONTH

      # Allows binding.pry to be used in development
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end

    configure :production do
      use Rack::SslEnforcer, hsts: true
      use Rack::Session::Redis,
          redis_server: @redis_url,
          expire_after: ONE_MONTH
    end
  end
end
