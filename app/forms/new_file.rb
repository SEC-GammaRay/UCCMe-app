
# frozen_string_literal: true

require_relative 'form_base'

module UCCMe
  module Form
    class NewFile < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_file.yml')
      
      params do
        required(:filename).filled(max_size?: 256, format?: FILENAME_REGEX)
        optional(:relative_path).maybe(format?: PATH_REGEX)
        optional(:description).maybe(:string, max_size?: 500)
        required(:content).filled(:string)
        optional(:folder_id).maybe(:integer)
      end
    end
  end
end
