Capistrano::Configuration.instance.load do

  set :configuration_template_path, 'config/deploy/config_files'

  after 'deploy:finalize_update', 'deploy:configuration:symlink'
  after 'deploy:update_code',     'deploy:configuration:create'

  namespace :deploy do
    namespace :configuration do
      def remote_file_exists?(path)
        results = []

        invoke_command("if [ -e '#{path}' ]; then echo -n 'true'; fi") do |ch, stream, out|
          results << (out == 'true')
        end

        results.all?
      end

      def find_templates_in(path)
        @found_templates ||= Dir.glob("#{path}/*.erb").inject({}) do |mapping, path|
          mapping.merge!(path => File.basename(path, '.erb'))
        end
      end

      desc "Create configuration files from templates defined in :configuration_template_path directory"
      task :create, :roles => :app do
        find_templates_in(fetch(:configuration_template_path)).each do |template_filename, filename|
          dest_path = "#{shared_path}/config/#{filename}"

          if !remote_file_exists?(dest_path)
            config = ERB.new(File.read(template_filename))

            run "mkdir -p #{shared_path}/config"
            put config.result(binding), dest_path
          else
            logger.debug "File '#{dest_path}' exists on all servers"
          end
        end
      end

      desc "Link created configuration to current release"
      task :symlink, :roles => :app do
        find_templates_in(fetch(:configuration_template_path)).each do |template, filename|
          target  = "#{shared_path}/config/#{filename}"
          symlink = "#{release_path}/config/#{filename}"

          run "ln -nsf '#{target}' '#{symlink}'"
        end
      end
    end
  end

end
