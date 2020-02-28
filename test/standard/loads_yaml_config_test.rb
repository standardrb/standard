require "test_helper"

class Standard::LoadsYamlConfigTest < UnitTest
  DEFAULT_STANDARD_CONFIG = {
    ruby_version: Gem::Version.new(RUBY_VERSION),
    fix: false,
    format: nil,
    parallel: false,
    ignore: [],
    default_ignores: true,
    config_root: nil
  }.freeze

  def setup
    @subject = Standard::LoadsYamlConfig.new
  end

  def test_no_file
    result = @subject.call([], "/")

    assert_equal(DEFAULT_STANDARD_CONFIG, result)
  end
end
