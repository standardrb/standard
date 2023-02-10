module Standard
  module Lsp
    class KillsServer
      def call(&blk)
        at_exit(&blk) unless blk.nil?
        exit 0
      end
    end
  end
end
