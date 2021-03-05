require "rubocop"

module Standard
  module Runners
    class Rubocop
      def call(config)
        rubocop_runner = RuboCop::CLI::Command::ExecuteRunner.new(
          RuboCop::CLI::Environment.new(
            config.rubocop_options,
            config.rubocop_config_store,
            config.paths
          )
        )

        rubocop_runner.run
      end
    end
  end
end
