require 'whenever/capistrano'

set(:whenever_command, 'bundle exec whenever')

set(:whenever_identifier)  { "#{application}_#{stage}" }
set(:whenever_environment) { stage }