module Standard
  module Lsp
    class Logger
      def initialize
        @puts_onces = []
      end

      def puts(message)
        warn("[server] #{message}")
      end

      def puts_once(message)
        return if @puts_onces.include?(message)
        @puts_onces << message
        puts(message)
      end
    end
  end
end
