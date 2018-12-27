require "rubocop"

module Standard
  module Runners
    class Rubocop
      def call(config)
        rubocop_runner = RuboCop::Runner.new(
          config.rubocop_options,
          config.rubocop_config_store
        )

        rubocop_runner.run(config.paths).tap do |success|
          unless success
            print_errors_and_warnings(rubocop_runner)
          end
        end
      end

      private

      def print_errors_and_warnings(rubocop_runner)
        (rubocop_runner.warnings + rubocop_runner.errors).each do |message|
          warn message
        end
      end
    end
  end
end
