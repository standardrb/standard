require "test_helper"
require "open3"

class StandardrbTest < UnitTest
  def test_project_a_failure_output
    stdout, status = run_standardrb("test/fixture/project/a")

    refute status.success?
    assert_equal <<-MSG.gsub(/^ {6}/, ""), stdout
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `standardrb --fix` to automatically fix some problems.
        lib/foo/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        lib/foo/tmp/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        lib/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.

      Notice: Disagree with these rules? While StandardRB is pre-1.0.0, feel free to submit suggestions to:
        https://github.com/testdouble/standard/issues/new
    MSG
  end

  def test_project_a_forwards_rubocop_options
    stdout, status = run_standardrb("test/fixture/project/a", %w[--only Style/TrivialAccessors])

    assert status.success?
    assert_equal "", stdout
  end

  def test_project_with_cwd_in_nested_path
    stdout, status = run_standardrb("test/fixture/project/a/lib/foo")

    refute status.success?
    assert_equal <<-MSG.gsub(/^ {6}/, ""), stdout
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `standardrb --fix` to automatically fix some problems.
        do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        tmp/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.

      Notice: Disagree with these rules? While StandardRB is pre-1.0.0, feel free to submit suggestions to:
        https://github.com/testdouble/standard/issues/new
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
end
