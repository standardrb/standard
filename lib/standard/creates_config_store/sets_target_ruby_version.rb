class Standard::CreatesConfigStore
  class SetsTargetRubyVersion
    def call(options_config, standard_config)
      options_config["AllCops"]["TargetRubyVersion"] = normalize_version(
        max_rubocop_supported_version(standard_config[:ruby_version])
      )
    end

    private

    def max_rubocop_supported_version(desired_version)
      return desired_version unless Gem::Version.correct?(desired_version)

      rubocop_supported_version = Gem::Version.new("2.5")
      if desired_version < rubocop_supported_version
        rubocop_supported_version
      else
        desired_version
      end
    end

    def normalize_version(version)
      return version unless Gem::Version.correct?(version)

      major, minor = version.segments
      "#{major}.#{minor}".to_f # lol
    end
  end
end
