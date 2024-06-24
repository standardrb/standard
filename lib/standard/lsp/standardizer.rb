require_relative "stdin_rubocop_runner"
require_relative "diagnostic"

module Standard
  module Lsp
    class Standardizer
      def initialize(config)
        @diagnostic_runner = ::Standard::Lsp::StdinRubocopRunner.new(config)
        @format_runner = ::Standard::Lsp::StdinRubocopRunner.new(config.dup.tap { |c|
          c.rubocop_options[:autocorrect] = true
        })
        @cop_registry = RuboCop::Cop::Registry.global.to_h
      end

      def format(path, text)
        @format_runner.run(path, text)
        @format_runner.formatted_source
      end

      def offenses(path, text, document_encoding = nil)
        @diagnostic_runner.run(path, text)

        @diagnostic_runner.offenses.map do |offense|
          Diagnostic.new(
            document_encoding,
            offense,
            path,
            @cop_registry[offense.cop_name]&.first
          ).to_lsp_diagnostic(@diagnostic_runner.config_for_working_directory)
        end
      end
    end
  end
end
