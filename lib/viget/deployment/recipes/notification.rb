require 'viget/deployment/notifier'

Capistrano::Configuration.instance.load do

  set :campfire_subdomain, 'vl'
  set :campfire_use_ssl,   true

  set(:github_base_url) do
    repository_url = fetch(:repository)
    path           = repository_url.gsub(%r{(^git@github\.com:?|\.git$)}, '')

    "https://github.com/#{path}"
  end

  after 'deploy:restart', 'deploy:notify'

  namespace :deploy do

    desc "[internal] Notify one or more campfire rooms on deployment"
    task :notify do
      notifier = Viget::Deployment::Notifier.new(
        fetch(:campfire_subdomain),
        fetch(:campfire_room_names),
        fetch(:campfire_token),
        fetch(:campfire_use_ssl),
        fetch(:github_base_url)
      )

      commit_message = capture("cd #{current_path}; git show --pretty=format:%s HEAD | head -n 1").strip
      notifier.announce(ENV['USER'], current_revision, commit_message, fetch(:application), fetch(:branch), fetch(:stage))
    end

  end
end