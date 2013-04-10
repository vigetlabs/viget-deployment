require 'whenever/capistrano'

set(:whenever_command, './bin/whenever')

set(:whenever_identifier) { "#{application}_#{rails_env}" }