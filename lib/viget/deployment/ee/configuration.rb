require 'viget/deployment/shared/configuration'

Capistrano::Configuration.instance.load do

  after 'deploy:configuration:symlink', 'deploy:configuration:symlink_database_config'

  namespace :deploy do
    namespace :configuration do

      task :symlink_database_config, :roles => :app, :except => {:no_release => true} do
        escaped_release = latest_release.to_s.shellescape
        link_path       = "#{escaped_release}/#{ee_system}/expressionengine/config/database.php"

        run "rm -rf -- #{link_path}"
        run "ln -s  -- #{shared_path}/config/database.php #{link_path}"
      end

    end
  end

end