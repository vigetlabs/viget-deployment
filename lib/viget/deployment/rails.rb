require 'viget/deployment/common'

recipe_path = File.expand_path(File.dirname(__FILE__) + '/rails')

Capistrano::Configuration.instance.load_paths << recipe_path

require 'viget/deployment/rails/core'
require 'viget/deployment/rails/configuration'
require 'viget/deployment/rails/database'
require 'viget/deployment/rails/slack_notification'
require 'viget/deployment/rails/maintenance'
require 'viget/deployment/rails/assets'
