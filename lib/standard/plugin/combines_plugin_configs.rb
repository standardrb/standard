module Standard
  module Plugin
    class CombinesPluginConfigs
      def initialize
        @initializes_plugins = InitializesPlugins.new
      end

      def call(standard_config)
        plugins = @initializes_plugins.call(standard_config[:plugins])
      end
    end
  end
end
