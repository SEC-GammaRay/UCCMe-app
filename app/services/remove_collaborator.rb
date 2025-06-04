# frozen_string_literal: true

require 'http'

module UCCMe
  # Service to remove collaborators to folder
  class RemoveCollaborator
    class CollaboratorNotRemoved < StandardError; end

    def initialize(config)
      @config = config
    end

    def api_url
      @config.API_URL
    end

    def call(current_account:, collaborator:, folder_id:)
      response = HTTP.auth("Bearer #{current_account.auth_token}")
                     .delete("#{api_url}/folders/#{folder_id}/collaborators",
                             json: { email: collaborator[:email] })

      raise CollaboratorNotRemoved unless response.code == 200
    end
  end
end
