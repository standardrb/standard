require_relative "config"

module Standard
  class Cli
    SUCCESS_STATUS_CODE = 0
    FAILURE_STATUS_CODE = 1

    def initialize(argv)
      @config = Config.new(argv)
    end

    def run
      rubocop_config = @config.to_rubocop
      runner = RuboCop::Runner.new(
        rubocop_config.options,
        rubocop_config.config_store
      )

      run_succeeded = runner.run(rubocop_config.paths)

      if run_succeeded
        SUCCESS_STATUS_CODE
      else
        (runner.warnings + runner.errors).each do |message|
          warn message
        end
        puts <<~CALL_TO_ACTION

          Notice: Disagree with these rules? While StandardRB is pre-1.0.0, feel free to submit suggestions to:
            https://github.com/testdouble/standard/issues/new
        CALL_TO_ACTION
        FAILURE_STATUS_CODE
      end
    end
  end
end
