require_relative "../../test_helper"

class Standard::SetsTargetRubyVersionTest < UnitTest
  def setup
    @subject = Standard::CreatesConfigStore::SetsTargetRubyVersion.new
  end

  def test_sets_standard_numeric_target_ruby_version
    options_config = {
      "AllCops" => {}
    }

    @subject.call(options_config, {
      ruby_version: Gem::Version.new("3.0.1")
    })

    assert_equal({
      "AllCops" => {
        "TargetRubyVersion" => 3.0
      }
    }, options_config)
  end

  def test_sets_non_numeric_target_ruby_version
    options_config = {
      "AllCops" => {}
    }

    @subject.call(options_config, {
      ruby_version: "next"
    })

    assert_equal({
      "AllCops" => {
        "TargetRubyVersion" => "next"
      }
    }, options_config)
  end
end
