module Standard
  module Plugin
    class CombinesPluginConfigs
      def initialize
        @initializes_plugins = InitializesPlugins.new
        @merges_plugins_into_rubocop_config = MergesPluginsIntoRubocopConfig.new
      end

      def call(options_config, standard_config, permit_merging:)
        plugins = @initializes_plugins.call(standard_config[:plugins])
        @merges_plugins_into_rubocop_config.call(options_config, standard_config, plugins, permit_merging: permit_merging)
      end
    end
  end
end
