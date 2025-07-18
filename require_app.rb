# frozen_string_literal: true

# Requires all ruby files in specified app folders
# Params:
# - (opt) folders: Array of root folder names, or String of single folder name
# Usage:
#  require_app
#  require_app('config')
#  require_app(['config', 'models'])
def require_app(folders = %w[lib models services forms controllers], config: true)
  app_list = Array(folders).map { |folder| "app/#{folder}" }
  app_list = ['config', app_list] if config
  full_list = app_list.flatten.join(',')

  Dir.glob("./{#{full_list}}/**/*.rb").each do |file|
    require file
  end
end
