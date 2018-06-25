after 'deploy:restart', 'git:push_deploy_tag'

namespace :git do
  task :push_deploy_tag do
    user  = `git config --get user.name`.chomp
    email = `git config --get user.email`.chomp

    puts `git tag #{stage}-#{release_name} #{current_revision} -m "Deployed by #{user} <#{email}>"`
    puts `git push --tags origin`
  end
end
