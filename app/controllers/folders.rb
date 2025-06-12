# frozen_string_literal: true

require 'roda'
require_relative './app'

module UCCMe
  # Web controller for UCCMe API
  class App < Roda
    route('folders') do |routing|
      routing.on do
        routing.redirect '/auth/login' unless @current_account.logged_in?
        @folders_route = '/folders'

        routing.on(String) do |folder_id|
          @folder_route = "#{@folders_route}/#{folder_id}"

          # GET /folders/[folder_id]
          routing.get do
            folder_info = GetFolder.new(App.config).call(
              @current_account, folder_id
            )

            folder = Folder.new(folder_info)

            view :folder, locals: {
              current_account: @current_account, folder: folder
            }
            # else
            #   routing.redirect '/auth/login'
          rescue StandardError => error
            puts "#{error.inspect}\n#{error.backtrace}"
            flash[:error] = 'Folder not found'
            routing.redirect @folders_route
          end

          # POST /folders/[folder_id]/collaborators
          routing.post('collaborators') do
            action = routing.params['action']
            collaborator_info = Form::CollaboratorEmail.new.call(routing.params)
            if collaborator_info.failure?
              flash[:error] = Form.validation_errors(collaborator_info)
              routing.halt
            end

            task_list = {
              'add' => { service: AddCollaborator,
                         message: 'Added new collaborator to folder' },
              'remove' => { service: RemoveCollaborator,
                            message: 'Removed collaborator from folder' }
            }

            task = task_list[action]
            task[:service].new(App.config).call(
              current_account: @current_account,
              collaborator: collaborator_info,
              folder_id: folder_id
            )
            flash[:notice] = task[:message]
          rescue StandardError
            flash[:error] = 'Could not find collaborator'
          ensure
            routing.redirect @folder_route
          end

          # POST /folders/[folder_id]/files/
          routing.post('files') do
            file_input = routing.params
            orig_ext = File.extname(file_input['file'][:filename])
            file_input['filename'] = "#{file_input['filename']}#{orig_ext}"
            file_input['file'] = file_input['file'][:tempfile]

            file_data = Form::NewFile.new.call(file_input)
            if file_data.failure?
              flash[:error] = Form.validation_errors(file_data)
              routing.halt
            end

            CreateNewFile.new(App.config).call(
              current_account: @current_account,
              folder_id: folder_id,
              file_data: file_data.to_h
            )
            flash[:notice] = 'Your file was added'
          rescue StandardError => error
            puts error.inspect
            puts error.backtrace
            flash[:error] = 'Could not add file'
          ensure
            routing.redirect @folder_route
          end
        end

        # GET /folders/
        routing.get do
          folder_list = GetAllFolders.new(App.config).call(@current_account)
          folders = Folders.new(folder_list)

          view :folders_all, locals: {
            current_account: @current_account, folders: folders
          }
        end

        # POST /folders/
        routing.post do
          routing.redirect '/auth/login' unless @current_account.logged_in?
          puts "FOLDER: #{routing.params}"
          folder_data = Form::NewFolder.new.call(routing.params)
          if folder_data.failure?
            flash[:error] = Form.Form.validation_errors(folder_data)
            routing.halt
          end

          CreateNewFolder.new(App.config).call(
            current_account: @current_account,
            folder_data: folder_data.to_h
          )
          flash[:notice] = 'Add files and collaborators to your new folder'
        rescue StandardError => error
          puts "FAILURE Creating Folder: #{error.inspect}"
          flash[:error] = 'Could not create folder'
        ensure
          routing.redirect @folders_route
        end
      end
    end
  end
end
