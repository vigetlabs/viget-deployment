require 'bundler/capistrano'
require 'capistrano/ext/multistage'

recipe_path = File.expand_path(File.dirname(__FILE__) + '/recipes')

Capistrano::Configuration.instance.load_paths << recipe_path