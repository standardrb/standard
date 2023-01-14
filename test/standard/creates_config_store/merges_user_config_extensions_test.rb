require_relative "../../test_helper"

class Standard::CreatesConfigStore::MergesUserConfigExtensionsTest < UnitTest
  def setup
    @subject = Standard::CreatesConfigStore::MergesUserConfigExtensions.new
  end

  def test_doesnt_change_config_when_no_extensions_defined
    options_config = {
      "AllCops" => {}
    }

    @subject.call(options_config, {
      extend_config: []
    })

    assert_equal({
      "AllCops" => {}
    }, options_config)
  end

  def test_when_one_file_extends
    options_config = {
      "AllCops" => {
        "TargetRubyVersion" => "2.6"
      }
    }

    @subject.call(options_config, {
      extend_config: ["test/fixture/extend_config/all_cops.yml"]
    })

    assert_equal({
      "AllCops" => {
        # Ignored b/c DISALLOWED_ALLCOPS_KEYS
        "TargetRubyVersion" => "2.6",
        # Excluded b/c DISALLOWED_ALLCOPS_KEYS
        # "StyleGuideCopsOnly" => false,

        # Allowed to overwrite
        "DisabledByDefault" => true,
        "StyleGuideBaseURL" => "https://all_cops.yml"
      }
    }, options_config)
  end

  def test_when_two_files_extend
    options_config = {
      "AllCops" => {}
    }

    @subject.call(options_config, {
      extend_config: [
        "test/fixture/extend_config/all_cops.yml",
        "test/fixture/extend_config/betterlint.yml"
      ]
    })

    assert_equal({
      "AllCops" => {
        "DisabledByDefault" => true,
        # Last-in wins
        "StyleGuideBaseURL" => "https://betterlint.yml"
      },
      "Betterment/UnscopedFind" => {
        "Enabled" => true,
        "unauthenticated_models" => ["SystemConfiguration"]
      }
    }, options_config)
  end

  def test_when_three_files_extend_with_monkey_business
    options_config = {
      "AllCops" => {},
      "Naming/VariableName" => {"Enabled" => true}
    }

    @subject.call(options_config, {
      extend_config: [
        "test/fixture/extend_config/all_cops.yml",
        "test/fixture/extend_config/betterlint.yml",
        "test/fixture/extend_config/monkey_business.yml"
      ]
    })

    assert_equal({
      "AllCops" => {
        "DisabledByDefault" => true,
        "StyleGuideBaseURL" => "https://betterlint.yml"
      },

      # Last-in wins, shallow merge for nested hashes other than AllCops
      "Betterment/UnscopedFind" => {
        "Enabled" => false
      },

      # Note that Naming/VariableName is not modified here, b/c it's a built-in
      "Naming/VariableName" => {
        "Enabled" => true
      }
    }, options_config)
  end
end
