# frozen_string_literal: true

require_relative '../spec_helper'
require 'webmock/minitest'

describe 'Test Service Objects' do
  before do
    @owners = { username: 'shou', password: 'shouliu' }
    @mal_accounts = { username: 'shou', password: 'wrongpassword' }
    @api_account = { username: 'shou', email: 'shou.liu@gmail.com' }
  end

  after do
    WebMock.reset!
  end

  describe 'Find authenticated account' do
    it 'HAPPY: should find an authenticated account' do
      auth_account_file = 'spec/fixtures/auth_account.json'
      auth_return_json = File.read(auth_account_file)

      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @owners.to_json)
             .to_return(body: auth_return_json,
                        headers: { 'Content-Type' => 'application/json' })

      auth = UCCMe::AuthenticateAccount.new(app.config).call(**@owners)

      account = auth[:account]
      _(account).wont_be_nil
      _(account['username']).must_equal @api_account[:username]
      _(account['email']).must_equal @api_account[:email]
    end

    it 'BAD: should not find a false authenticated account' do
      WebMock.stub_request(:post, "#{API_URL}/auth/authenticate")
             .with(body: @mal_accounts.to_json)
             .to_return(status: 403)
      _(proc {
        UCCMe::AuthenticateAccount.new(app.config).call(**@mal_accounts)
      }).must_raise UCCMe::AuthenticateAccount::UnauthorizedError
    end
  end
end
