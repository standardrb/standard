require_relative "../file_finder"
require_relative "../plugin"

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
    end

    def call(options_config, standard_config)
      return unless standard_config[:extend_config]&.any?

      plugins = standard_config[:extend_config].map { |path|
        ExtendConfigPlugin.new(path)
      }
      @merges_plugins_into_rubocop_config.call(options_config, standard_config, plugins, permit_merging: false)
    end
  end
end
