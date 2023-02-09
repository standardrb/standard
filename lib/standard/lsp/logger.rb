module Standard
  module Lsp
    class Logger
      def puts(message)
        warn("[server] #{message}")
      end
    end
  end
end
