class Standard::CreatesConfigStore
  class SetsTargetRubyVersion
    # This is minimum version that Rubocop can parse, not the minimum
    # version it can run on (e.g. TargetRubyVersion).  See the following
    # for more details:
    #
    # https://docs.rubocop.org/rubocop/configuration.html#setting-the-target-ruby-version
    #
    # https://github.com/rubocop/rubocop/blob/master/lib/rubocop/target_ruby.rb
    MIN_TARGET_RUBY_VERSION = "2.0"

    def call(options_config, standard_config)
      options_config["AllCops"]["TargetRubyVersion"] = normalize_version(
        min_target_ruby_version_supported(standard_config[:ruby_version])
      )
    end

    private

    def min_target_ruby_version_supported(desired_target_ruby_version)
      return desired_target_ruby_version unless Gem::Version.correct?(desired_target_ruby_version)

      min_target_ruby_version = Gem::Version.new(MIN_TARGET_RUBY_VERSION)
      if desired_target_ruby_version < min_target_ruby_version
        min_target_ruby_version
      else
        desired_target_ruby_version
      end
    end

    def normalize_version(version)
      return version unless Gem::Version.correct?(version)

      major, minor = version.segments
      "#{major}.#{minor}".to_f # lol
    end
  end
end
