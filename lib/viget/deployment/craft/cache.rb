Capistrano::Configuration.instance.load do

  after 'deploy:finalize_update', 'deploy:cache:templates:clear'

  namespace :deploy do
    namespace :cache do

      desc "Clear all caches"
      task :clear do
        deploy.cache.templates.clear
      end

      namespace :templates do
        desc "Clear the templates cache"
        task :clear, :roles => :app do
          run_rake_task "cache:templates:clear"
        end
      end

    end
  end

end