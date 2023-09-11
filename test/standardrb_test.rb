require_relative "test_helper"
require "open3"

class StandardrbTest < UnitTest
  FIXTURE_ROOT_FOLDER = "test/fixture"
  TEST_ROOT_FOLDER = "tmp/tests/standardrb"

  # Initialize the test folder once for all the tests
  # in this file.
  FileUtils.rm_rf(TEST_ROOT_FOLDER)
  FileUtils.mkdir_p(TEST_ROOT_FOLDER)

  def test_project_a_failure_output
    stdout, status = run_standardrb("test/fixture/project/a")

    refute status.success?
    assert_same_lines <<~MSG, stdout
      #{standard_greeting}
        lib/foo/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        lib/foo/meh/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        lib/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
    MSG
  end

  def test_generate_todo
    assert_generate_todo("standardrb/generate_todo", "generate_todo", %w[--generate-todo --config ./.standard.yml])
  end

  def test_generate_todo_existing
    assert_generate_todo("standardrb/generate_todo_existing", "generate_todo_existing", %w[--generate-todo --config ./.standard.yml])
  end

  def test_project_a_forwards_rubocop_options
    stdout, status = run_standardrb("test/fixture/project/a", %w[--only Style/TrivialAccessors])

    assert status.success?
    assert_equal "", stdout
  end

  def test_project_with_cwd_in_nested_path
    stdout, status = run_standardrb("test/fixture/project/a/lib/foo")

    refute status.success?
    assert_same_lines <<~MSG, stdout
      #{standard_greeting}
        do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        meh/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
    MSG
  end

  def test_quoted_symbols_are_enforced
    stdout, status = run_standardrb("test/fixture/quoted_symbols")
    refute status.success?, stdout
    assert_equal stdout.scan(/.*\.rb.*/), [
      "  test.rb:2:5: Style/QuotedSymbols: Prefer double-quoted symbols unless you need single quotes to avoid extra backslashes for escaping."
    ]
  end

  def test_extend_config_option
    stdout, status = run_standardrb("test/fixture/extend_config/project")

    refute status.success?
    assert_same_lines <<~MSG, stdout
      #{standard_greeting}
        oranges.rb:1:1: Bananas/BananasOnly: Bananas only! No oranges.
    MSG
  end

  def test_plugins_options
    stdout, status = run_standardrb("test/fixture/plugins/project")

    refute status.success?
    assert_same_lines <<~MSG, stdout
      #{standard_greeting}
      standard: Run `standardrb --fix` to potentially fix one problem.
        olives.rb:1:10: Style/StringLiterals: Prefer double-quoted strings unless you need single quotes to avoid extra backslashes for escaping.
        olives.rb:1:1: Bananas/BananasOnly: Bananas only! No steak or apples or shenanigans.
    MSG
  end

  private

  def run_standardrb(cwd, args = [])
    og_pwd = Dir.pwd
    Dir.chdir(cwd)
    Open3.capture2(File.join(__dir__, "../exe/standardrb"), *args)
  ensure
    Dir.chdir(og_pwd)
  end

  def assert_same_lines(expected, actual)
    assert_equal expected.split("\n").sort, actual.split("\n").sort
  end

  def assert_generate_todo(fixture_subfolder, test_subfolder, arguments)
    fixture_folder = File.join(FIXTURE_ROOT_FOLDER, fixture_subfolder)
    test_folder = File.join(TEST_ROOT_FOLDER, test_subfolder)

    FileUtils.cp_r(File.join(fixture_folder, "."), test_folder)

    stdout, status = run_standardrb(test_folder, arguments)

    # The generate todo returns the Rubocop result which is non-zero
    # if any linting errors where found.
    refute status.success?
    assert stdout.empty?

    assert File.exist?(File.join(test_folder, ".standard_todo.yml"))
    assert_equal File.read(File.join(test_folder, ".standard_todo_expected.yml")), File.read(File.join(test_folder, ".standard_todo.yml"))
  end
end
