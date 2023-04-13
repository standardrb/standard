module Standard
  module Plugin
    class InitializesPlugins
      def initialize
        @standardizes_configured_plugins = StandardizesConfiguredPlugins.new
        @determines_class_constants = DeterminesClassConstant.new
      end

      def call(plugins)
        plugin_configs = @standardizes_configured_plugins.call(plugins)
        plugin_configs.map { |name_or_class, user_config|
          if user_config["enabled"]
            if name_or_class.is_a?(String) || name_or_class.is_a?(Symbol)
              @determines_class_constants.call(name_or_class, user_config).new(user_config)
            else
              name_or_class.new(user_config)
            end
          end
        }
      end
    end
  end
end
