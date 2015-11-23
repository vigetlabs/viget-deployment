# via: https://exceptiontrap.com/blog/5-run-rails-production-console-with-capistrano

namespace :rails do
  desc "Remote console"
  task :console, roles: :app do
    run_interactively "bundle exec rails console #{fetch(:stage)}"
  end
end

def run_interactively(command, server=nil)
  server ||= find_servers_for_task(current_task).first
  exec %Q(ssh -l #{user} #{server} -t '/bin/bash -l -c "cd #{current_path} && #{command}"')
end
