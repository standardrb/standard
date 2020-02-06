require "yaml"
require "pathname"
require_relative "file_finder"
require_relative "parses_cli_option"

module Standard
  class LoadsYamlConfig
    def initialize
      @parses_cli_option = ParsesCliOption.new
    end

    def call(argv, search_path)
      standard_yaml_path = determine_yaml_file(argv, search_path, "--config", ".standard.yml")
      todo_yaml_path = determine_yaml_file(argv, search_path, "--todo", ".standard_todo.yml")

      standard_yaml = load_standard_yaml(standard_yaml_path)
      todo_yaml = load_standard_yaml(todo_yaml_path)

      merge_ignore(standard_yaml, todo_yaml)
      construct_config(standard_yaml_path, standard_yaml)
    end

    private

    def merge_ignore(merge_into_yaml, merge_from_yaml)
      merge_into_yaml["ignore"] = arrayify(merge_into_yaml["ignore"])
      merge_from_yaml["ignore"] = arrayify(merge_from_yaml["ignore"])

      merge_into_yaml["ignore"] = merge_into_yaml["ignore"] + merge_from_yaml["ignore"]
    end

    def determine_yaml_file(argv, search_path, option_name, default_file)
      @parses_cli_option.call(argv, option_name) || FileFinder.new.call(default_file, search_path)
    end

    def load_standard_yaml(yaml_path)
      if yaml_path
        YAML.load_file(yaml_path) || {}
      else
        {}
      end
    end

    def construct_config(yaml_path, standard_yaml)
      {
        ruby_version: Gem::Version.new((standard_yaml["ruby_version"] || RUBY_VERSION)),
        fix: !!standard_yaml["fix"],
        format: standard_yaml["format"],
        parallel: !!standard_yaml["parallel"],
        ignore: expand_ignore_config(standard_yaml["ignore"]),
        default_ignores: standard_yaml.key?("default_ignores") ? !!standard_yaml["default_ignores"] : true,
        config_root: yaml_path ? Pathname.new(yaml_path).dirname.to_s : nil,
      }
    end

    def expand_ignore_config(ignore_config)
      arrayify(ignore_config).map { |rule|
        if rule.is_a?(String)
          [rule, ["AllCops"]]
        elsif rule.is_a?(Hash)
          rule.entries.first
        end
      }
    end

    def arrayify(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end
  end
end
