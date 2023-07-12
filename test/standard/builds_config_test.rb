require_relative "../test_helper"

class Standard::BuildsConfigTest < UnitTest
  DEFAULT_OPTIONS = {
    autocorrect: false,
    safe_autocorrect: true,
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
  end

  def test_custom_argv_with_fix_set
    result = @subject.call(["--only", "Standard/SemanticBlocks", "--fix", "--parallel"])

    assert_equal DEFAULT_OPTIONS.merge(
      autocorrect: true,
      safe_autocorrect: true,
      parallel: true,
      only: ["Lint/Syntax", "Standard/SemanticBlocks"]
    ), result.rubocop_options
  end

  def test_blank_standard_yaml
    result = @subject.call([], path("test/fixture/config/z"))

    assert_equal DEFAULT_OPTIONS, result.rubocop_options
  end

  def test_decked_out_standard_yaml
    result = @subject.call([], path("test/fixture/config/y"))

    assert_equal DEFAULT_OPTIONS.merge(
      autocorrect: true,
      safe_autocorrect: true,
      parallel: true,
      formatters: [["progress", nil]]
    ), result.rubocop_options

    resulting_options_config = result.rubocop_config_store.for("").to_h
    assert_includes resulting_options_config["AllCops"]["Exclude"], path("test/fixture/config/y/monkey/**/*")
    assert_equal({"Exclude" => [path("test/fixture/config/y/neat/cool.rb")]}, resulting_options_config["Fake/Lol"])
    assert_equal({"Exclude" => [path("test/fixture/config/y/neat/cool.rb")]}, resulting_options_config["Fake/Kek"])
  end

  def test_single_line_ignore
    result = @subject.call([], path("test/fixture/config/x"))

    assert_equal DEFAULT_OPTIONS, result.rubocop_options
    resulting_options_config = result.rubocop_config_store.for("").to_h
    assert_includes resulting_options_config["AllCops"]["Exclude"], path("test/fixture/config/x/pants/**/*")
  end

  def test_specified_standard_yaml_overrides_local
    result = @subject.call(["--config", "test/fixture/lol.standard.yml"], path("test/fixture/config/z"))

    assert_equal DEFAULT_OPTIONS.merge(
      autocorrect: true,
      safe_autocorrect: true
    ), result.rubocop_options
  end

  def test_specified_standard_yaml_raises
    err = assert_raises(StandardError) do
      @subject.call(["--config", "fake.file"], path("test/fixture/config/z"))
    end
    assert_match(/Configuration file ".*fake\.file" not found/, err.message)
  end

  def test_todo_file_not_loaded_when_generating_todo_file
    result = @subject.call(["--generate-todo"], path("test/fixture/config/t"))

    assert_equal DEFAULT_OPTIONS.merge(
      todo_file: nil,
      todo_ignore_files: []
    ), result.rubocop_options
  end

  def test_todo_with_offenses_merged
    result = @subject.call([], path("test/fixture/config/t"))

    assert_equal DEFAULT_OPTIONS.merge(
      todo_file: path("test/fixture/config/t/.standard_todo.yml"),
      todo_ignore_files: %w[todo_file_one.rb todo_file_two.rb]
    ), result.rubocop_options

    resulting_options_config = result.rubocop_config_store.for("").to_h
    assert_includes resulting_options_config["AllCops"]["Exclude"], path("test/fixture/config/t/none_todo_path/**/*")
    assert_includes resulting_options_config["AllCops"]["Exclude"], path("test/fixture/config/t/none_todo_file.rb")
    assert_includes resulting_options_config["AllCops"]["Exclude"], path("test/fixture/config/t/todo_file_two.rb")
    assert_includes resulting_options_config["Lint/AssignmentInCondition"]["Exclude"], path("test/fixture/config/t/todo_file_one.rb")
  end
end
