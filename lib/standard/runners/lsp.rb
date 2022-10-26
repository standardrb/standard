require_relative "../lsp/server"

module Standard
  module Runners
    class Lsp
      def call(config)
        standardizer = Standard::LSP::Standardizer.new(config)
        Standard::LSP::Server.start(standardizer)
      end
    end
  end
end
