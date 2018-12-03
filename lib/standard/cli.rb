require_relative "builds_config"
require_relative "loads_runner"

module Standard
  class Cli
    SUCCESS_STATUS_CODE = 0
    FAILURE_STATUS_CODE = 1

    def initialize(argv)
      @argv = argv
      @builds_config = BuildsConfig.new
      @loads_runner = LoadsRunner.new
    end

    def run
      config = @builds_config.call(@argv)

      success = @loads_runner.call(config.runner).call(config)

      success ? SUCCESS_STATUS_CODE : FAILURE_STATUS_CODE
    end
  end
end
