# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# web
# gem 'erb', '~> 4.0', '>= 4.0.4'
gem 'logger'
gem 'puma'
gem 'rack-session', '>= 2.1.1'
gem 'redis-rack'
gem 'redis-store'
gem 'roda'
gem 'slim'

# configuration
gem 'figaro'
gem 'rake'

# communication
gem 'http'
gem 'redis'

# security
gem 'dry-validation', '~>1.10'
gem 'rack-ssl-enforcer'
gem 'rbnacl' # assumes libsodium package already installed
gem 'secure_headers'

# encoding
gem 'base64'
gem 'json'

# debugging
gem 'pry'

# development
group :development do
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-performance'
  gem 'rubocop-rake', '~> 0.7.1'
end

# testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
  gem 'webmock'
end

group :development, :test do
  gem 'rack', '>= 3.1.16'
  gem 'rack-test'
  gem 'rerun'
end
