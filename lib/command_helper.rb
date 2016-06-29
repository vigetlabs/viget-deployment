module CommandHelper

  def run(command)
    puts command
    `#{command}`
  end

  def find_executable(name)
    executable = `which #{name}`.chomp

    raise "Could not find executable: '#{name}'" unless $?.success?

    executable
  end

end