require 'yaml'
require 'erb'
require 'pathname'

lib_dir = Pathname.new(File.dirname(__FILE__)).join('..')

require lib_dir.join('command_helper')

require lib_dir.join('database')
require lib_dir.join('database', 'file')
require lib_dir.join('database', 'zip_file')
require lib_dir.join('database', 'dump_file')

require lib_dir.join('tasks', 'configuration')
require lib_dir.join('tasks', 'configuration', 'craft')

include Configuration::Craft

load lib_dir.join('tasks', 'cms.rake')

namespace :cache do
  namespace :templates do
    desc "Clear the generated template caches"
    task :clear do
      print " * Clearing template caches ... "
      FileUtils.rm_rf(Dir['craft/storage/runtime/compiled_templates/*'])
      puts  "done."
    end
  end

  desc "Clear all available caches"
  task :clear => ['templates:clear']
end
