# frozen_string_literal: true

require 'http'

module UCCMe
  # Service to create a configuration file for a folder
  class CreateNewFile
    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, folder_id:, file_data:)
      config_url = "#{api_url}/folders/#{folder_id}/files"

      file = file_data[:file]
      file_data[:file] = HTTP::FormData::File.new(file)

      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .post(config_url, form: file_data)

      response.code == 201 ? JSON.parse(response.body.to_s) : raise
    end
  end
end
