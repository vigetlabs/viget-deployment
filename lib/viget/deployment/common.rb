module Viget
  module Deployment
    def self.root_path
      Pathname.new(File.expand_path(File.dirname(__FILE__))).join('..', '..', '..')
    end

    def self.recipes_path
      root_path.join('lib', 'viget', 'deployment')
    end
  end
end

def run_rake_task(command, options = {})
  options[:remote] = true unless options.has_key?(:remote)

  if options[:remote]
    escaped_release = latest_release.to_s.shellescape
    run "cd #{escaped_release} && #{fetch(:rake_environment)} #{fetch(:rake)} #{command}"
  else
    system "bundle exec rake #{command}"
  end
end

require 'capistrano/ext/multistage'
require 'bundler/capistrano'

require 'viget/deployment/shared/slack_notification'
require 'viget/deployment/shared/maintenance'
