require_relative "../runners/rubocop"
require "tempfile"

module Standard
  module LSP
    class Standardizer
      def initialize(config)
        @template_options = config
        @runner = Standard::Runners::Rubocop.new
      end

      def format(text)
        run_standard(text, format: true)
      end

      def offenses(text)
        results = run_standard(text, format: false)
        JSON.parse(results, symbolize_names: true).dig(:files, 0, :offenses)
      end

      private

      BASENAME = ["source", ".rb"].freeze
      def run_standard(text, format:)
        Tempfile.open(BASENAME) do |temp|
          temp.write(text)
          temp.flush
          stdout = capture_rubocop_stdout(make_config(temp.path, format))
          format ? File.read(temp.path) : stdout
        end
      end

      def make_config(file, format)
        # Can't make frozen versions of this hash because RuboCop mutates it
        o = if format
          {autocorrect: true, formatters: [["Standard::Formatter", nil]], parallel: true, todo_file: nil, todo_ignore_files: [], safe_autocorrect: true}
        else
          {autocorrect: false, formatters: [["json"]], parallel: true, todo_file: nil, todo_ignore_files: [], format: "json"}
        end
        Standard::Config.new(@template_options.runner, [file], o, @template_options.rubocop_config_store)
      end

      def capture_rubocop_stdout(config)
        redir = StringIO.new
        $stdout = redir
        @runner.call(config)
        redir.string
      ensure
        $stdout = STDOUT
      end
    end
  end
end
