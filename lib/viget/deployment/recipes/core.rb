Capistrano::Configuration.instance.load do

  set :user,          'www-data'
  set :scm,           :git
  set :deploy_via,    :remote_cache
  set :use_sudo,      false
  set :default_stage, 'integration'

  set(:rails_env)  { fetch(:stage) }
  set(:repository) { "git@github.com:vigetlabs/#{application}.git" }
  set(:deploy_to)  { "/var/www/#{application}/#{rails_env}" }
  set(:branch)     { fetch(:rails_env) }

  namespace :deploy do
    desc "Deploys code to target environment and runs all migrations"
    task :default do
      deploy.migrations
    end

    desc "Restart passenger with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "touch #{current_path}/tmp/restart.txt"
    end
  end

end