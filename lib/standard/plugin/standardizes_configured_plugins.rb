module Standard
  module Plugin
    class StandardizesConfiguredPlugins
      DEFAULT_PLUGIN_CONFIG = {
        "enabled" => true,
        "require_path" => nil, # If not set, will be set to the plugin name
        "plugin_class_name" => nil # If not set, looks for gemspec `spec.metadata["default_lint_roller_plugin"]`
      }.freeze

      BUILT_INS = [
        {"standard-base" => {
          "require_path" => "standard/base",
          "plugin_class_name" => "Standard::Base::Plugin"
        }},
        "standard-custom",
        "standard-performance"
      ].freeze

      def call(plugins)
        normalize_config_shape(BUILT_INS + plugins)
      end

      private

      def normalize_config_shape(plugins)
        plugins.map { |plugin|
          if plugin.is_a?(Hash)
            plugin_name = plugin.keys.first
            [plugin_name, DEFAULT_PLUGIN_CONFIG.merge({"require_path" => plugin_name}, plugin.values.first)]
          else
            [plugin, DEFAULT_PLUGIN_CONFIG.merge("require_path" => plugin)]
          end
        }.to_h
      end
    end
  end
end
