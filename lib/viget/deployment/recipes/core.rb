Capistrano::Configuration.instance.load do

  set :user,          'www-data'
  set :scm,           :git
  set :deploy_via,    :remote_cache
  set :use_sudo,      false
  set :default_stage, 'integration'

  # Add the default uploads directory for CarrierWave, etc to the list of
  # directories that will get symlinked on setup and deploy
  set :shared_children, %w(public/system log tmp/pids public/uploads)

  set(:rails_env)  { fetch(:stage) }
  set(:repository) { "git@github.com:vigetlabs/#{application}.git" }
  set(:deploy_to)  { "/var/www/#{application}/#{rails_env}" }

  set(:branch) do
    (fetch(:rails_env).to_s == 'integration') ? :master : fetch(:rails_env)
  end

  set :keep_releases, 5

  after "deploy:update_code", "deploy:cleanup"

  namespace :setup do
    task :default do
      deploy.setup
      strategy.deploy!

      deploy.configuration.create
      deploy.configuration.symlink

      bundle.install
    end
  end

  task :offline do
    maintenance.on
  end

  task :online do
    maintenance.off
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
