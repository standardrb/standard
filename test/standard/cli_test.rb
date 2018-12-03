require "test_helper"
require "fileutils"

class Standard::CliTest < UnitTest
  def test_autocorrectable
    FileUtils.rm_rf("tmp/cli_test")
    FileUtils.mkdir_p("tmp/cli_test")

    FileUtils.cp("test/fixture/cli/autocorrectable-bad.rb", "tmp/cli_test/subject.rb")

    exit_code = Standard::Cli.new(["tmp/cli_test/subject.rb", "--fix"]).run

    assert_equal 0, exit_code
    assert_equal IO.read("test/fixture/cli/autocorrectable-good.rb"), IO.read("tmp/cli_test/subject.rb")
  end

  def test_unfixable_broken
    fake_out, fake_err, exit_code = do_with_fake_io {
      Standard::Cli.new(["test/fixture/cli/unfixable-bad.rb", "--fix"]).run
    }

    refute_equal 0, exit_code
    assert_empty fake_err.string
    assert_equal <<-OUTPUT.gsub(/^ {6}/, ""), fake_out.string
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `standardrb --fix` to automatically fix some problems.
        test/fixture/cli/unfixable-bad.rb:3:12: Lint/AssignmentInCondition: Wrap assignment in parentheses if intentional

      Notice: Disagree with these rules? While StandardRB is pre-1.0.0, feel free to submit suggestions to:
        https://github.com/testdouble/standard/issues/new
    OUTPUT
  end

  def test_unfixable_manually_fixed
    fake_out, fake_err, exit_code = do_with_fake_io {
      Standard::Cli.new(["test/fixture/cli/unfixable-good.rb", "--fix"]).run
    }

    assert_equal 0, exit_code
    assert_empty fake_err.string
    assert_empty fake_out.string
  end
end
