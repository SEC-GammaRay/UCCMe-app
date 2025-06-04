# frozen_string_literal: true

require 'http'

module UCCMe
  # Create a new configuration file for a folder
  class CreateNewFolder
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, folder_data:)
      config_url = "#{api_url}/folders"
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, json: folder_data)

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
