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
      yaml_path = @parses_cli_option.call(argv, "--config") ||
        FileFinder.new.call(".standard.yml", search_path)

      # Check for the todo file.  If found merge with standard config file.
      todo_yaml_path = @parses_cli_option.call(argv, "--todo") ||
        FileFinder.new.call(".standard_todo.yml", search_path)

      standard_yaml = load_standard_yaml(yaml_path)
      todo_yaml = load_standard_yaml(todo_yaml_path)

      standard_yaml.merge!(todo_yaml)
      construct_config(yaml_path, standard_yaml)
    end

    private

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
