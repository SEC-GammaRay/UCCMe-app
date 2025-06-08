# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do
  before do
    @credentials = { username: 'sharon', password: 'mypa$$w0rd' }
    @mal_credentials = { username: 'sharon', password: 'wrongpassword' }
    @api_account = { username: 'sharon', email: 'sharon.lin@iss.nthu.edu.tw' }
  end

  after do
    WebMock.reset!
  end

  describe 'Find authenticated account' do
    it 'HAPPY: should find an authenticated account' do
      auth_account_file = 'spec/fixtures/auth_account.json'
      auth_return_json = File.read(auth_account_file)
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @credentials.to_json)
             .to_return(body: auth_return_json,
                        headers: { 'Content-Type' => 'application/json' })

      auth = UCCMe::AuthenticateAccount.new.call(**@credentials)

      account = auth[:account]['attributes']
      _(account).wont_be_nil
      _(account['username']).must_equal @api_account[:username]
      _(account['email']).must_equal @api_account[:email]
    end

    it 'BAD: should not find a false authenticated account' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @mal_credentials.to_json)
             .to_return(status: 401)
      _(proc {
        UCCMe::AuthenticateAccount.new.call(**@mal_credentials)
      }).must_raise UCCMe::AuthenticateAccount::NotAuthenticatedError
    end
  end
end
