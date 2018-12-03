require_relative "config"
require_relative "runner"

module Standard
  class Cli
    SUCCESS_STATUS_CODE = 0
    FAILURE_STATUS_CODE = 1

    def initialize(argv)
      @argv = argv
      @config = Config.new
      @runner = Runner.new
    end

    def run
      config = @config.call(@argv)

      success = @runner.call(config)

      success ? SUCCESS_STATUS_CODE : FAILURE_STATUS_CODE
    end
  end
end
