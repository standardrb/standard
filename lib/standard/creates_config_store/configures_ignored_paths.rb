require "pathname"

class Standard::CreatesConfigStore
  class ConfiguresIgnoredPaths
    def call(options_config, standard_config)
      ignored_patterns(standard_config).each do |(path, cops)|
        cops.each do |cop|
          options_config[cop] ||= {}
          options_config[cop]["Exclude"] ||= []
          options_config[cop]["Exclude"] |= [
            Pathname.new(standard_config[:config_root]).join(path).to_s,
          ]
        end
      end
    end

    private

    def ignored_patterns(standard_config)
      standard_config[:ignore]
    end
  end
end
