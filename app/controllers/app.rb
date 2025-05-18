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

    ONE_MONTH = 30*24*60*60    
    use Rack::Session::Cookie,
      expire_after: ONE_MONTH, 
      secret: config.SESSION_SECRET

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      @current_account = SecureSession.new(session).get(:current_account)

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
