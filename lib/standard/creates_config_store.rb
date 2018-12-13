require "rubocop"

require_relative "creates_config_store/assigns_rubocop_yaml"
require_relative "creates_config_store/sets_target_ruby_version"
require_relative "creates_config_store/configures_ignored_paths"

module Standard
  class CreatesConfigStore
    def initialize
      @assigns_rubocop_yaml = AssignsRubocopYaml.new
      @sets_target_ruby_version = SetsTargetRubyVersion.new
      @configures_ignored_paths = ConfiguresIgnoredPaths.new
    end

    def call(standard_config)
      RuboCop::ConfigStore.new.tap do |config_store|
        options_config = @assigns_rubocop_yaml.call(config_store, standard_config)
        @sets_target_ruby_version.call(options_config, standard_config)
        @configures_ignored_paths.call(options_config, standard_config)
      end
    end
  end
end
