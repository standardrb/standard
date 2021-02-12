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
          print_errors_and_warnings(success, rubocop_runner)
          print_corrected_code_if_fixing_stdin(config.rubocop_options)
        end
      end

      private

      def print_errors_and_warnings(success, rubocop_runner)
        return unless success

        (rubocop_runner.warnings + rubocop_runner.errors).each do |message|
          warn message
        end
      end

      def print_corrected_code_if_fixing_stdin(rubocop_options)
        return unless rubocop_options[:stdin] && rubocop_options[:auto_correct]

        if rubocop_options[:stderr]
          warn "=" * 20
        else
          puts "=" * 20
        end
        print rubocop_options[:stdin]
      end
    end
  end
end
