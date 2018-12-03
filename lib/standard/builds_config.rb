require_relative "loads_yaml_config"
require_relative "merges_settings"
require_relative "creates_config_store"

module Standard
  Config = Struct.new(:runner, :paths, :rubocop_options, :rubocop_config_store)

  class BuildsConfig
    def initialize
      @loads_yaml_config = LoadsYamlConfig.new
      @merges_settings = MergesSettings.new
      @creates_config_store = CreatesConfigStore.new
    end

    def call(argv, search_path = Dir.pwd)
      standard_config = @loads_yaml_config.call(search_path)
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
