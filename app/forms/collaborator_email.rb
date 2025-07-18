# frozen_string_literal: true

require_relative 'form_base'

module UCCMe
  module Form
    # Form validation contracts for collaborators' account management
    class CollaboratorEmail < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/account_details.yml')

      params do
        required(:email).filled(format?: EMAIL_REGEX)
        optional(:folder_id).maybe(:integer)
      end
    end
  end
end
