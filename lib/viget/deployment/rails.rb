require 'viget/deployment/common'

%w(rails shared).each do |path|
  Capistrano::Configuration.instance.load_paths << Viget::Deployment.recipes_path.join(path)
end

Capistrano::Configuration.instance.load 'rbenv'

require 'viget/deployment/rails/core'
require 'viget/deployment/shared/configuration'
require 'viget/deployment/rails/database'
require 'viget/deployment/rails/assets'
