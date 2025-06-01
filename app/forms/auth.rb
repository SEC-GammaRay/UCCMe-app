# frozen_string_literal: true

require_relative 'form_base'

module UCCMe
  module Form
    class LoginCredentials < Dry::Validation::Contract
      params do
        required(:username).filled
        required(:password).filled
      end
    end

    class Registration < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/account_details.yml')
      
      params do
        required(:username).filled(format?: USERNAME_REGEX, min_size?: 3)
        required(:email).filled(format?: EMAIL_REGEX)
      end
    end

    class Passwords < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/password.yml')
      
      params do
        required(:password).filled(min_size?: 8)
        required(:password_confirm).filled
      end

      rule(:password, :password_confirm) do
        unless values[:password].eql?(values[:password_confirm])
          key.failure('Passwords do not match')
        end
      end
    end
  end
end
