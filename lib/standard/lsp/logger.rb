module Standard
  module Lsp
    class Logger
      def initialize(prefix: "[server]")
        @prefix = prefix
        @puts_onces = []
      end

      def puts(message)
        warn [@prefix, message].compact.join(" ")
      end

      def puts_once(message)
        return if @puts_onces.include?(message)

        @puts_onces << message
        puts(message)
      end
    end
  end
end
