Capistrano::Configuration.instance.load do

  set :user,          'www-data'
  set :scm,           :git
  set :deploy_via,    :remote_cache
  set :use_sudo,      false

  # Forward current user's keys to deployment server for Github checkouts
  set :ssh_options, {:forward_agent => true}

  set(:repository) { "git@github.com:vigetlabs/#{application}.git" }

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

end