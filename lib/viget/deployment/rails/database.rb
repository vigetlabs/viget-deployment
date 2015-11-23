Capistrano::Configuration.instance.load do

  after 'setup',          'deploy:db:create'
  after 'deploy:migrate', 'deploy:db:seed'

  namespace :deploy do

    namespace :db do
      def rake(task_name, options = {})
        rake_cmd = fetch(:rake, 'rake')

        run "cd #{latest_release} && #{rake_cmd} RAILS_ENV=#{rails_env} #{task_name}"
      end

      task :create, :roles => :db, :only => {:primary => true} do
        rake 'db:create'
      end

      task :seed, :roles => :db, :only => {:primary => true} do
        rake 'db:seed'
      end

    end

  end

end