require 'viget/deployment/slack_notifier'

Capistrano::Configuration.instance.load do
  after 'deploy:restart', 'deploy:notify:slack'

  namespace :deploy do
    namespace :notify do
      def required_vars
        [:slack_url, :slack_channel]
      end

      def missing_vars
        required_vars.select { |k| fetch(k, nil).nil? }
      end

      desc 'Send deploy notification to Slack'
      task :slack do
        if missing_vars.any?
          logger.important "Missing values for #{missing_vars.inspect}, skipping notification"

          next
        end

        notifier = Viget::Deployment::SlackNotifier.new(
          self,
          slack_url:     fetch(:slack_url),
          slack_channel: fetch(:slack_channel)
        )

        notifier.notify

        logger.important "Deploy notification sent to '#{fetch(:slack_channel)}'"
      end
    end
  end
end
