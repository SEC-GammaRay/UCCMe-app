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
          credentials = Form::LoginCredentials.new.call(routing.params)
          if credentials.failure?
            flash[:error] = 'Please enter both username and password'
            routing.redirect @login_route
          end

          authenticated = AuthenticateAccount.new(App.config)
                                             .call(**credentials.values)
          #   username: routing.params['username'],
          #   password: routing.params['password']
          # )

          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account
          # session[:current_account] = account
          # SecureSession.new(session).set(:account, current_account.account_info)
          # SecureSession.new(session).set(:auth_token, current_account.auth_token)

          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect '/'
        rescue AuthenticateAccount::UnauthorizedError
          flash.now[:error] = 'Username and password did not match our records'
          response.status = 401
          view :login
        rescue AuthenticateAccount::ApiServerError => e
          App.logger.warn "API server error: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
        # rescue StandardError => e
        #   puts "❌ AUTH ERROR: #{e.class} - #{e.message}"
        #   flash.now[:error] = 'Username or password is incorrect'
        #   response.status = 400
        #   view :login
        # end
      end

      routing.on '/auth/logout' do
        routing.is 'logout' do
          # session[:current_account] = nil
          # SecureSession.new(session).delete(:current_account)
          CurrentSession.new(session).delete
          flash[:notice] = "You've been logged out"
          routing.redirect @login_route
        end
      end

      @register_route = '/auth/register'
      routing.on 'register' do
        routing.is do
          # GET /auth/register
          routing.get do
            view :register
          end

          # POST /auth/register
          routing.post do
            registration = Form::Registration.new.call(routing.params)
            if registration.failure?
              flash[:error] = Form.validation_errors(registration)
              routing.redirect @register_route
            end

            VerifyRegistration.new(App.config).call(registration)

            flash[:notice] = 'Please check your email to confirm your account'
            routing.redirect '/'
          rescue VerifyRegistration::ApiServerError => e
            App.logger.warn "API server error: #{e.inspect}\n #{e.backtrace}"
            flash[:error] = 'Our server is currently unavailable. Please try again later.'
            routing.redirect @register_route
          rescue StandardError => e
            App.logger.error "Could not process registration: #{e.inspect}"
            flash[:error] = 'Registration failed. Please try again.'
            routing.redirect @register_route
          end
        end

        # GET /auth/register/<token>
        routing.get(String) do |registration_token|
          flash.now[:notice] = 'Email Verified! Please enter password.'
          new_account = SecureMessage.new(registration_token).decrypt
          view :register_confirm,
               locals: { new_account:,
                         registration_token: }
        end
      end
    end
  end
end
