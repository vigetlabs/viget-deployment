require 'viget/deployment/shared/configuration'

Capistrano::Configuration.instance.load do

  after 'deploy:configuration:symlink',                 'deploy:configuration:symlink_database_config'
  after 'deploy:configuration:symlink_database_config', 'deploy:configuration:symlink_cachemonster_config'

  namespace :deploy do
    namespace :configuration do

      task :symlink_database_config, :roles => :app, :except => {:no_release => true} do
        escaped_release = latest_release.to_s.shellescape
        link_name       = "#{escaped_release}/#{database_configuration_path}"
        target          = "#{shared_path}/config/#{File.basename(database_configuration_path)}"

        run "rm -rf -- #{link_name}"
        run "ln -s  -- #{target} #{link_name}"
      end

      task :symlink_cachemonster_config, :roles => :app, :except => {:no_release => true} do
        escaped_release = latest_release.to_s.shellescape
        link_name       = "#{escaped_release}/#{cachemonster_configuration_path}"
        target          = "#{shared_path}/config/#{File.basename(cachemonster_configuration_path)}"

        run "rm -rf -- #{link_name}"
        run "ln -s  -- #{target} #{link_name}"
      end

    end
  end

end
