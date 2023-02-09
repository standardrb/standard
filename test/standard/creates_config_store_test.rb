require_relative "../test_helper"

class Standard::CreatesConfigStore
  class Test < UnitTest
    def setup
      @assigns_rubocop_yaml = Mocktail.of_next(AssignsRubocopYaml)
      @sets_target_ruby_version = Mocktail.of_next(SetsTargetRubyVersion)
      @configures_ignored_paths = Mocktail.of_next(ConfiguresIgnoredPaths)
      @merges_user_config_extensions = Mocktail.of_next(MergesUserConfigExtensions)

      @subject = Standard::CreatesConfigStore.new
    end

    def test_minimal_config
      standard_config = :some_config
      options_config = :some_options
      stubs { |m| @assigns_rubocop_yaml.call(m.is_a(RuboCop::ConfigStore), standard_config) }.with { options_config }

      @subject.call(standard_config)

      verify { @sets_target_ruby_version.call(options_config, standard_config) }
      verify { @configures_ignored_paths.call(options_config, standard_config) }
      verify { @merges_user_config_extensions.call(options_config, standard_config) }
    end
  end
end
