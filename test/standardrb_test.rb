require_relative "test_helper"
require "open3"

class StandardrbTest < UnitTest
  def test_project_a_failure_output
    stdout, status = run_standardrb("test/fixture/project/a")

    refute status.success?
    assert_same_lines <<-MSG.gsub(/^ {6}/, ""), stdout
      #{standard_greeting}
        lib/foo/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        lib/foo/tmp/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        lib/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
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
    assert_same_lines <<-MSG.gsub(/^ {6}/, ""), stdout
      #{standard_greeting}
        do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
        tmp/do_lint.rb:1:1: Lint/UselessAssignment: Useless assignment to variable - `useless_assignment`.
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
end
