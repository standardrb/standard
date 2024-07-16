module Standard
  module Lsp
    class Diagnostic
      Constant = LanguageServer::Protocol::Constant
      Interface = LanguageServer::Protocol::Interface

      RUBOCOP_TO_LSP_SEVERITY = {
        info: Constant::DiagnosticSeverity::HINT,
        refactor: Constant::DiagnosticSeverity::INFORMATION,
        convention: Constant::DiagnosticSeverity::INFORMATION,
        warning: Constant::DiagnosticSeverity::WARNING,
        error: Constant::DiagnosticSeverity::ERROR,
        fatal: Constant::DiagnosticSeverity::ERROR
      }.freeze

      def initialize(document_encoding, offense, uri, cop_class)
        @document_encoding = document_encoding
        @offense = offense
        @uri = uri
        @cop_class = cop_class
      end

      def to_lsp_code_actions
        code_actions = []

        code_actions << autocorrect_action if correctable?
        code_actions << disable_line_action

        code_actions
      end

      def to_lsp_diagnostic(config)
        highlighted = @offense.highlighted_area
        Interface::Diagnostic.new(
          message: message,
          source: "Standard Ruby",
          code: @offense.cop_name,
          code_description: code_description(config),
          severity: severity,
          range: Interface::Range.new(
            start: Interface::Position.new(
              line: @offense.line - 1,
              character: highlighted.begin_pos
            ),
            end: Interface::Position.new(
              line: @offense.line - 1,
              character: highlighted.end_pos
            )
          ),
          data: {
            correctable: correctable?,
            code_actions: to_lsp_code_actions
          }
        )
      end

      private

      def message
        message = @offense.message
        message += "\n\nThis offense is not auto-correctable.\n" unless correctable?
        message
      end

      def severity
        RUBOCOP_TO_LSP_SEVERITY[@offense.severity.name]
      end

      def code_description(config)
        return unless @cop_class

        if (doc_url = @cop_class.documentation_url(config))
          Interface::CodeDescription.new(href: doc_url)
        end
      end

      def autocorrect_action
        Interface::CodeAction.new(
          title: "Autocorrect #{@offense.cop_name}",
          kind: Constant::CodeActionKind::QUICK_FIX,
          edit: Interface::WorkspaceEdit.new(
            document_changes: [
              Interface::TextDocumentEdit.new(
                text_document: Interface::OptionalVersionedTextDocumentIdentifier.new(
                  uri: ensure_uri_scheme(@uri.to_s).to_s,
                  version: nil
                ),
                edits: correctable? ? offense_replacements : []
              )
            ]
          ),
          is_preferred: true
        )
      end

      def offense_replacements
        @offense.corrector.as_replacements.map do |range, replacement|
          Interface::TextEdit.new(
            range: Interface::Range.new(
              start: Interface::Position.new(line: range.line - 1, character: range.column),
              end: Interface::Position.new(line: range.last_line - 1, character: range.last_column)
            ),
            new_text: replacement
          )
        end
      end

      def disable_line_action
        Interface::CodeAction.new(
          title: "Disable #{@offense.cop_name} for this line",
          kind: Constant::CodeActionKind::QUICK_FIX,
          edit: Interface::WorkspaceEdit.new(
            document_changes: [
              Interface::TextDocumentEdit.new(
                text_document: Interface::OptionalVersionedTextDocumentIdentifier.new(
                  uri: ensure_uri_scheme(@uri.to_s).to_s,
                  version: nil
                ),
                edits: line_disable_comment
              )
            ]
          )
        )
      end

      def line_disable_comment
        new_text = if @offense.source_line.include?(" # standard:disable ")
          ",#{@offense.cop_name}"
        else
          " # standard:disable #{@offense.cop_name}"
        end

        eol = Interface::Position.new(
          line: @offense.line - 1,
          character: length_of_line(@offense.source_line)
        )

        # TODO: fails for multiline strings - may be preferable to use block
        # comments to disable some offenses
        inline_comment = Interface::TextEdit.new(
          range: Interface::Range.new(start: eol, end: eol),
          new_text: new_text
        )

        [inline_comment]
      end

      def length_of_line(line)
        if @document_encoding == Encoding::UTF_16LE
          line_length = 0
          line.codepoints.each do |codepoint|
            line_length += 1
            if codepoint > RubyLsp::Document::Scanner::SURROGATE_PAIR_START
              line_length += 1
            end
          end
          line_length
        else
          line.length
        end
      end

      def correctable?
        !@offense.corrector.nil?
      end

      def ensure_uri_scheme(uri)
        uri = URI.parse(uri)
        uri.scheme = "file" if uri.scheme.nil?
        uri
      end
    end
  end
end
