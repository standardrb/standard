require "rubocop"
require_relative "config"
require_relative "timer"

module Standard
  class Cli
    SUCCESS_STATUS_CODE = 0
    FAILURE_STATUS_CODE = 1

    def initialize
      @config = Config.new(ARGV)
      @timer = Timer.new
    end

    def run
      rubocop_config = @config.to_rubocop
      runner = RuboCop::Runner.new(
        rubocop_config.options,
        rubocop_config.config_store
      )

      time, run_succeeded = @timer.time {
        runner.run(rubocop_config.paths)
      }

      if run_succeeded
        puts "✨  Done in #{time.round(2)}s."
        SUCCESS_STATUS_CODE
      else
        runner.warnings.each { |warning| warn warning }
        print_errors(runner.errors)
        FAILURE_STATUS_CODE
      end
    end

    private

    # See: https://github.com/rubocop-hq/rubocop/blob/master/lib/rubocop/cli.rb#L263
    def print_errors(errors)
      return if errors.empty?

      errors.each { |error| warn error }

      warn <<~WARNING
        Errors are usually caused by RuboCop bugs.
        Please, report your problems to RuboCop's issue tracker.
        #{Gem.loaded_specs['rubocop'].metadata['bug_tracker_uri']}
        Mention the following information in the issue report:
        #{RuboCop::Version.version(true)}
      WARNING
    end
  end
end
