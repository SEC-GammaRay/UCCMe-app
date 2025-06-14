# frozen_string_literal: true

require 'roda'
require_relative './app'

module UCCMe
  # Web controller for UCCMe API
  class App < Roda
    route('files') do |routing|
      routing.redirect '/auth/login' unless @current_account.logged_in?

      # GET /files/[file_id]
      routing.get(String) do |file_id|
        file_info = GetFile.new(App.config).call(
          @current_account, file_id
        )
        file = StoredFile.new(file_info)
        view :file, locals: {
          current_account: @current_account, file: file
        }
      rescue StandardError => error
        puts "#{error.inspect}\n#{error.backtrace}"
        flash[:error] = 'File not found'
        routing.redirect routing.referer || '/folders'
      end
    end
  end
end
