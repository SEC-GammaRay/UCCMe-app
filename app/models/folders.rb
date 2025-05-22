# frozen_string_literal: true

require_relative 'folder'

module UCCMe
  # Behavior of the currently logged in account
  class Folders
    attr_reader :all

    def initialize(folders_list)
      @all = folders_list.map do |folder|
        Folder.new(folder)
      end
    end
  end
end
