require "rubocop"

module Standard
  module Runners
    class Rubocop
      def call(config)
        rubocop_runner = RuboCop::CLI::Command::ExecuteRunner.new(
          RuboCop::CLI::Environment.new(
            without_parallelizing_in_stdin_mode(config.rubocop_options),
            config.rubocop_config_store,
            config.paths
          )
        )

        rubocop_runner.run
      end

      private

      # This is a workaround for an issue with how `parallel` and `stdin`
      # interact when invoked in this way. See:
      #   https://github.com/standardrb/standard/issues/536
      def without_parallelizing_in_stdin_mode(options)
        if options[:stdin]
          options.delete(:parallel)
        end

        options
      end
    end
  end
end
