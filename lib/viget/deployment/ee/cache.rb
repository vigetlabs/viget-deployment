Capistrano::Configuration.instance.load do

  namespace :deploy do
    namespace :cache do

      desc "Clear all caches"
      task :clear do
        deploy.cache.stash.clear
        deploy.cache.file.clear
      end

      namespace :stash do
        desc "Clear the remote Stash cache"
        task :clear, :roles => :db, :only => {:primary => true} do
          run_rake_task "ee:cache:stash:clear"
        end
      end

      namespace :file do
        desc "Clear the remote file cache"
        task :clear, :roles => :app do
          run_rake_task "ee:cache:file:clear"
        end
      end

    end
  end

end