class Database

  class ZipFile
    include CommandHelper

    def initialize(filename)
      @filename = filename
    end

    def path
      Pathname.new(`pwd`.chomp).join(::File.dirname(@filename))
    end

    def filename
      ::File.basename(@filename)
    end

    def files
      unarchive.map {|f| Pathname.new(path).join(f) }
    end

    def archive(source_file)
      run("cd '#{path}' && #{find_executable('zip')} #{filename} #{::File.basename(source_file)}")
    end

    def unarchive
      unzip('-Z', '-1', filename).split("\n").tap do |files|
        unzip('-o', filename)
      end
    end

    def unzip(*args)
      run("cd '#{path}' && #{find_executable('unzip')} #{args.join(' ')}").chomp
    end

  end

end
