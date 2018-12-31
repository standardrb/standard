require_relative "../file_finder"

module Standard
  module Runners
    class Help
      def call(config)
        puts <<-MESSAGE.gsub(/^ {10}/, "")
          Usage: standardrb [--fix] [-vh] [--format <name>] [--] [FILE]...

          Options:

            --fix             Automatically fix failures where possible
            --no-fix          Do not automatically fix failures
            --format <name>   Format output with any RuboCop formatter (e.g. "json")
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
          Standard config file: #{FileFinder.new.call(".standard.yml", Dir.pwd) || "[No file found]"}

          Please report any problems (and include the above information) at the URL below:

            https://github.com/testdouble/standard/issues/new

        MESSAGE
      end
    end
  end
end
