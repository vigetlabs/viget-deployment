Capistrano::Configuration.instance.load do

  after 'deploy:finalize_update', 'deploy:configuration:symlink'
  after 'deploy:update_code',     'deploy:configuration:create'

  # The local directory in the app that we're deploying to look for configuration files
  # in the format of <filename>.<desired extension>.erb (e.g. `database.yml.erb`)
  set :configuration_template_path, 'config/deploy/config_files'

  namespace :deploy do
    namespace :configuration do

      def ask(prompt, default = nil)
        Capistrano::CLI.ui.ask(prompt) {|q| q.default = default }
      end

      def template_paths
        [
          Viget::Deployment.root_path.join('templates', deployment_type).to_s,
          fetch(:configuration_template_path)
        ]
      end

      def remote_file_exists?(path)
        results = []

        invoke_command("if [ -e '#{path}' ]; then echo -n 'true'; else echo -n 'false'; fi") do |ch, stream, out|
          results << (out == 'true')
        end

        results.all?
      end

      def find_templates_in(*paths)
        pattern = (paths.length > 1) ? "{#{paths.join(',')}}/*.erb" : "#{paths.first}/*.erb"

        @found_templates ||= Dir.glob(pattern).inject({}) do |mapping, path|
          mapping.merge!(File.basename(path, '.erb') => path)
        end
      end

      desc "Create configuration files from templates defined in  directory"
      task :create, :except => {:no_release => true} do
        find_templates_in(*template_paths).each do |filename, template_filename|
          dest_path = "#{shared_path}/config/#{filename}"

          if !remote_file_exists?(dest_path)
            config = ERB.new(File.read(template_filename), nil, '-')

            run "mkdir -p #{shared_path}/config"
            put config.result(binding), dest_path
          else
            logger.debug "File '#{dest_path}' exists on all servers"
          end
        end
      end

      desc "Link created configuration to current release"
      task :symlink, :except => {:no_release => true} do
        find_templates_in(*template_paths).each do |filename, template_filename|
          target  = "#{shared_path}/config/#{filename}"
          symlink = "#{release_path}/config/#{filename}"

          run "ln -nsf '#{target}' '#{symlink}'"
        end
      end
    end
  end

end
