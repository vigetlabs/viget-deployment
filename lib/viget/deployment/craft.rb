require 'viget/deployment/common'

%w(ee shared).each do |path|
  Capistrano::Configuration.instance.load_paths << Viget::Deployment.recipes_path.join(path)
end

Capistrano::Configuration.instance.load 'rbenv'

require 'viget/deployment/craft/core'
require 'viget/deployment/craft/configuration'
require 'viget/deployment/craft/sync'