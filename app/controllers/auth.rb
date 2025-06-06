# frozen_string_literal: true

require 'roda'
require_relative 'app'

# rubocop:disable Metrics/ClassLength
module UCCMe
  # Web controller for UCCMe API
  class App < Roda
    def google_oauth_url(config)
      url = config.GOOGLE_OAUTH_URL
      client_id = config.GOOGLE_CLIENT_ID
      scope = config.GOOGLE_SCOPE
      redirect_uri = config.GOOGLE_REDIRECT_URI

      params = {
        client_id: client_id,
        redirect_uri: redirect_uri,
        scope: scope,
        response_type: 'code',
        access_type: 'offline',  
        prompt: 'consent'        
      }
      query_string = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
      
      "#{url}?#{query_string}"
    end 
  
    route('auth') do |routing|
      @oauth_callback = 'auth/sso_callback'
      @login_route = '/auth/login'
      routing.is 'login' do
        # GET /auth/login
        routing.get do
          view :login, locals: {
            google_oauth_url: google_oauth_url(App.config)
          }
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

          current_account = Account.new(
            authenticated[:account],
            authenticated[:auth_token]
          )

          CurrentSession.new(session).current_account = current_account

          flash[:notice] = "Welcome back #{current_account.username}!"
          routing.redirect '/folders'
        rescue AuthenticateAccount::UnauthorizedError
          flash.now[:error] = 'Username and password did not match our records'
          response.status = 401
          view :login
        rescue AuthenticateAccount::ApiServerError => error
          App.logger.warn "API server error: #{error.inspect}\n#{error.backtrace}"
          flash[:error] = 'Our servers are not responding -- please try later'
          response.status = 500
          routing.redirect @login_route
        end
      end
    end

      @oauth_callback = '/auth/sso_callback'
      routing.is 'sso_callback' do
        # GET /auth/sso_callback
          routing.get do
          authorized = AuthorizeGoogleAccount
                       .new(App.config)
                       .call(routing.params['code'])

          puts "Authorized data: #{authorized.inspect}"
          puts "About to create Account with: #{authorized[:account].inspect}, #{authorized[:auth_token].inspect}"

          current_account = Account.new(
            authorized[:account],
            authorized[:auth_token]
          )

        CurrentSession.new(session).current_account = current_account
        flash[:notice] = "Welcome #{current_account.username}!"
        routing.redirect '/'
      rescue AuthorizeGoogleAccount::UnauthorizedError
        flash[:error] = 'Could not login with Google'
        response.status = 403
        routing.redirect @login_route
      rescue StandardError
        flash[:error] = 'Our servers are not responding -- please try later'
        response.status = 500
        routing.redirect @login_route
      end
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
        rescue AuthorizeGoogleAccount::UnauthorizedError
          flash[:error] = 'Could not login with Google'
          response.status = 403
          routing.redirect @login_route
        rescue StandardError => e
          puts "SSO LOGIN ERROR: #{e.inspect}\n#{e.backtrace}"
          flash[:error] = 'Unexpected API Error'
          response.status = 500
          routing.redirect @login_route
        end
      end


      @logout_route = '/auth/logout'
      routing.is 'logout' do
        routing.get do
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
          rescue VerifyRegistration::ApiServerError => error
            App.logger.warn "API server error: #{error.inspect}\n #{error.backtrace}"
            flash[:error] = 'Our server is currently unavailable. Please try again later.'
            routing.redirect @register_route
          rescue StandardError => error
            App.logger.error "Could not process registration: #{error.inspect}"
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
# rubocop:enable Metrics/ClassLength
