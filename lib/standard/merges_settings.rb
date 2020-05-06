require "rubocop"

module Standard
  class MergesSettings
    Settings = Struct.new(:runner, :options, :paths)

    def call(argv, standard_yaml)
      standard_argv, rubocop_argv = separate_argv(argv)
      standard_cli_flags = parse_standard_argv(standard_argv)
      rubocop_cli_flags, lint_paths = RuboCop::Options.new.parse(rubocop_argv)

      Settings.new(
        determine_command(standard_argv),
        merge(standard_yaml, standard_cli_flags, without_banned(rubocop_cli_flags)),
        lint_paths
      )
    end

    private

    def separate_argv(argv)
      argv.partition { |flag|
        ["--generate-todo", "--fix", "--no-fix", "--version", "-v", "--help", "-h"].include?(flag)
      }
    end

    def parse_standard_argv(argv)
      argv.each_with_object({}) { |arg, cli_flags|
        if arg == "--fix"
          cli_flags[:auto_correct] = true
          cli_flags[:safe_auto_correct] = true
        elsif arg == "--no-fix"
          cli_flags[:auto_correct] = false
          cli_flags[:safe_auto_correct] = false
        end
      }
    end

    def determine_command(argv)
      if (argv & ["--help", "-h"]).any?
        :help
      elsif (argv & ["--version", "-v"]).any?
        :version
      elsif (argv & ["--generate-todo"]).any?
        :genignore
      else
        :rubocop
      end
    end

    def merge(standard_yaml, standard_cli_flags, rubocop_cli_flags)
      {
        auto_correct: standard_yaml[:fix],
        safe_auto_correct: standard_yaml[:fix],
        formatters: [[standard_yaml[:format] || "Standard::Formatter", nil]],
        parallel: standard_yaml[:parallel],
        todo_file: standard_yaml[:todo_file],
        todo_ignore_files: standard_yaml[:todo_ignore_files]
      }.merge(standard_cli_flags).merge(rubocop_cli_flags)
    end

    def without_banned(rubocop_cli_flags)
      rubocop_cli_flags.tap do |flags|
        flags.delete(:config)
      end
    end
  end
end
