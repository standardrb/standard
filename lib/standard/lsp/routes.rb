module Standard
  module Lsp
    class Routes
      def initialize(writer, logger, standardizer)
        @writer = writer
        @logger = logger
        @standardizer = standardizer

        @text_cache = {}
      end

      def self.handle(name, &block)
        define_method("handle_#{name}", &block)
      end

      def for(name)
        name = "handle_#{name}"
        if respond_to?(name)
          method(name)
        end
      end

      handle "initialize" do |request|
        @writer.write(id: request[:id], result: Proto::Interface::InitializeResult.new(
          capabilities: Proto::Interface::ServerCapabilities.new(
            document_formatting_provider: true,
            diagnostic_provider: true,
            execute_command_provider: true,
            text_document_sync: Proto::Interface::TextDocumentSyncOptions.new(
              change: Proto::Constant::TextDocumentSyncKind::FULL
            )
          )
        ))
      end

      handle "initialized" do |request|
        @logger.puts "Standard Ruby v#{Standard::VERSION} LSP server initialized, pid #{Process.pid}"
      end

      handle "shutdown" do |request|
        @logger.puts "Client asked to shutdown Standard LSP server. Exiting..."
        at_exit {
          @writer.write(id: request[:id], result: nil)
        }
        exit 0
      end

      handle "textDocument/diagnostic" do |request|
        doc = request[:params][:textDocument]
        result = diagnostic(doc[:uri], doc[:text])
        @writer.write(result)
      end

      handle "textDocument/didChange" do |request|
        params = request[:params]
        result = diagnostic(params[:textDocument][:uri], params[:contentChanges][0][:text])
        @writer.write(result)
      end

      handle "textDocument/didOpen" do |request|
        doc = request[:params][:textDocument]
        result = diagnostic(doc[:uri], doc[:text])
        @writer.write(result)
      end

      handle "textDocument/didClose" do |request|
        @text_cache.delete(request.dig(:params, :textDocument, :uri))
      end

      handle "textDocument/formatting" do |request|
        uri = request[:params][:textDocument][:uri]
        @writer.write({id: request[:id], result: format_file(uri)})
      end

      handle "workspace/didChangeWatchedFiles" do |request|
        @logger.puts "Configuration file changed; restart required"
        exit 0
      end

      handle "workspace/executeCommand" do |request|
        if request[:params][:command] == "standardRuby.formatAutoFixes"
          uri = request[:params][:arguments][0][:uri]
          changes = format_file(uri)
          if changes.any?
            @writer.write(answer = {
              method: "workspace/applyEdit",
              params: {
                label: "Format with Standard Ruby auto-fixes",
                edit: {
                  changes: {
                    uri => changes
                  }
                }
              }
            })
          end
        end
      end
      handle "textDocument/didSave" do |_request|
        # No-op
      end

      handle "$/cancelRequest" do |_request|
        # No-op
      end

      handle "$/setTrace" do |_request|
        # No-op
      end

      private

      def format_file(file_uri)
        text = @text_cache[file_uri]
        if text.nil?
          @logger.puts "Format request arrived before text synchonized; skipping: `#{file_uri}'"
          []
        else
          new_text = @standardizer.format(text)
          if new_text == text
            []
          else
            [{
              newText: new_text,
              range: {
                start: {line: 0, character: 0},
                end: {line: text.count("\n") + 1, character: 0}
              }
            }]
          end
        end
      end

      def diagnostic(file_uri, text)
        @text_cache[file_uri] = text
        offenses = @standardizer.offenses(text)

        lsp_diagnostics = offenses.map { |o|
          code = o[:cop_name]

          msg = o[:message].delete_prefix(code)
          loc = o[:location]

          severity = case o[:severity]
          when "error", "fatal"
            SEV::ERROR
          when "warning"
            SEV::WARNING
          when "convention"
            SEV::INFORMATION
          when "refactor", "info"
            SEV::HINT
          else # the above cases fully cover what RuboCop sends at this time
            logger.puts "Unknown severity: #{severity.inspect}"
            SEV::HINT
          end

          {
            code: code,
            message: msg,
            range: {
              start: {character: loc[:start_column] - 1, line: loc[:start_line] - 1},
              end: {character: loc[:last_column] - 1, line: loc[:last_line] - 1}
            },
            severity: severity,
            source: "standard"
          }
        }

        {
          method: "textDocument/publishDiagnostics",
          params: {
            uri: file_uri,
            diagnostics: lsp_diagnostics
          }
        }
      end
    end
  end
end
