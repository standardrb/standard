require_relative "../runners/rubocop"

module Standard
  module Lsp
    class Standardizer
      def initialize(config)
        @config = config
        @rubocop_runner = Standard::Runners::Rubocop.new
      end

      # This abuses the --stdin option of rubocop and reads the formatted text
      # from the options[:stdin] that rubocop mutates. This depends on
      # parallel: false as well as the fact that rubocop doesn't otherwise dup
      # or reassign that options object. Risky business!
      #
      # Reassigning options[:stdin] is done here:
      #   https://github.com/rubocop/rubocop/blob/master/lib/rubocop/cop/team.rb#L131
      # Printing options[:stdin]
      #   https://github.com/rubocop/rubocop/blob/master/lib/rubocop/cli/command/execute_runner.rb#L95
      # Setting `parallel: true` would break this here:
      #   https://github.com/rubocop/rubocop/blob/master/lib/rubocop/runner.rb#L72
      def format(path, text)
        ad_hoc_config = fork_config(path, text, format: true)
        capture_rubocop_stdout(ad_hoc_config)
        ad_hoc_config.rubocop_options[:stdin]
      end

      def offenses(path, text)
        results = capture_rubocop_stdout(fork_config(path, text, format: false))
        JSON.parse(results, symbolize_names: true).dig(:files, 0, :offenses)
      end

      private

      # Can't make frozen versions of this hash because RuboCop mutates it
      def fork_config(path, text, format:)
        o = if format
          {stdin: text, autocorrect: true, formatters: [["Standard::Formatter", nil]], parallel: false, todo_file: nil, todo_ignore_files: [], safe_autocorrect: true}
        else
          {stdin: text, autocorrect: false, formatters: [["json"]], parallel: false, todo_file: nil, todo_ignore_files: [], format: "json"}
        end
        Standard::Config.new(@config.runner, [path], o, @config.rubocop_config_store)
      end

      def capture_rubocop_stdout(config)
        redir = StringIO.new
        $stdout = redir
        @rubocop_runner.call(config)
        redir.string
      ensure
        $stdout = STDOUT
      end
    end
  end
end
