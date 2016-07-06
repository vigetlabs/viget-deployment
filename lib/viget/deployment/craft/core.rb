require 'viget/deployment/cms/core'

Capistrano::Configuration.instance.load do
  set :deployment_type, 'craft'
  set :default_stage,   'staging'
  set :branch,          'master'

  set :mapped_paths, {
    'public/uploads' => 'public/uploads',
    'craft/storage'  => 'craft/storage'
  }

  set :upload_paths,                    ['public/uploads', 'craft/storage/userphotos']
  set :system_paths,                    ['craft/app', 'craft/config', 'craft/storage']
  set :configuration_files,             ['config/config.yml', 'config/db.php']
  set :database_configuration_path,     'craft/config/db.php'
  set :cachemonster_configuration_path, 'craft/config/cachemonster.php'

  set(:rake_environment) { "CRAFT_ENV=#{app_env}" }

end
