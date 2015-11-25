require 'viget/deployment/common'

%w(ee shared).each do |path|
  Capistrano::Configuration.instance.load_paths << Viget::Deployment.recipes_path.join(path)
end

Capistrano::Configuration.instance.load 'rbenv'

require 'viget/deployment/ee/core'
require 'viget/deployment/ee/configuration'
require 'viget/deployment/ee/sync'
require 'viget/deployment/ee/cache'