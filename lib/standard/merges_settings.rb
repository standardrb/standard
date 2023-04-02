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
      argv.partition do |flag|
        ["--generate-todo", "--fix", "--fix-unsafely", "--no-fix", "--version", "-v", "--verbose-version", "-V", "--help", "-h", "--lsp"].include?(flag)
      end
    end

    def parse_standard_argv(argv)
      argv.each_with_object({}) do |arg, cli_flags|
        if arg == "--fix"
          cli_flags[:autocorrect] = true
          cli_flags[:safe_autocorrect] = true
        elsif arg == "--fix-unsafely"
          cli_flags[:autocorrect] = true
          cli_flags[:safe_autocorrect] = false
        elsif arg == "--no-fix"
          cli_flags[:autocorrect] = false
          cli_flags[:safe_autocorrect] = false
        end
      end
    end

    def determine_command(argv)
      if (argv & ["--help", "-h"]).any?
        :help
      elsif (argv & ["--version", "-v"]).any?
        :version
      elsif (argv & ["--verbose-version", "-V"]).any?
        :verbose_version
      elsif (argv & ["--generate-todo"]).any?
        :genignore
      elsif (argv & ["--lsp"]).any?
        :lsp
      else
        :rubocop
      end
    end

    def merge(standard_yaml, standard_cli_flags, rubocop_cli_flags)
      {
        autocorrect: standard_yaml[:fix],
        safe_autocorrect: true,
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
