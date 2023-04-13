module Standard
  module Plugin
    class StandardizesConfiguredPlugins
      BUILT_INS = [Standard::Base::Plugin, "standard-custom", "standard-performance"].freeze
      DEFAULT_PLUGIN_CONFIG = {
        "enabled" => true,
        "plugin_class_name" => nil
      }.freeze

      def call(plugins)
        prepend_built_ins_if_absent(normalize_from_yaml(plugins))
      end

      private

      def normalize_from_yaml(plugins)
        plugins.map { |plugin|
          if plugin.is_a?(Hash)
            [plugin.keys.first, DEFAULT_PLUGIN_CONFIG.merge(plugin.values.first)]
          else
            [plugin, DEFAULT_PLUGIN_CONFIG]
          end
        }.to_h
      end

      def prepend_built_ins_if_absent(plugins)
        missing_built_ins = BUILT_INS.select { |built_in| plugins.keys.none?(built_in) }
        return if missing_built_ins.none?

        (missing_built_ins.map { |built_in|
          [built_in, DEFAULT_PLUGIN_CONFIG]
        } + plugins.to_a).to_h
      end
    end
  end
end
