require "test_helper"
require "fileutils"

class Standard::CliTest < UnitTest
  def setup
    FileUtils.rm_rf("tmp/cli_test")
    FileUtils.mkdir_p("tmp/cli_test")
  end

  def test_example_1
    FileUtils.cp("test/fixture/cli/autocorrectable-bad.rb", "tmp/cli_test/subject.rb")

    Standard::Cli.new(["tmp/cli_test/subject.rb", "--fix"]).run

    assert_equal IO.read("test/fixture/cli/autocorrectable-good.rb"), IO.read("tmp/cli_test/subject.rb")
  end
end
