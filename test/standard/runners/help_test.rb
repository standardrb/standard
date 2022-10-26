require_relative "../../test_helper"

require "standard/runners/help"

class Standard::Runners::HelpTest < UnitTest
  def setup
    @subject = Standard::Runners::Help.new
  end

  def test_prints_help
    fake_out, _ = do_with_fake_io {
      @subject.call(nil)
    }

    expected = <<~MESSAGE
      Usage: standardrb [--fix] [--lsp] [-vh] [--format <name>] [--] [FILE]...

      Options:

        --fix             Automatically fix failures where possible
        --no-fix          Do not automatically fix failures
        --format <name>   Format output with any RuboCop formatter (e.g. "json")
        --generate-todo   Create a .standard_todo.yml that lists all the files that contain errors
        --lsp             Start a LSP server listening on STDIN
        -v, --version     Print the version of Standard
        -h, --help        Print this message
        FILE              Files to lint [default: ./]

      Standard also forwards most CLI arguments to RuboCop. To see them, run:

        $ rubocop --help

      While Standard only offers a few configuration options, most can be set in
      a `.standard.yml` file. For full documentation, please visit:

        https://github.com/testdouble/standard

      Having trouble? Here's some diagnostic information:

              Ruby version: #{RUBY_VERSION}
         Current directory: #{Dir.pwd}
           RuboCop version: #{RuboCop::Version.version}
          Standard version: #{Standard::VERSION}
      Standard config file: #{Standard::FileFinder.new.call(".standard.yml", Dir.pwd)}

      Please report any problems (and include the above information) at the URL below:

        https://github.com/testdouble/standard/issues/new

    MESSAGE
    assert_equal expected, fake_out.string
  end
end
