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
require lib_dir.join('tasks', 'configuration', 'expression_engine')

include Configuration::ExpressionEngine

load lib_dir.join('tasks', 'cms.rake')

namespace :cache do
  namespace :stash do
    desc "Clear the Stash add-on caches"
    task :clear do
      db = Database.new(database_config)
      db.db_execute('TRUNCATE TABLE `exp_stash`')
      puts "Cleared stash cache"
    end
  end

  namespace :file do
    desc "Clear the EE filesystem caches"
    task :clear do
      file_caches = [
        "#{system_dir}/expressionengine/cache/db_cache",
        "static"
      ]

      file_caches.each do |cache_path|
        puts " * Wiping cache directory: #{cache_path}"
        FileUtils.rm_rf(Dir["#{cache_path}/*"])
      end
      puts "Cleared file cache"
    end
  end

  desc "Clear all available caches"
  task :clear => ['stash:clear', 'file:clear']
end

