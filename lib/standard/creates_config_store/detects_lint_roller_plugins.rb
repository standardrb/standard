class Standard::CreatesConfigStore
  class DetectsLintRollerPlugins
    def initialize
      @determines_class_constant = Standard::Plugin::DeterminesClassConstant.new
    end

    def call(loaded_gems = Gem.loaded_specs.values)
      lint_roller_plugins = []

      loaded_gems.each do |gem_spec|
        next unless gem_spec.metadata.key?("default_lint_roller_plugin")

        plugin_class_name = gem_spec.metadata["default_lint_roller_plugin"]

        begin
          require gem_spec.name

          plugin_class = @determines_class_constant.call(gem_spec.name, {
            "plugin_class_name" => plugin_class_name
          })

          plugin_instance = plugin_class.new({})

          lint_roller_plugins << plugin_instance
        rescue LoadError => e
          warn "[Standard] Failed to load gem '#{gem_spec.name}': #{e.message}" if ENV["DEBUG"]
          next
        rescue => e
          warn "[Standard] Failed to load lint_roller plugin from '#{gem_spec.name}': #{e.message}" if ENV["DEBUG"]
          next
        end
      end

      lint_roller_plugins
    end
  end
end
