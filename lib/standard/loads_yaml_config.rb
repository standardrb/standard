require "yaml"
require "pathname"
require_relative "file_finder"
require_relative "resolves_yaml_option"

module Standard
  class LoadsYamlConfig
    def call(standard_yaml_path, todo_yaml_path)
      standard_yaml = load_standard_yaml(standard_yaml_path)
      todo_yaml = load_standard_yaml(todo_yaml_path)

      construct_config(standard_yaml_path, standard_yaml, todo_yaml_path, todo_yaml)
    end

    private

    def load_standard_yaml(yaml_path)
      if yaml_path
        YAML.load_file(yaml_path) || {}
      else
        {}
      end
    end

    def construct_config(yaml_path, standard_yaml, todo_path, todo_yaml)
      {
        ruby_version: normalized_ruby_version(standard_yaml["ruby_version"]),
        fix: !!standard_yaml["fix"],
        format: standard_yaml["format"],
        parallel: !!standard_yaml["parallel"],
        ignore: expand_ignore_config(standard_yaml["ignore"]) + expand_ignore_config(todo_yaml["ignore"]),
        default_ignores: standard_yaml.key?("default_ignores") ? !!standard_yaml["default_ignores"] : true,
        config_root: yaml_path ? Pathname.new(yaml_path).dirname.to_s : nil,
        todo_file: todo_path,
        todo_ignore_files: Array(todo_yaml["ignore"]).map { |f| (Hash === f) ? f.keys.first : f },
        plugins: Array(standard_yaml["plugins"]),
        extend_config: Array(standard_yaml["extend_config"])
      }
    end

    def normalized_ruby_version(version)
      return version if version && !Gem::Version.correct?(version)

      Gem::Version.new(version || RUBY_VERSION)
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
