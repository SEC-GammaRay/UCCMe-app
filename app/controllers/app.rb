# frozen_string_literal: true

require 'roda'
require 'erb'

module UCCMe
  # Base class for UCCMe Web Application
  class App < Roda
    plugin :flash
    plugin :multi_route
    plugin :render, engine: 'slim', views: 'app/presentation/views'
    plugin :public, root: 'app/presentation/public'
    plugin :assets, path: 'app/presentation/assets',
                    css: 'style.css', timestamp_paths: true

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      @current_account = session[:current_account]

      routing.public
      routing.assets
      routing.multi_route

      # GET /
      routing.root do
        view 'home', locals: { current_account: @current_account }
      end
    end
  end
end
