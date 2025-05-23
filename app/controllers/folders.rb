# frozen_string_literal: true

require 'roda'

module UCCMe
  # Web controller for UCCMe API
  class App < Roda
    route('folders') do |routing|
      routing.on do
        # GET /folders/
        routing.get do
          if @current_account.logged_in?
            folder_list = GetAllFolders.new(App.config).call(@current_account)

            folders = Folders.new(folder_list)

            view :folders_all,
                 locals: { current_account: @current_account, folders: }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
