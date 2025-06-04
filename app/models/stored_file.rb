# frozen_string_literal: true

require_relative 'folder'

module UCCMe
  # Behaviors of the currently logged in account
  class StoredFile
    attr_reader :id, :filename, :description, :content, :cc_types, # basic info
                :folder # full details

    def initialize(info)
      process_attributes(info['attributes'])
      process_included(info['include'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @filename = attributes['filename']
      @description = attributes['description']
      @content = attributes['content']
      @cc_types = attributes['cc_types']
    end

    def process_included(included)
      @folder = Folder.new(included['folder']) if included && included['folder']
    end
  end
end
