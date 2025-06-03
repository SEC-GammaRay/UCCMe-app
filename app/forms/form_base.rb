# frozen_string_literal: true

require 'dry-validation'

module UCCMe
  # Form helpers
  module Form
    USERNAME_REGEX = /^[a-zA-Z0-9]+([._]?[a-zA-Z0-9]+)*$/
    EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    FOLDERNAME_REGEX = /^[a-zA-Z0-9_\-\s]+$/
    FILENAME_REGEX = /^[a-zA-Z0-9._\-\s]+\.[a-zA-Z0-9]+$/
    PATH_REGEX = %r{^[a-zA-Z0-9._\-/\s]*$}

    def self.validation_errors(validation)
      validation.errors.to_h.map { |k, v| [k, v].join(' ') }.join('; ')
    end

    def self.message_values(validation)
      validation.errors.to_h.values.join('; ')
    end
  end
end
