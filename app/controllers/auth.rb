# frozen_string_literal: true

require 'roda'
require_relative 'app'

module UCCMe
  # Web controller for UCCMe API
  class App < Roda
    route('auth') do |routing|
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login
        end

        # POST /auth/login
        routing.post do
          account_info = AuthenticateAccount.new(App.config).call(
            username: routing.params['username'],
            password: routing.params['password']
          )

          current_account = Account.new(
            account_info[:account],
            account_info[:auth_token]
          )

          # session[:current_account] = account
          SecureSession.new(session).set(:account, current_account.account_info)
          SecureSession.new(session).set(:auth_token, current_account.auth_token)

          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect '/'
        rescue StandardError => e
          puts "❌ AUTH ERROR: #{e.class} - #{e.message}"
          flash.now[:error] = 'Username or password is incorrect'
          response.status = 400
          view :login
        end
      end

      routing.on 'logout' do
        routing.get do
          # session[:current_account] = nil
          SecureSession.new(session).delete(:current_account)
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.is 'register' do
        routing.get do
          view :register
        end

        routing.post do
          account_data = routing.params.transform_keys(&:to_sym)
          CreateAccount.new(App.config).call(**account_data)

          flash[:notice] = 'Please login with your new account information!'
          routing.redirect @login_route
        rescue StandardError => e
          App.logger.error "ERROR CREATING ACCOUNT: #{e.inspect}"
          App.logger.error e.backtrace
          flash[:error] = 'Could not create account'
          routing.redirect @register_route
        end
      end
    end
  end
end
