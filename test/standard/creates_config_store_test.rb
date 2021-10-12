require_relative "../test_helper"

class Standard::CreatesConfigStore
  class Test < UnitTest
    def setup
      @assigns_rubocop_yaml = gimme_next(AssignsRubocopYaml)
      @sets_target_ruby_version = gimme_next(SetsTargetRubyVersion)
      @configures_ignored_paths = gimme_next(ConfiguresIgnoredPaths)

      @subject = Standard::CreatesConfigStore.new
    end

    def test_minimal_config
      standard_config = :some_config
      options_config = :some_options
      give(@assigns_rubocop_yaml).call(is_a(RuboCop::ConfigStore), standard_config) { options_config }

      @subject.call(standard_config)

      verify(@sets_target_ruby_version).call(options_config, standard_config)
      verify(@configures_ignored_paths).call(options_config, standard_config)
    end
  end
end
