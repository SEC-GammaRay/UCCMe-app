# frozen_string_literal: true

require_relative 'form_base'

module UCCMe
  module Form
    class NewFolder < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/folder.yml')
      
      params do
        required(:foldername).filled(format?: FOLDERNAME_REGEX, min_size?: 1, max_size?: 50)
        optional(:description).maybe(:string, max_size?: 200)
      end
    end
  end
end
