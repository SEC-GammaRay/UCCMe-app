# frozen_string_literal: true

require 'delegate'
require 'roda'
require 'figaro'
require 'logger'
require 'rack/ssl-enforcer'
require 'rack/session'

require_relative '../require_app'

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
    use Rack::Session::Cookie,
        expire_after: ONE_MONTH,
        secret: config.SESSION_SECRET

    # Console/Pry configuration
    configure :development, :test do
      require 'pry'

      # Allows running reload! in pry to restart entire app
      def self.reload!
        exec 'pry -r ./spec/test_load_all'
      end
    end

    configure :production do
      use Rack::SslEnforcer, hsts: true
    end
  end
end
