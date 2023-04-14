module Standard
  module Plugin
    class DeterminesClassConstant
      def call(plugin_name, user_config)
        require user_config["require_path"] unless user_config["require_path"].nil?

        if (constant_name = user_config["plugin_class_name"])
          begin
            Kernel.const_get(constant_name)
          rescue
            raise "Failed while configuring plugin `#{plugin_name}': no constant with name `#{constant_name}' was found"
          end
        else
          begin
            Kernel.const_get(Gem.loaded_specs[plugin_name].metadata["default_lint_roller_plugin"])
          rescue LoadError, StandardError
            raise <<~MSG
              Failed loading plugin `#{plugin_name}' because we couldn't determine
              the corresponding plugin class to instantiate.

              Standard plugin class names must either be:

                - If the plugin is a gem, defined in the gemspec as `default_lint_roller_plugin'

                  spec.metadata["default_lint_roller_plugin"] = "MyModule::Plugin"

                - Set in YAML as `plugin_class_name'; example:

                  plugins:
                    - incomplete:
                        require_path: my_module/plugin
                        plugin_class_name: "MyModule::Plugin"
            MSG
          end
        end
      end
    end
  end
end
