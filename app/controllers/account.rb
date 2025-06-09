# frozen_string_literal: true

require 'roda'
require_relative 'app'


module UCCMe
  # Web controller for UCCMe API
  class App < Roda
    route('account') do |routing|
      routing.on String do |username|
        # GET /account/[username]
        routing.get do
          unless @current_account.logged_in?
            flash[:error] = 'You must be logged in to view your requests.'
            routing.redirect '/auth/login'
          end
          
          account = GetAccountDetails.new(App.config).call(
            @current_account, username
          )

          if account.nil?
            response.status = 404
            flash[:error] = 'Account not found'
            routing.redirect(request.referrer || '/')
          end

          view :account, locals: { account: account }
        rescue GetAccountDetails::InvalidAccount => e
          flash[:error] = e.message
          routing.redirect '/auth/login'
        end

        # POST /account/<registration_token>
        routing.post String do |registration_token|
          passwords = Form::Passwords.new.call(routing.params)
          raise Form.message_values(passwords) if passwords.failure?

          new_account = SecureMessage.new(registration_token).decrypt
          CreateAccount.new(App.config).call(
            email: new_account['email'],
            username: new_account['username'],
            password: routing.params['password']
          )
          flash[:notice] = 'Account created! Please login'
          routing.redirect '/auth/login'
        rescue CreateAccount::InvalidAccount => error
          flash[:error] = error.message
          routing.redirect '/auth/register'
        rescue StandardError => error
          flash[:error] = error.message
          routing.redirect(
            "#{App.config.APP_URL}/auth/register/#{registration_token}"
          )
        end
      end
    end
  end
end
