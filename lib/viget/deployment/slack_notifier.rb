require 'net/http'
require 'uri'
require 'json'

module Viget
  module Deployment
    class SlackNotifier
      attr_reader :cap, :slack_url, :slack_channel

      def initialize(cap, slack_url, slack_channel)
        @cap           = cap
        @slack_channel = slack_channel
        @slack_url     = slack_url
      end

      def notify
        post(payload)
      end

      def payload
        {
          channel:    slack_channel,
          username:   slack_username,
          icon_emoji: slack_emoji,
          attachments: [{
            fallback:   fallback,
            title:      current_revision,
            text:       commit_message,
            title_link: commit_url,
            color:      color,
            fields: [
              deployed_by_field,
              branch_field,
              visit_site_field
            ].compact
          }]
        }
      end


      private

      def deployed_by_field
        {
          title: 'Deployed By',
          value: user,
          short: true
        }
      end

      def branch_field
        {
          title: 'Branch',
          value: "<#{branch_url}|#{branch}>",
          short: true
        }
      end

      def visit_site_field
        if slack_app_url
          {
            title: 'URL',
            value: "<#{slack_app_url}>",
            short: false
          }
        end
      end

      def slack_uri
        URI.parse(slack_url)
      end

      def slack_username
        cap.fetch(:slack_username, "#{environment} Deploy")
      end

      def slack_emoji
        cap.fetch(:slack_emoji, ':bell:')
      end

      def slack_app_url
        cap.fetch(:slack_app_url, nil)
      end

      def color
        case environment
        when 'Integration'
          '#d16d4e'
        when 'Staging'
          '#7c82d1'
        else
          '#23d15a'
        end
      end

      def fallback
        "#{current_revision}: #{commit_message}"
      end

      def environment
        cap.fetch(:stage).to_s.capitalize
      end

      def git_username
        username = cap.run_locally('git config --get user.name')

        username unless username.nil? or username == ''
      end

      def user
        git_username || ENV['USER']
      end

      def github_url
        repository_url = cap.fetch(:repository)
        path           = repository_url.gsub(%r{(^git@github\.com:?|\.git$)}, '')

        "https://github.com/#{path}"
      end

      def branch_url
        branch = cap.fetch(:branch).to_s.split('/').last

        "#{github_url}/commits/#{branch}"
      end

      def commit_url
        "#{github_url}/commit/#{current_revision}"
      end

      def commit_message
        @commit_message ||= cap.capture(%{cd #{cap.current_path}; git show --pretty=format:"%s - %an" HEAD | head -n 1}).strip
      end

      def current_revision
        cap.current_revision
      end

      def branch
        cap.fetch(:branch)
      end

      def post(payload)
        http = Net::HTTP.new(slack_uri.host, slack_uri.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(slack_uri.request_uri)
        request.set_form_data(payload: JSON.generate(payload))

        http.request(request)
      end
    end
  end
end
