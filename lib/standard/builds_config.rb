require_relative "loads_yaml_config"
require_relative "merges_settings"
require_relative "creates_config_store"

module Standard
  Config = Struct.new(:runner, :paths, :rubocop_options, :rubocop_config_store)

  class BuildsConfig
    def initialize
      @resolves_yaml_option = ResolvesYamlOption.new
      @loads_yaml_config = LoadsYamlConfig.new
      @merges_settings = MergesSettings.new
      @creates_config_store = CreatesConfigStore.new
    end

    def call(argv, search_path = Dir.pwd)
      standard_yaml_path = @resolves_yaml_option.call(argv, search_path, "--config", ".standard.yml")
      todo_yaml_path = @resolves_yaml_option.call(argv, search_path, "--todo", ".standard_todo.yml")
      standard_config = @loads_yaml_config.call(standard_yaml_path, todo_yaml_path)

      settings = @merges_settings.call(argv, standard_config)
      Config.new(
        settings.runner,
        settings.paths,
        settings.options,
        @creates_config_store.call(standard_config)
      )
    end
  end
end
