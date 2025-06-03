# frozen_string_literal: true

require 'ostruct'

module UCCMe
  # Behavior of the currently logged in account
  class Folder
    attr_reader :id, :foldername, :description, # basic info
                :owner, :collaborators, :stored_files, :policies # full details

    def initialize(folder_info)
      process_attributes(folder_info['attributes'])
      process_relationships(folder_info['relationships'])
      process_policies(folder_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @foldername = attributes['foldername']
      @description = attributes['description']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner'])
      @collaborators = process_collaborators(relationships['collaborators'])
      @stored_files = process_files(relationships['stored_files'])
    end

    # rubocop:disable Style/OpenStructUse
    def process_policies(policies)
      @policies = OpenStruct.new(policies)
    end
    # rubocop:enable Style/OpenStructUse

    def process_files(files_info)
      return nil unless files_info

      files_info.map { |file_info| StoredFile.new(file_info) }
    end

    def process_collaborators(collaborators)
      return nil unless collaborators

      collaborators.map { |account_info| Account.new(account_info) }
    end
  end
end
