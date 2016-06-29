class Database
  include CommandHelper

  RECOGNIZED_OPTIONS = %w(user host port socket)

  def initialize(options = {})
    @options = options
  end

  def export_to(filename)
    DumpFile.new(filename).dump do |path|
      run "#{inline_password}#{find_executable('mysqldump')} #{command_flags} #{database} > #{path}"
    end
  end

  def import_from(filename)
    File.new(filename).each_file do |file|
      run "#{inline_password}#{find_executable('mysql')} #{command_flags} #{database} < #{file}"
    end
  end

  def drop
    run "#{inline_password}#{find_executable('mysqladmin')} #{command_flags} -f drop #{database}"
  end

  def create
    execute "CREATE DATABASE IF NOT EXISTS `#{database}`"
  end

  def db_execute(command)
    execute command, database
  end

  private

  def execute(command, database = nil)
    full_command = (database.nil?) ? command : "USE `#{database}`; #{command}"

    run "#{inline_password}#{find_executable('mysql')} #{command_flags} -e '#{full_command}'"
  end

  def database
    @options['database'] || raise("Missing value for `database` in options")
  end

  def inline_password
    @options['password'] ? "MYSQL_PWD='#{@options['password']}' " : ''
  end

  def command_flags
    flags.join(' ')
  end

  def flags
    @flags ||= basic_flags.tap do |flags|
      flags << "--protocol=TCP" if @options['port']
    end
  end

  def basic_flags
    RECOGNIZED_OPTIONS.inject([]) do |pairings, option|
      pairings << "--#{option}=#{@options[option]}" if @options[option]
      pairings
    end
  end

end