require_relative "builds_config"
require_relative "loads_runner"
require_relative "prints_big_hairy_version_warning"

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
      PrintsBigHairyVersionWarning.new.call
      exit 1
    end
  end
end
