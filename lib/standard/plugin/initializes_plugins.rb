module Standard
  module Plugin
    class InitializesPlugins
      def initialize
        @standardizes_configured_plugins = StandardizesConfiguredPlugins.new
        @determines_class_constants = DeterminesClassConstant.new
      end

      def call(plugins)
        plugin_configs = @standardizes_configured_plugins.call(plugins)
        plugin_configs.map { |name, user_config|
          if user_config["enabled"]
            @determines_class_constants.call(name, user_config).new(user_config)
          end
        }
      end
    end
  end
end
