require "test_helper"

class Standard::BuildsConfigTest < UnitTest
  DEFAULT_OPTIONS = {
    auto_correct: false,
    safe_auto_correct: false,
    formatters: [["Standard::Formatter", nil]],
    parallel: false,
  }.freeze

  DEFAULT_CONFIG = RuboCop::ConfigStore.new.tap do |config_store|
    config_store.options_config = path("config/base.yml")
    options_config = config_store.instance_variable_get("@options_config")
    options_config["AllCops"]["TargetRubyVersion"] = RUBY_VERSION.to_f
  end.for("").to_h.freeze

  def setup
    @subject = Standard::BuildsConfig.new
  end

  def test_no_argv_and_no_standard_dot_yml
    result = @subject.call([], "/")

    assert_equal :rubocop, result.runner
    assert_equal DEFAULT_OPTIONS, result.rubocop_options
    assert_equal DEFAULT_CONFIG, result.rubocop_config_store.for("").to_h
  end

  def test_custom_argv_with_fix_set
    result = @subject.call(["--only", "Standard/SemanticBlocks", "--fix", "--parallel"])

    assert_equal DEFAULT_OPTIONS.merge(
      auto_correct: true,
      safe_auto_correct: true,
      parallel: true,
      only: ["Standard/SemanticBlocks"]
    ), result.rubocop_options
  end

  def test_blank_standard_yaml
    result = @subject.call([], path("test/fixture/config/z"))

    assert_equal DEFAULT_OPTIONS, result.rubocop_options
    assert_equal DEFAULT_CONFIG, result.rubocop_config_store.for("").to_h
  end

  def test_decked_out_standard_yaml
    result = @subject.call([], path("test/fixture/config/y"))

    assert_equal DEFAULT_OPTIONS.merge(
      auto_correct: true,
      safe_auto_correct: true,
      parallel: true,
      formatters: [["progress", nil]]
    ), result.rubocop_options

    expected_config = RuboCop::ConfigStore.new.tap do |config_store|
      config_store.options_config = path("config/ruby-1.8.yml")
      options_config = config_store.instance_variable_get("@options_config")
      options_config["AllCops"]["Exclude"] << path("test/fixture/config/y/monkey/**/*")
      options_config["Fake/Lol"] = {"Exclude" => [path("test/fixture/config/y/neat/cool.rb")]}
      options_config["Fake/Kek"] = {"Exclude" => [path("test/fixture/config/y/neat/cool.rb")]}
    end.for("").to_h
    assert_equal expected_config, result.rubocop_config_store.for("").to_h
  end

  def test_single_line_ignore
    result = @subject.call([], path("test/fixture/config/x"))

    assert_equal DEFAULT_OPTIONS, result.rubocop_options
    assert_equal DEFAULT_CONFIG.merge(
      "AllCops" => DEFAULT_CONFIG["AllCops"].merge(
        "Exclude" => DEFAULT_CONFIG["AllCops"]["Exclude"] + [path("test/fixture/config/x/pants/**/*")]
      )
    ), result.rubocop_config_store.for("").to_h
  end

  def test_19
    result = @subject.call([], path("test/fixture/config/w"))

    assert_equal DEFAULT_OPTIONS, result.rubocop_options

    expected_config = RuboCop::ConfigStore.new.tap do |config_store|
      config_store.options_config = path("config/ruby-1.9.yml")
    end.for("").to_h
    assert_equal expected_config, result.rubocop_config_store.for("").to_h
  end

  def test_specified_standard_yaml_overrides_local
    result = @subject.call(["--config", "test/fixture/lol.standard.yml"], path("test/fixture/config/z"))

    assert_equal DEFAULT_OPTIONS.merge(
      auto_correct: true,
      safe_auto_correct: true
    ), result.rubocop_options
    assert_equal DEFAULT_CONFIG, result.rubocop_config_store.for("").to_h
  end

  def test_specified_standard_yaml_raises
    err = assert_raises(StandardError) {
      @subject.call(["--config", "fake.file"], path("test/fixture/config/z"))
    }
    assert_match(/Configuration file ".*fake\.file" not found/, err.message)
  end
end
