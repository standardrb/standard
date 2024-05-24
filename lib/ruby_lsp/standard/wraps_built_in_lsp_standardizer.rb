module RubyLsp
  module Standard
    class WrapsBuiltinLspStandardizer
      include RubyLsp::Requests::Support::Formatter
      def initialize
        init!
      end

      def init!
        @config = ::Standard::BuildsConfig.new.call(ARGV)
        @standardizer = ::Standard::Lsp::Standardizer.new(
          @config,
          ::Standard::Lsp::Logger.new
        )
        @cop_registry = RuboCop::Cop::Registry.global.to_h
      end

      def run_formatting(uri, document)
        @standardizer.format(uri_to_path(uri), document.source)
      end

      def run_diagnostic(uri, document)
        offenses = @standardizer.offenses(uri_to_path(uri), document.source)

        offenses.map { |o|
          cop_name = o[:cop_name]

          msg = o[:message].delete_prefix(cop_name)
          loc = o[:location]

          severity = case o[:severity]
          when "error", "fatal"
            RubyLsp::Constant::DiagnosticSeverity::ERROR
          when "warning"
            RubyLsp::Constant::DiagnosticSeverity::WARNING
          when "convention"
            RubyLsp::Constant::DiagnosticSeverity::INFORMATION
          when "refactor", "info"
            RubyLsp::Constant::DiagnosticSeverity::HINT
          else # the above cases fully cover what RuboCop sends at this time
            logger.puts "Unknown severity: #{severity.inspect}"
            RubyLsp::Constant::DiagnosticSeverity::HINT
          end

          RubyLsp::Interface::Diagnostic.new(
            code: cop_name,
            code_description: code_description(cop_name),
            message: msg,
            source: "Standard Ruby",
            severity: severity,
            range: RubyLsp::Interface::Range.new(
              start: RubyLsp::Interface::Position.new(line: loc[:start_line] - 1, character: loc[:start_column] - 1),
              end: RubyLsp::Interface::Position.new(line: loc[:last_line] - 1, character: loc[:last_column] - 1)
            )
            # TODO: do I need something like this?
            # See: https://github.com/Shopify/ruby-lsp/blob/4c1906172add4d5c39c35d3396aa29c768bfb898/lib/ruby_lsp/requests/support/rubocop_diagnostic.rb#L62
            # data: {
            #   correctable: @offense.correctable?,
            #   code_actions: to_lsp_code_actions
            # }
          )
        }
      end

      private

      # duplicated from: lib/standard/lsp/routes.rb
      def uri_to_path(uri)
        uri.to_s.sub(%r{^file://}, "")
      end

      # lifted from:
      # https://github.com/Shopify/ruby-lsp/blob/4c1906172add4d5c39c35d3396aa29c768bfb898/lib/ruby_lsp/requests/support/rubocop_diagnostic.rb#L84
      def code_description(cop_name)
        if (cop_class = @cop_registry[cop_name]&.first)
          if (doc_url = cop_class.documentation_url)
            Interface::CodeDescription.new(href: doc_url)
          end
        end
      end
    end
  end
end
