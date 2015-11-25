require 'viget/deployment/shared/core'

Capistrano::Configuration.instance.load do
  set :deployment_type, 'rails'
  set :default_stage,   'integration'

  # Add the default uploads directory for CarrierWave, etc to the list of
  # directories that will get symlinked on setup and deploy
  set :shared_children, %w(public/system log tmp/pids public/uploads)

  set(:rails_env)  { fetch(:stage) }
  set(:deploy_to)  { "/var/www/#{application}/#{rails_env}" }

  set(:rake_environment) { "RAILS_ENV=#{rails_env}" }

  set(:branch) do
    (fetch(:rails_env).to_s == 'integration') ? :master : fetch(:rails_env)
  end

  namespace :deploy do
    desc "Deploys code to target environment and runs all migrations"
    task :default do
      set :migrate_target, :latest
      update_code
      migrate
      create_symlink
      restart
    end

    desc "Restart passenger with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end

end
