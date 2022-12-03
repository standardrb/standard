require "language_server-protocol"
require_relative "standardizer"

module Standard
  module LSP
    class Server
      Proto = LanguageServer::Protocol
      SEV = Proto::Constant::DiagnosticSeverity

      def self.start(standardizer)
        new(standardizer).start
      end

      attr_accessor :standardizer, :writer, :reader, :logger, :text_cache, :subscribers

      def initialize(standardizer)
        self.standardizer = standardizer
        self.writer = Proto::Transport::Io::Writer.new($stdout)
        self.reader = Proto::Transport::Io::Reader.new($stdin)
        self.logger = $stderr
        self.text_cache = {}

        self.subscribers = {
          "initialize" => ->(request) {
            init_result = Proto::Interface::InitializeResult.new(
              capabilities: Proto::Interface::ServerCapabilities.new(
                document_formatting_provider: true,
                diagnostic_provider: true,
                text_document_sync: Proto::Constant::TextDocumentSyncKind::FULL
              )
            )
            writer.write(id: request[:id], result: init_result)
          },

          "initialized" => ->(request) { logger.puts "standard v#{Standard::VERSION} initialized, pid #{Process.pid}" },

          "shutdown" => ->(request) {
            logger.puts "asked to shutdown, exiting..."
            exit
          },

          "textDocument/didChange" => ->(request) {
            params = request[:params]
            result = diagnostic(params[:textDocument][:uri], params[:contentChanges][0][:text])
            writer.write(result)
          },

          "textDocument/didOpen" => ->(request) {
            td = request[:params][:textDocument]
            result = diagnostic(td[:uri], td[:text])
            writer.write(result)
          },

          "textDocument/didClose" => ->(request) {
            text_cache.delete(request.dig(:params, :textDocument, :uri))
          },

          "textDocument/formatting" => ->(request) {
            uri = request[:params][:textDocument][:uri]
            writer.write({id: request[:id], result: format_file(uri)})
          },

          "textDocument/didSave" => ->(request) {}
        }
      end

      def start
        reader.read do |request|
          method = request[:method]
          if (subscriber = subscribers[method])
            subscriber.call(request)
          else
            logger.puts "unknown method: #{method}"
          end
        rescue => e
          logger.puts "error #{e.class} #{e.message[0..100]}"
          logger.puts e.backtrace.inspect
        end
      end

      def format_file(file_uri)
        text = text_cache[file_uri]
        new_text = standardizer.format(text)

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

      def diagnostic(file_uri, text)
        text_cache[file_uri] = text
        offenses = standardizer.offenses(text)

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
            logger.puts "unknown severity: #{severity.inspect}"
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
            diagnostics: lsp_diagnostics,
            uri: file_uri
          }
        }
      end
    end
  end
end
