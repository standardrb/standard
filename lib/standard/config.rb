require "rubocop"
require "pathname"
require "yaml"
require_relative "file_finder"
require_relative "formatter"

module Standard
  class Config
    RuboCopConfig = Struct.new(:paths, :options, :config_store)

    def initialize
    end

    def call(argv, search_path = Dir.pwd)
      filtered_argv, fix_flag = parse_argv(argv)
      @rubocop_options, @paths = RuboCop::Options.new.parse(filtered_argv)
      @standard_yml_path = FileFinder.new.call(".standard.yml", search_path)
      @standard_config = init_standard_config(@standard_yml_path, fix_flag)
      RuboCopConfig.new(
        @paths,
        wrap_rubocop_options(@rubocop_options),
        RuboCop::ConfigStore.new.tap(&method(:mutate_config_store!))
      )
    end

    private

    # Filtered b/c RuboCop will switch to --only Layout when --fix is set (undocumented behavior)
    def parse_argv(argv)
      filtered_argv = argv.dup
      fix_flag = !!filtered_argv.delete("--fix")
      [filtered_argv, fix_flag]
    end

    def init_standard_config(yml_path, fix_flag)
      standard_yml = YAML.load_file(yml_path) if yml_path
      standard_yml ||= {}

      {
        ruby_version: ruby_version(standard_yml["ruby_version"] || RUBY_VERSION),
        fix: fix_flag || !!standard_yml["fix"],
        format: standard_yml["format"],
        parallel: !!standard_yml["parallel"],
        ignore: expand_ignore_config(standard_yml["ignore"]),
      }
    end

    def wrap_rubocop_options(rubocop_options)
      {
        auto_correct: @standard_config[:fix],
        safe_auto_correct: @standard_config[:fix],
        formatters: [[@standard_config[:format] || "Standard::Formatter", nil]],
        parallel: @standard_config[:parallel],
      }.merge(rubocop_options)
    end

    def mutate_config_store!(config_store)
      config_store.options_config = rubocop_yaml_path(@standard_config[:ruby_version])
      options_config = config_store.instance_variable_get("@options_config")

      options_config["AllCops"]["TargetRubyVersion"] = floatify_version(
        max_rubocop_supported_version(@standard_config[:ruby_version])
      )

      @standard_config[:ignore].each do |(path, cops)|
        cops.each do |cop|
          options_config[cop] ||= {}
          options_config[cop]["Exclude"] ||= []
          options_config[cop]["Exclude"] |= [Pathname.new(@standard_yml_path).dirname.join(path).to_s]
        end
      end
    end

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

    def expand_ignore_config(ignore_config)
      arrayify(ignore_config).map { |rule|
        if rule.is_a?(String)
          [rule, ["AllCops"]]
        elsif rule.is_a?(Hash)
          rule.entries.first
        end
      }
    end

    def ruby_version(version)
      Gem::Version.new(version)
    end

    def floatify_version(version)
      major, minor = version.segments
      "#{major}.#{minor}".to_f # lol
    end

    def max_rubocop_supported_version(desired_version)
      rubocop_supported_version = Gem::Version.new("2.2")
      if desired_version < rubocop_supported_version
        rubocop_supported_version
      else
        desired_version
      end
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
