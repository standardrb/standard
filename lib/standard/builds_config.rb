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

      # Don't load the existing todo file when generating a new todo file.  Otherwise the
      # new todo file won't have the ignore rules in the existing file.
      todo_yaml_path = unless argv.include?("--generate-todo")
        @resolves_yaml_option.call(argv, search_path, "--todo", ".standard_todo.yml")
      end

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
