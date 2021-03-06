require_relative "builds_config"
require_relative "loads_runner"

module Standard
  class Cli
    def initialize(argv)
      @argv = argv
      @builds_config = BuildsConfig.new
      @loads_runner = LoadsRunner.new
    end

    def run
      config = @builds_config.call(@argv)
      @loads_runner.call(config.runner).call(config).to_i
    end
  end
end
