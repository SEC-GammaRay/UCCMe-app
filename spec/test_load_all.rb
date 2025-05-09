# frozen_string_literal: true

# run pry -r <path_to_this_file>

require_relative '../require_app'
require_app

def app = UCCMe::App

unless app.environment == :production
  require 'rack/test'
  include Rack::Test::Methods # rubocop:disable Style/MixinUsage
end
