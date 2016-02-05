Capistrano::Configuration.instance.load do
  set :rsync_command, 'rsync'
  set :rsync_options, '--verbose --archive --compress --copy-links --delete --stats'

  namespace :sync do

    desc "Copy content from target environment to local system"
    task :content, :only => {:primary => true} do
      remote_host = capture("echo $CAPISTRANO:HOST$").strip

      fetch(:upload_paths).each do |path|
        src  = "#{shared_path}/#{path}"
        dest = "./#{path}"

        FileUtils.mkdir_p(dest)

        run_locally "#{rsync_command} #{rsync_options} --rsh='ssh' #{user}@#{remote_host}:#{src} #{dest}"
      end
    end

    desc "Copy database from target environment to local system"
    task :db, :roles => :db, :only => {:primary => true} do
      filename = 'data/db_dump.sql'

      run_rake_task "db:export_to_file[#{filename}]"
      download "#{current_path}/#{filename}", filename

      run_rake_task "db:import", :remote => false
    end

  end

end