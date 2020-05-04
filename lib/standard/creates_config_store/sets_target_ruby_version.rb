class Standard::CreatesConfigStore
  class SetsTargetRubyVersion
    def call(options_config, standard_config)
      options_config["AllCops"]["TargetRubyVersion"] = floatify_version(
        max_rubocop_supported_version(standard_config[:ruby_version])
      )
    end

    private

    def max_rubocop_supported_version(desired_version)
      rubocop_supported_version = Gem::Version.new("2.4")
      if desired_version < rubocop_supported_version
        rubocop_supported_version
      else
        desired_version
      end
    end

    def floatify_version(version)
      major, minor = version.segments
      "#{major}.#{minor}".to_f # lol
    end
  end
end
