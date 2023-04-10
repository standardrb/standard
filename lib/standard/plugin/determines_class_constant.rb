module Standard
  module Plugin
    class DeterminesClassConstant
      def call(plugin_name, user_config)
        if (constant_name = user_config["plugin_class_name"])
          begin
            Kernel.const_get(constant_name)
          rescue
            raise "Failed while configuring plugin `#{plugin_name}': no constant with name `#{constant_name}' was found"
          end
        else
          begin
            require plugin_name
            Kernel.const_get(Gem.loaded_specs[plugin_name].metadata["default_lint_roller_plugin"])
          rescue LoadError, StandardError => e
            raise "Failed while configuring plugin `#{plugin_name}'. #{e.class}: #{e.message}"
          end
        end
      end
    end
  end
end
