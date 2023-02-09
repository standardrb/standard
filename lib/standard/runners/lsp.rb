require_relative "../lsp/server"

module Standard
  module Runners
    class Lsp
      def call(config)
        standardizer = Standard::Lsp::Standardizer.new(config)
        Standard::Lsp::Server.start(standardizer)
      end
    end
  end
end
