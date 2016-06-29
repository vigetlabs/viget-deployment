class Database

  class DumpFile
    def initialize(filename)
      @filename = filename
    end

    def replace_extension(filename, extension)
      filename.sub(/\.\w+/, ".#{extension}")
    end

    def archive_filename
      replace_extension(@filename, 'zip')
    end

    def export_filename
      replace_extension(@filename, 'sql')
    end

    def files
      [export_filename]
    end

    def dump(&block)
      yield export_filename
      archive if archive?
    end

    def archive?
      @filename.end_with?('.zip')
    end

    def archive
      ZipFile.new(archive_filename).archive(export_filename)
    end
  end

end
