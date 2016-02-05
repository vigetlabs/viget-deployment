module Configuration
  module Craft
    include Configuration

    def slug
      'craft'
    end

    def name
      'Craft'
    end

    def configuration_file_mapping
      {
        'config.yml.erb' => 'config/config.yml',
        'db.php.erb'     => 'craft/config/db.php'
      }
    end

    def untracked_directories
      ['public/uploads']
    end

  end
end