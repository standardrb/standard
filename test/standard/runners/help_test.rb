require "test_helper"

require "standard/runners/help"

class Standard::Runners::HelpTest < UnitTest
  def setup
    @subject = Standard::Runners::Help.new
  end

  def test_prints_help
    fake_out, _ = do_with_fake_io {
      @subject.call(nil)
    }

    expected = <<-MESSAGE.gsub(/^ {6}/, "")
      Usage:

        $ standardrb [path1] [path2]

      Standard will lint the current working directory if no paths are provided.

      Options:

        --fix             Automatically fix failures wherever possible
        --format [name]   Format output with any RuboCop formatter (e.g. "json")
        --version, -v     Print the version of standard
        --help, -h        Print this message

      Standard also forwards most CLI options to RuboCop. You can see them by running:

        $ rubocop --help

      While Standard has few configuration options, most can be set in a `.standard.yml`
      file. For full documentation, please visit:

        https://github.com/testdouble/standard

      Having trouble? Here's some diagnostic information:

              Ruby version: #{RUBY_VERSION}
         Current directory: #{Dir.pwd}
           RuboCop version: #{RuboCop::Version.version}
          Standard version: #{Standard::VERSION}
      Standard config file: #{Standard::FileFinder.new.call(".standard.yml", Dir.pwd)}
    MESSAGE
    assert_equal expected, fake_out.string
  end
end
