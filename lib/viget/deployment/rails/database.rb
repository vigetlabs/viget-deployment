Capistrano::Configuration.instance.load do

  after 'setup',          'deploy:db:create'
  after 'deploy:migrate', 'deploy:db:seed'

  namespace :deploy do

    namespace :db do
      task :create, :roles => :db, :only => {:primary => true} do
        run_rake_task 'db:create'
      end

      task :seed, :roles => :db, :only => {:primary => true} do
        run_rake_task 'db:seed'
      end

    end

  end

end