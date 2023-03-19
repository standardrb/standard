require_relative "../test_helper"
require "fileutils"

class Standard::CommentDirectiveTest < UnitTest
  def test_comment_directive
    fake_out, fake_err, exit_code = do_with_fake_io {
      Standard::Cli.new(["test/fixture/comment_directive_test/disabled.rb"]).run
    }

    refute_equal 0, exit_code
    assert_empty fake_err.string
    assert_equal <<-OUTPUT.gsub(/^ {6}/, ""), fake_out.string
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `standardrb --fix` to automatically fix some problems.
        test/fixture/comment_directive_test/disabled.rb:11:1: Layout/IndentationWidth: Use 2 (not 4) spaces for indentation.
    OUTPUT
  end

  def test_isolated_directive
    fake_out, fake_err, exit_code = do_with_fake_io {
      Standard::Cli.new(["test/fixture/comment_directive_test/isolated.rb"]).run
    }

    assert_equal 0, exit_code
    assert_empty fake_err.string
    assert_empty fake_out.string
  end
end
