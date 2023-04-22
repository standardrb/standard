require_relative "../test_helper"

class Standard::LoadsYamlConfigTest < UnitTest
  DEFAULT_STANDARD_CONFIG = {
    ruby_version: Gem::Version.new(RUBY_VERSION),
    fix: false,
    format: nil,
    parallel: false,
    ignore: [],
    default_ignores: true,
    config_root: nil,
    todo_file: nil,
    todo_ignore_files: [],
    plugins: [],
    extend_config: []
  }.freeze

  def setup
    @subject = Standard::LoadsYamlConfig.new
  end

  def test_no_files
    result = @subject.call(nil, nil)

    assert_equal(DEFAULT_STANDARD_CONFIG, result)
  end
end
