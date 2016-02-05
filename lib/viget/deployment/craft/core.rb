require 'viget/deployment/cms/core'

Capistrano::Configuration.instance.load do

  after 'deploy:setup',           'deploy:protect_shared_directories'
  after 'deploy:finalize_update', 'deploy:set_permissions'

  set :deployment_type, 'craft'
  set :default_stage,   'staging'
  set :branch,          'master'

  set :mapped_paths, {
    'public/uploads' => 'public/uploads',
    'craft/storage'  => 'craft/storage'
  }

  set :upload_paths,                ['public/uploads', 'craft/storage/userphotos']
  set :configuration_files,         ['config/config.yml', 'config/db.php']
  set :database_configuration_path, 'craft/config/db.php'

  set(:rake_environment) { "CRAFT_ENV=#{app_env}" }

end
