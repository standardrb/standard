require "rubocop"
require "pathname"

module Standard
  class CreatesConfigStore
    def call(standard_config)
      config_store = RuboCop::ConfigStore.new
      config_store.options_config = rubocop_yaml_path(standard_config[:ruby_version])
      options_config = config_store.instance_variable_get("@options_config")

      options_config["AllCops"]["TargetRubyVersion"] = floatify_version(
        max_rubocop_supported_version(standard_config[:ruby_version])
      )

      standard_config[:ignore].each do |(path, cops)|
        cops.each do |cop|
          options_config[cop] ||= {}
          options_config[cop]["Exclude"] ||= []
          options_config[cop]["Exclude"] |= [
            Pathname.new(standard_config[:config_root]).join(path).to_s,
          ]
        end
      end

      config_store
    end

    private

    def rubocop_yaml_path(desired_version)
      file_name = if desired_version < Gem::Version.new("1.9")
        "ruby-1.8.yml"
      elsif desired_version < Gem::Version.new("2.0")
        "ruby-1.9.yml"
      elsif desired_version < Gem::Version.new("2.3")
        "ruby-2.2.yml"
      else
        "base.yml"
      end

      Pathname.new(__dir__).join("../../config/#{file_name}")
    end

    def max_rubocop_supported_version(desired_version)
      rubocop_supported_version = Gem::Version.new("2.2")
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
