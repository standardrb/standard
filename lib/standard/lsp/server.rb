require "language_server-protocol"
require_relative "standardizer"
require_relative "routes"

module Standard
  module Lsp
    Proto = LanguageServer::Protocol
    SEV = Proto::Constant::DiagnosticSeverity

    class Server
      def self.start(standardizer)
        new(standardizer).start
      end

      def initialize(standardizer)
        @standardizer = standardizer
        @writer = Proto::Transport::Io::Writer.new($stdout)
        @reader = Proto::Transport::Io::Reader.new($stdin)
        @logger = $stderr
        @routes = Routes.new(@writer, @logger, @standardizer)
      end

      def start
        @reader.read do |request|
          method = request[:method]
          if (route = @routes.for(method))
            route.call(request)
          else
            @writer.write({id: request[:id], error: Proto::Interface::ResponseError.new(
              code: Proto::Constant::ErrorCodes::METHOD_NOT_FOUND,
              message: "Unsupported Method: #{method}"
            )})
            @logger.puts "Unsupported Method: #{method}"
          end
        rescue => e
          @logger.puts "Error #{e.class} #{e.message[0..100]}"
          @logger.puts e.backtrace.inspect
        end
      end
    end
  end
end
