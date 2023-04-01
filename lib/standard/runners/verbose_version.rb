require_relative "rubocop"

module Standard
  module Runners
    class VerboseVersion
      def call(config)
        puts <<~MSG
          Standard version: #{Standard::VERSION}
          RuboCop version:  #{RuboCop::Version.version(debug: true)}
        MSG
      end
    end
  end
end
