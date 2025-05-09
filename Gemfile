# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# web
# gem 'erb', '~> 4.0', '>= 4.0.4'
gem 'puma'
gem 'rack-session', '>= 2.1.1'
gem 'roda'
gem 'slim'

# configuration
gem 'figaro'
gem 'rake'

# communication
gem 'http'

# security
gem 'rack-ssl-enforcer'
gem 'rbnacl' # assumes libsodium package already installed

# encoding
gem 'base64'

# debugging
gem 'pry'

# development
group :development do
  gem 'rubocop'
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
  gem 'rack', '>= 3.1.14'
  gem 'rack-test'
  gem 'rerun'
end
