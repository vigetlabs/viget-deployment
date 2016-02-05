module Configuration
  def database_config
    YAML.load_file('config/config.yml')['database']
  end

  def root_path
    Pathname.new(File.expand_path(File.dirname(__FILE__))).join('..', '..')
  end

  def asset_path
    root_path.join('lib', 'viget', 'deployment', 'assets')
  end

  def ask(prompt, default = nil)
    @saved_responses ||= {}

    key = prompt.strip

    return @saved_responses[key] if @saved_responses[key]

    question = prompt
    question << "|#{default}| " if default

    print question
    response = STDIN.gets.chomp

    response = default if default && response == ''
    @saved_responses[key] = response
  end

  def configuration_files
    configuration_file_mapping.values
  end

end