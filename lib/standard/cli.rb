require_relative "builds_config"
require_relative "runs_rubocop"

module Standard
  class Cli
    SUCCESS_STATUS_CODE = 0
    FAILURE_STATUS_CODE = 1

    def initialize(argv)
      @argv = argv
      @builds_config = BuildsConfig.new
      @runs_rubocop = RunsRubocop.new
    end

    def run
      config = @builds_config.call(@argv)

      success = @runs_rubocop.call(config)

      success ? SUCCESS_STATUS_CODE : FAILURE_STATUS_CODE
    end
  end
end
