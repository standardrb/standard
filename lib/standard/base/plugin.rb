module Standard::Base
  class Plugin < LintRoller::Plugin
    def initialize(config)
      @config = config
    end

    def about
      LintRoller::About.new(
        name: "standard-base",
        version: VERSION,
        homepage: "https://github.com/standardrb/standard",
        description: "Configuration for RuboCop's built-in rules"
      )
    end

    def supported?(context)
      true
    end

    def rules(context)
      LintRoller::Rules.new(
        type: :path,
        config_format: :rubocop,
        value: determine_yaml_path(context.target_ruby_version)
      )
    end

    private

    def determine_yaml_path(desired_version)
      desired_version = Gem::Version.new(desired_version) unless desired_version.is_a?(Gem::Version)
      default = "base.yml"

      file_name = if !Gem::Version.correct?(desired_version)
        default
      elsif desired_version < Gem::Version.new("1.9")
        "ruby-1.8.yml"
      elsif desired_version < Gem::Version.new("2.0")
        "ruby-1.9.yml"
      elsif desired_version < Gem::Version.new("2.1")
        "ruby-2.0.yml"
      elsif desired_version < Gem::Version.new("2.2")
        "ruby-2.1.yml"
      elsif desired_version < Gem::Version.new("2.3")
        "ruby-2.2.yml"
      elsif desired_version < Gem::Version.new("2.4")
        "ruby-2.3.yml"
      elsif desired_version < Gem::Version.new("2.5")
        "ruby-2.4.yml"
      elsif desired_version < Gem::Version.new("2.6")
        "ruby-2.5.yml"
      elsif desired_version < Gem::Version.new("3.0")
        "ruby-2.7.yml"
      elsif desired_version < Gem::Version.new("3.1")
        "ruby-3.0.yml"
      elsif desired_version < Gem::Version.new("3.2")
        "ruby-3.1.yml"
      elsif desired_version < Gem::Version.new("3.3")
        "ruby-3.2.yml"
      elsif desired_version < Gem::Version.new("3.4")
        "ruby-3.3.yml"
      else
        default
      end

      Pathname.new(__dir__).join("../../../config/#{file_name}")
    end
  end
end
