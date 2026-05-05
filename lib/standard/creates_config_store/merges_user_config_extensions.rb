require_relative "../file_finder"
require_relative "../plugin"
require_relative "detects_lint_roller_plugins"

class Standard::CreatesConfigStore
  class MergesUserConfigExtensions
    class ExtendConfigPlugin < LintRoller::Plugin
      def initialize(path)
        @yaml_path = Standard::FileFinder.new.call(path, Dir.pwd)
      end

      def about
        About.new("Pseudo-plugin wrapping the `extend_config' path: #{@yaml_path}")
      end

      def rules(context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: @yaml_path
        )
      end
    end

    def initialize
      @merges_plugins_into_rubocop_config = Standard::Plugin::MergesPluginsIntoRubocopConfig.new
      @detects_lint_roller_plugins = DetectsLintRollerPlugins.new
      @creates_runner_context = Standard::Plugin::CreatesRunnerContext.new
    end

    def call(options_config, standard_config)
      return unless standard_config[:extend_config]&.any?

      static_plugins = standard_config[:extend_config].map { |path|
        ExtendConfigPlugin.new(path)
      }

      needs_lint_roller_detection = should_detect_lint_roller_plugins?(standard_config[:extend_config], standard_config)

      @merges_plugins_into_rubocop_config.call(options_config, standard_config, static_plugins, permit_merging: needs_lint_roller_detection)

      # Only auto-detect when extend_config contains lint_roller cops to preserve backward compatibility
      all_lint_roller_plugins = if needs_lint_roller_detection
        @detects_lint_roller_plugins.call(Gem.loaded_specs.values)
      else
        []
      end

      if all_lint_roller_plugins.any?
        already_configured_cops = options_config.to_h.keys

        runner_context = @creates_runner_context.call(standard_config)
        new_plugins = all_lint_roller_plugins.select do |plugin|
          rules = plugin.rules(runner_context)
          if rules.type == :object
            rules.value.keys.any? { |cop| !already_configured_cops.include?(cop) }
          elsif rules.type == :path && rules.config_format == :rubocop
            begin
              plugin_config = YAML.load_file(rules.value) || {}
              plugin_cops = plugin_config.keys.select { |key| key.include?("/") }
              plugin_cops.none? { |cop| already_configured_cops.include?(cop) }
            rescue
              true
            end
          else
            true
          end
        end

        if new_plugins.any?
          @merges_plugins_into_rubocop_config.call(options_config, standard_config, new_plugins, permit_merging: false)
        end
      end
    end

    private

    def should_detect_lint_roller_plugins?(extend_config_paths, standard_config)
      return true if standard_config[:plugins]&.any?

      extend_config_paths.any? do |path|
        yaml_path = Standard::FileFinder.new.call(path, Dir.pwd)
        next false unless yaml_path && File.exist?(yaml_path)

        begin
          config_content = YAML.load_file(yaml_path) || {}

          has_explicit_plugins = config_content.key?("plugins")
          has_namespaced_cops = config_content.keys.any? { |key|
            key.include?("/") && !key.start_with?("AllCops")
          }

          has_explicit_plugins && has_namespaced_cops
        rescue
          false
        end
      end
    end
  end
end
