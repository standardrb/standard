require "pathname"

class Standard::CreatesConfigStore
  class AssignsRubocopYaml
    def call(config_store, standard_config)
      config_store.options_config = rubocop_yaml_path(standard_config[:ruby_version])
      config_store.instance_variable_get("@options_config")
    end

    private

    def rubocop_yaml_path(desired_version)
      file_name = if desired_version < Gem::Version.new("1.9")
        "ruby-1.8.yml"
      elsif desired_version < Gem::Version.new("2.0")
        "ruby-1.9.yml"
      elsif desired_version < Gem::Version.new("2.3")
        "ruby-2.2.yml"
      elsif desired_version < Gem::Version.new("2.4")
        "ruby-2.3.yml"
      elsif desired_version < Gem::Version.new("2.6")
        "ruby-2.5.yml"
      elsif desired_version < Gem::Version.new("3.0")
        "ruby-2.7.yml"
      else
        "base.yml"
      end

      Pathname.new(__dir__).join("../../../config/#{file_name}")
    end
  end
end
