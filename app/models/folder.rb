# frozen_string_literal: true

module UCCMe
  # Behavior of the currently logged in account
  class Folder
    attr_reader :id, :foldername, :description

    def initialize(folder_info)
      @id = folder_info['attributes']['id']
      @foldername = folder_info['attributes']['foldername']
      @description = folder_info['attributes']['description']
    end
  end
end
