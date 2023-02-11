require_relative "../lsp/server"

module Standard
  module Runners
    class Lsp
      def call(config)
        Standard::Lsp::Server.new(config).start
      end
    end
  end
end
