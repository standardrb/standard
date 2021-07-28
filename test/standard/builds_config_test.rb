require "test_helper"

class Standard::BuildsConfigTest < UnitTest
  DEFAULT_OPTIONS = {
    auto_correct: false,
    safe_auto_correct: false,
    formatters: [["Standard::Formatter", nil]],
    parallel: false,
    todo_file: nil,
    todo_ignore_files: []
  }.freeze

  def setup
    @subject = Standard::BuildsConfig.new
  end

  def test_no_argv_and_no_standard_dot_yml
    result = @subject.call([], "/")

    assert_equal :rubocop, result.runner
    assert_equal DEFAULT_OPTIONS, result.rubocop_options
    assert_equal config_store, result.rubocop_config_store.for("").to_h
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
    assert_equal config_store("test/fixture/config/z"), result.rubocop_config_store.for("").to_h
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
      options_config["AllCops"]["Exclude"] |= [path("test/fixture/config/y/monkey/**/*")]
      options_config["Fake/Lol"] = {"Exclude" => [path("test/fixture/config/y/neat/cool.rb")]}
      options_config["Fake/Kek"] = {"Exclude" => [path("test/fixture/config/y/neat/cool.rb")]}
    end.for("").to_h
    assert_equal expected_config, result.rubocop_config_store.for("").to_h
  end

  def test_single_line_ignore
    result = @subject.call([], path("test/fixture/config/x"))

    assert_equal DEFAULT_OPTIONS, result.rubocop_options
    assert_equal config_store("test/fixture/config/x").dup.tap { |config_store|
      config_store["AllCops"]["Exclude"] |= [path("test/fixture/config/x/pants/**/*")]
    }, result.rubocop_config_store.for("").to_h
  end

  def test_19
    result = @subject.call([], path("test/fixture/config/w"))

    assert_equal DEFAULT_OPTIONS, result.rubocop_options

    assert_equal config_store("test/fixture/config/w", "config/ruby-1.9.yml", 2.5), result.rubocop_config_store.for("").to_h
  end

  def test_specified_standard_yaml_overrides_local
    result = @subject.call(["--config", "test/fixture/lol.standard.yml"], path("test/fixture/config/z"))

    assert_equal DEFAULT_OPTIONS.merge(
      auto_correct: true,
      safe_auto_correct: true
    ), result.rubocop_options
    assert_equal config_store("test/fixture"), result.rubocop_config_store.for("").to_h
  end

  def test_specified_standard_yaml_raises
    err = assert_raises(StandardError) {
      @subject.call(["--config", "fake.file"], path("test/fixture/config/z"))
    }
    assert_match(/Configuration file ".*fake\.file" not found/, err.message)
  end

  def test_todo_merged
    result = @subject.call([], path("test/fixture/config/u"))

    assert_equal DEFAULT_OPTIONS.merge(
      todo_file: path("test/fixture/config/u/.standard_todo.yml"),
      todo_ignore_files: %w[todo_file_one.rb todo_file_two.rb]
    ), result.rubocop_options

    assert_equal config_store("test/fixture/config/u").dup.tap { |config_store|
      config_store["AllCops"]["Exclude"] |= [path("test/fixture/config/u/none_todo_path/**/*")]
      config_store["AllCops"]["Exclude"] |= [path("test/fixture/config/u/none_todo_file.rb")]
      config_store["AllCops"]["Exclude"] |= [path("test/fixture/config/u/todo_file_one.rb")]
      config_store["AllCops"]["Exclude"] |= [path("test/fixture/config/u/todo_file_two.rb")]
    }, result.rubocop_config_store.for("").to_h
  end

  def test_todo_with_offenses_merged
    result = @subject.call([], path("test/fixture/config/t"))

    assert_equal DEFAULT_OPTIONS.merge(
      todo_file: path("test/fixture/config/t/.standard_todo.yml"),
      todo_ignore_files: %w[todo_file_one.rb todo_file_two.rb]
    ), result.rubocop_options

    assert_equal config_store("test/fixture/config/t").dup.tap { |config_store|
      config_store["AllCops"]["Exclude"] |= [path("test/fixture/config/t/none_todo_path/**/*")]
      config_store["AllCops"]["Exclude"] |= [path("test/fixture/config/t/none_todo_file.rb")]
      config_store["AllCops"]["Exclude"] |= [path("test/fixture/config/t/todo_file_two.rb")]
      config_store["Lint/AssignmentInCondition"]["Exclude"] = [path("test/fixture/config/t/todo_file_one.rb")]
    }, result.rubocop_config_store.for("").to_h
  end

  private

  def config_store(config_root = nil, rubocop_yml = highest_compatible_yml_version, ruby_version = RUBY_VERSION)
    RuboCop::ConfigStore.new.tap do |config_store|
      config_store.options_config = path(rubocop_yml)
      options_config = config_store.instance_variable_get("@options_config")
      options_config["AllCops"]["TargetRubyVersion"] = ruby_version.to_f
      options_config["AllCops"]["Exclude"] |= standard_default_ignores(config_root)
    end.for("").to_h
  end

  def highest_compatible_yml_version
    non_latest_ruby = Dir["config/*.yml"]
      .map { |n| n.match(/ruby-(.*)\.yml/) }.compact
      .map { |m| Gem::Version.new(m[1]) }.sort.reverse
      .find { |v| Gem::Version.new(RUBY_VERSION) >= v }

    if non_latest_ruby
      "config/ruby-#{non_latest_ruby}.yml"
    else
      "config/base.yml"
    end
  end

  def standard_default_ignores(config_root)
    Standard::CreatesConfigStore::ConfiguresIgnoredPaths::DEFAULT_IGNORES.map { |(path, _)|
      File.expand_path(File.join(config_root || Dir.pwd, path))
    }
  end
end
