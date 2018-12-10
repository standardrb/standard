require "pathname"

module Standard
  class ParsesCliOption
    def call(argv, option_name)
      return unless (config_file = argv_value_for(argv, option_name))

      resolved_config = Pathname.new(config_file)
      if resolved_config.exist?
        resolved_config.expand_path
      else
        raise "Configuration file \"#{resolved_config.expand_path}\" not found."
      end
    end

    def argv_value_for(argv, option_name)
      return unless (index = argv.index(option_name))
      argv[index + 1]
    end
  end
end
