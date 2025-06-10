# frozen_string_literal: true

require_relative 'form_base'

module UCCMe
  module Form
    # Form validation contracts for file management
    class NewFile < Dry::Validation::Contract
      config.messages.load_paths << File.join(__dir__, 'errors/new_file.yml')

      params do
        required(:filename).filled(max_size?: 256, format?: FILENAME_REGEX)
        optional(:description).maybe(:string, max_size?: 500)
        required(:cc_type).filled(:string, included_in?: ['CC BY-NC-ND', 'CC BY-NC-SA'])
        required(:file)
      end

      rule(:file) do
        key.failure('must be a valid uploaded file') unless value.respond_to?(:read)
      end
    end
  end
end
