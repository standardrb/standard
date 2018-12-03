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
            print_call_for_feedback
          end
        end
      end

      private

      def print_errors_and_warnings(rubocop_runner)
        (rubocop_runner.warnings + rubocop_runner.errors).each do |message|
          warn message
        end
      end

      def print_call_for_feedback
        puts <<-CALL_TO_ACTION.gsub(/^ {10}/, "")

          Notice: Disagree with these rules? While StandardRB is pre-1.0.0, feel free to submit suggestions to:
            https://github.com/testdouble/standard/issues/new
        CALL_TO_ACTION
      end
    end
  end
end
