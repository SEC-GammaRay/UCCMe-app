# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# web
# gem 'erb', '~> 4.0', '>= 4.0.4'
gem 'puma'
gem 'rack-session'
gem 'roda'
gem 'slim'

# configuration
gem 'figaro'

# encoding
gem 'base64'

# debugging
gem 'pry'

# communication
gem 'http'

# security
gem 'rbnacl' # assumes libsodium package already installed

# development
group :development do
  gem 'rake'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-rake', '~> 0.7.1'
end

group :development, :test do
  gem 'rack-test'
  gem 'rerun'
end
