class Database

  class File
    def initialize(filename, &block)
      @filename = filename
    end

    def each_file(&block)
      handler.files.each(&block)
    end

    def handler
      archive? ? ZipFile.new(@filename) : DumpFile.new(@filename)
    end

    def archive?
      @filename.end_with?('.zip')
    end
  end

end
