require 'viget/deployment/shared/core'

Capistrano::Configuration.instance.load do

  after 'deploy:setup',         'deploy:protect_shared_directories'
  after 'deploy:finalize_code', 'deploy:set_permissions'

  set :deployment_type, 'ee'
  set :default_stage,   'staging'
  set :branch,          'master'
  set :public_children, []        # No Rails-managed public assets
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

  set :upload_paths, mapped_paths.values - ['system', 'system/cache', 'cache']
  set :shared_children, []

  set(:shared_paths) { fetch(:mapped_paths) }

  set(:app_env)    { fetch(:stage) }
  set(:deploy_to)  { "/var/www/#{application}/#{app_env}" }

  set(:rake_environment) { "EE_ENV=#{app_env}" }

  namespace :deploy do
    desc "Prepares one or more servers for deployment." # copied and modified from core recipe
    task :setup, :except => { :no_release => true } do
      dirs = [deploy_to, releases_path, shared_path]
      dirs += shared_paths.values.map { |d| File.join(shared_path, d) }

      run "#{try_sudo} mkdir -p #{dirs.join(' ')}"
      run "#{try_sudo} chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
    end

    desc "[internal] Touches up the released code." # copied and modified from core recipe
    task :finalize_update, :except => { :no_release => true } do
      escaped_release = latest_release.to_s.shellescape
      commands = []
      commands << "chmod -R -- g+w #{escaped_release}" if fetch(:group_writable, true)

      # mkdir -p is making sure that the directories are there for some SCM's that don't
      # save empty folders
      shared_paths.map do |link, target|
        t = target.shellescape

        commands << "rm -rf   -- #{escaped_release}/#{t}"
        commands << "mkdir -p -- #{escaped_release}/#{target.slice(0..(target.rindex('/'))).shellescape}" if target.rindex('/')
        commands << "ln -s    -- #{shared_path}/#{t} #{escaped_release}/#{link.shellescape}"
      end

      run commands.join(' && ') if commands.any?
    end

    desc "Deploys code to target environment and runs all migrations"
    task :default do
      update_code
      create_symlink
      restart
    end

    desc "Set permissions on shared folders and configuration files"
    task :set_permissions, :roles => :app, :except => {:no_release => true} do
      %(config/config.yml config/database.php).each do |config_file|
        run "chmod 0666 #{shared_path}/#{config_file}"
      end

      shared_paths.values.each do |dir|
        run "chmod -r 0777 #{shared_path}/#{dir}"
      end
    end

    desc "Disallow directory browsing of public directories regardless of Apache / Nginx settings"
    task :protect_shared_directories, :roles => :app, :except => {:no_release => true} do
      shared_paths.values.each do |path|
        put Viget::Deployment.recipes_path.join('assets', 'protected.html').to_s, "#{shared_path}/#{path}/index.html"
      end
    end

    desc "Restart passenger with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
      # NOOP: used as a hook for other tasks
    end

    namespace :db do
      desc "Perform an initial database create & import"
      task :import, :roles => :db, :only => {:primary => true} do
        run_rake_task 'ee:db:initial_import'
      end
    end
  end

end