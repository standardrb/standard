require_relative "../file_finder"

module Standard
  module Runners
    class Help
      def call(config)
        puts <<~MESSAGE
          Usage: standardrb [--fix] [--lsp] [-vh] [--format <name>] [--] [FILE]...

          Options:

            --fix             Apply automatic fixes that we're confident won't break your code
            --fix-unsafely    Apply even more fixes, including some that may change code behavior
            --no-fix          Do not automatically fix failures
            --format <name>   Format output with any RuboCop formatter (e.g. "json")
            --generate-todo   Create a .standard_todo.yml that lists all the files that contain errors
            --lsp             Start a LSP server listening on STDIN
            -v, --version     Print the version of Standard
            -V, --verbose-version   Print the version of Standard and its dependencies.
            -h, --help        Print this message
            FILE              Files to lint [default: ./]

          Standard also forwards most CLI arguments to RuboCop. To see them, run:

            $ rubocop --help

          While Standard only offers a few configuration options, most can be set in
          a `.standard.yml` file. For full documentation, please visit:

            https://github.com/standardrb/standard

          Having trouble? Here's some diagnostic information:

                  Ruby version: #{RUBY_VERSION}
             Current directory: #{Dir.pwd}
               RuboCop version: #{RuboCop::Version.version}
              Standard version: #{Standard::VERSION}
          Standard config file: #{FileFinder.new.call(".standard.yml", Dir.pwd) || "[No file found]"}

          Please report any problems (and include the above information) at the URL below:

            https://github.com/standardrb/standard/issues/new

        MESSAGE
      end
    end
  end
end
