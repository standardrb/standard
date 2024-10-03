module Standard
  module Lsp
    # Originally lifted from:
    # https://github.com/Shopify/ruby-lsp/blob/8d4c17efce4e8ecc8e7c557ab2981db6b22c0b6d/lib/ruby_lsp/requests/support/rubocop_runner.rb#L20
    class StdinRubocopRunner < ::RuboCop::Runner
      class ConfigurationError < StandardError; end

      attr_reader :offenses

      attr_reader :config_for_working_directory

      DEFAULT_RUBOCOP_OPTIONS = {
        stderr: true,
        force_exclusion: true,
        formatters: ["RuboCop::Formatter::BaseFormatter"],
        raise_cop_error: true,
        todo_file: nil,
        todo_ignore_files: []
      }.freeze

      def initialize(config)
        @options = {}
        @offenses = []
        @errors = []
        @warnings = []

        @config_for_working_directory = config.rubocop_config_store.for_pwd

        super(
          config.rubocop_options.merge(DEFAULT_RUBOCOP_OPTIONS),
          config.rubocop_config_store
        )
      end

      def run(path, contents)
        @errors = []
        @warnings = []
        @offenses = []
        @options[:stdin] = contents

        super([path])

        raise Interrupt if aborting?
      rescue ::RuboCop::Runner::InfiniteCorrectionLoop => error
        if defined?(::RubyLsp::Requests::Formatting::Error)
          raise ::RubyLsp::Requests::Formatting::Error, error.message
        else
          raise error
        end
      rescue ::RuboCop::ValidationError => error
        raise ConfigurationError, error.message
      rescue => error
        if defined?(::RubyLsp::Requests::Formatting::Error)
          raise ::RubyLsp::Requests::Support::InternalRuboCopError, error
        else
          raise error
        end
      end

      def formatted_source
        @options[:stdin]
      end

      private

      def file_finished(_file, offenses)
        @offenses = offenses
      end
    end
  end
end
