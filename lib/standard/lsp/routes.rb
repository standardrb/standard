require_relative "kills_server"

module Standard
  module Lsp
    class Routes
      def initialize(writer, logger, standardizer)
        @writer = writer
        @logger = logger
        @standardizer = standardizer

        @text_cache = {}
        @kills_server = KillsServer.new
      end

      def self.handle(name, &block)
        define_method(:"handle_#{name}", &block)
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
            text_document_sync: Proto::Interface::TextDocumentSyncOptions.new(
              change: Proto::Constant::TextDocumentSyncKind::FULL,
              open_close: true
            )
          )
        ))
      end

      handle "initialized" do |request|
        @logger.puts "Standard Ruby v#{Standard::VERSION} LSP server initialized, pid #{Process.pid}"
      end

      handle "shutdown" do |request|
        @logger.puts "Client asked to shutdown Standard LSP server."
        @kills_server.call do
          @writer.write(id: request[:id], result: nil)
          @logger.puts "Exiting..."
        end
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

      handle "workspace/didChangeConfiguration" do |_request|
        @logger.puts "Ignoring workspace/didChangeConfiguration"
      end

      CONFIGURATION_FILE_PATTERNS = [
        ".standard.yml",
        ".standard_todo.yml"
      ].freeze

      handle "workspace/didChangeWatchedFiles" do |request|
        if request[:params][:changes].any? { |change|
          CONFIGURATION_FILE_PATTERNS.any? { |path| change[:uri].end_with?(path) }
        }
          @logger.puts "Configuration file changed; restart required"
          @kills_server.call
        end
      end

      handle "workspace/executeCommand" do |request|
        if request[:params][:command] == "standardRuby.formatAutoFixes"
          uri = request[:params][:arguments][0][:uri]
          @writer.write({
            id: request[:id],
            method: "workspace/applyEdit",
            params: {
              label: "Format with Standard Ruby auto-fixes",
              edit: {
                changes: {
                  uri => format_file(uri)
                }
              }
            }
          })
        else
          handle_unsupported_method(request, request[:params][:command])
        end
      end

      handle "textDocument/didSave" do |_request|
        # Nothing to do
      end

      handle "$/cancelRequest" do |_request|
        # Can't cancel anything because single-threaded
      end

      handle "$/setTrace" do |_request|
        # No-op, we log everything
      end

      def handle_unsupported_method(request, method = request[:method])
        @writer.write({id: request[:id], error: Proto::Interface::ResponseError.new(
          code: Proto::Constant::ErrorCodes::METHOD_NOT_FOUND,
          message: "Unsupported Method: #{method}"
        )})
        @logger.puts "Unsupported Method: #{method}"
      end

      def handle_method_missing(request)
        if request.key?(:id)
          @writer.write({id: request[:id], result: nil})
        end
      end

      private

      def uri_to_path(uri)
        uri.sub(%r{^file://}, "")
      end

      def format_file(file_uri)
        text = @text_cache[file_uri]
        if text.nil?
          @logger.puts "Format request arrived before text synchonized; skipping: `#{file_uri}'"
          []
        else
          new_text = @standardizer.format(uri_to_path(file_uri), text)
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

        {
          method: "textDocument/publishDiagnostics",
          params: {
            uri: file_uri,
            diagnostics: @standardizer.offenses(uri_to_path(file_uri), text)
          }
        }
      end
    end
  end
end
