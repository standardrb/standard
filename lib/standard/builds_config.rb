require_relative "loads_yaml_config"
require_relative "merges_settings"
require_relative "creates_config_store"

module Standard
  Config = Struct.new(:runner, :paths, :rubocop_options, :rubocop_config_store)

  class BuildsConfig
    def initialize
      @parses_cli_option = ParsesCliOption.new
      @loads_yaml_config = LoadsYamlConfig.new
      @merges_settings = MergesSettings.new
      @creates_config_store = CreatesConfigStore.new
    end

    def call(argv, search_path = Dir.pwd)
      standard_yaml_path = determine_yaml_file(argv, search_path, "--config", ".standard.yml")
      todo_yaml_path = determine_yaml_file(argv, search_path, "--todo", ".standard_todo.yml")
      standard_config = @loads_yaml_config.call(standard_yaml_path, todo_yaml_path)

      settings = @merges_settings.call(argv, standard_config)
      Config.new(
        settings.runner,
        settings.paths,
        settings.options,
        @creates_config_store.call(standard_config)
      )
    end

    private

    def determine_yaml_file(argv, search_path, option_name, default_file)
      @parses_cli_option.call(argv, option_name) || FileFinder.new.call(default_file, search_path)
    end
  end
end
