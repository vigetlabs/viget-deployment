module Configuration
  module ExpressionEngine
    include Configuration

    def slug
      'ee'
    end

    def name
      'ExpressionEngine'
    end

    def system_dir
      paths = Dir.glob("#{Dir.pwd}/**/expressionengine")
      raise "Could not locate EE system path" unless paths.length == 1

      Pathname.new(paths.first).join('..').basename
    end

    def ee_system
      system_dir
    end

    def configuration_file_mapping
      {
        'config.yml.erb'   => 'config/config.yml',
        'database.php.erb' => "#{system_dir}/expressionengine/config/database.php"
      }
    end

    def untracked_directories
      [
        "images/uploads",
        "images/captchas",
        "images/member_photos",
        "images/pm_attachments",
        "images/signature_attachments",
        "images/avatars/uploads",
        "#{system_dir}/expressionengine/cache"
      ]
    end

  end
end