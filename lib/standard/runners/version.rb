module Standard
  module Runners
    class Version
      def call(config)
        puts Standard::VERSION
      end
    end
  end
end
