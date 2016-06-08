require 'viget/deployment/cms/core'

Capistrano::Configuration.instance.load do
  set :deployment_type, 'ee'
  set :default_stage,   'staging'
  set :branch,          'master'

  set :ee_system,       'ee-system'

  set :mapped_paths, {
    'system'                              => 'system',
    "#{ee_system}/expressionengine/cache" => 'ee-cache',
    'cache'                               => 'cache',
    'uploads'                             => 'uploads',
    'images/avatars/uploads'              => 'images/avatars/uploads',
    'images/captchas'                     => 'images/captchas',
    'images/member_photos'                => 'images/member_photos',
    'images/pm_attachments'               => 'images/pm_attachments',
    'images/signature_attachments'        => 'images/signature_attachments'
  }

  set :upload_paths,                mapped_paths.values - ['system', 'system/cache', 'cache']
  set :system_paths,                []
  set :configuration_files,         ['config/config.yml', 'config/database.php']

  set(:database_configuration_path) { "#{ee_system}/expressionengine/config/database.php" }

  set(:rake_environment) { "EE_ENV=#{app_env}" }

end
