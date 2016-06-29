task :create_directories do
  untracked_directories.each do |directory|
    FileUtils.mkdir_p(directory)
    FileUtils.cp(asset_path.join('protected.html'), "#{directory}/index.html")
    FileUtils.chmod_R(0777, directory)
  end

  puts "Created untracked directories"
end

task :setup => ['config:reset', 'db:initial_import', 'create_directories']

namespace :db do
  desc "Create the database specified in the configuration file"
  task :create do |t, args|
    db = Database.new(database_config)
    db.create
  end

  desc "Drop the database specified in the configuration file"
  task :drop do |t, args|
    db = Database.new(database_config)
    db.drop
  end

  desc "Import the database from the specified dumpfile (or default)"
  task :import_from_file, [:file] do |t, args|
    args.with_defaults(:file => 'data/db_dump.zip')

    db = Database.new(database_config)
    db.import_from(args[:file])
  end

  desc "Export the database to the specified dumpfile (or default)"
  task :export_to_file, [:file] do |t, args|
    args.with_defaults(:file => 'data/db_dump.zip')

    db = Database.new(database_config)
    db.export_to(args[:file])
  end

  desc "Backup the database to a timestamped SQL file"
  task :backup, [:file] do |t, args|
    args.with_defaults(:file => Time.now.strftime('data/db_backup_%Y%m%d%H%M.sql'))

    db = Database.new(database_config)
    db.export_to(args[:file])
  end

  task :initial_import => [:create, :import_from_file]
  task :import         => [:backup, :drop, :create, :import_from_file]
  task :export         => [:export_to_file]
end

task :config => ['config:create']

namespace :config do
  desc "Re-create configuration files from scratch"
  task :reset => [:remove, :create]

  desc "Generate necessary #{name} configuration files"
  task :create do
    missing_files = configuration_files.reject {|f| File.exist?(f) }

    if missing_files.empty?
      puts "It seems as if setup has already been run. Exiting."
      exit 1
    end

    puts
    puts "This process will walk through setting up a local install of this #{name} project."
    puts "Please answer a few questions about your local MySQL installation to get started"
    puts

    configuration_file_mapping.each do |template, destination|
      File.open(destination, 'w') do |file|
        file << ERB.new(File.read(root_path.join('templates', slug, template)), nil, '-').result(binding)
      end

      FileUtils.chmod(0666, destination)
    end

    puts
  end

  desc "Remove all generated #{name} configuration files"
  task :remove do
    configuration_files.each {|f| FileUtils.rm_rf(f) }
  end
end
