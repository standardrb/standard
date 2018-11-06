require "rubocop"
require "pathname"
require "yaml"
require_relative "file_finder"

module Standard
  class Config
    RuboCopConfig = Struct.new(:paths, :options, :config_store)

    def initialize(argv)
      @rubocop_options, @paths = RuboCop::Options.new.parse(argv)
      @standard_yml_path = FileFinder.new.call(".standard.yml", Dir.pwd)
      @standard_config = init_standard_config(@standard_yml_path)
    end

    def to_rubocop
      RuboCopConfig.new(
        @paths,
        wrap_rubocop_options(@rubocop_options),
        RuboCop::ConfigStore.new.tap(&self.method(:mutate_config_store!))
      )
    end

    private

    def init_standard_config(yml_path)
      user_config = if yml_path
        YAML.load_file(Pathname.new(Dir.pwd).join(yml_path))
      else
        {}
      end

      {
        :fix => !!user_config["fix"],
        :ignore => expand_ignore_config(user_config["ignore"])
      }
    end

    def wrap_rubocop_options(rubocop_options)
      {
        :formatters => [["progress", nil]]
      }.merge(
        :fix_layout => @standard_config[:fix],
        :auto_correct => @standard_config[:fix]
      ).merge(rubocop_options)
    end

    def mutate_config_store!(config_store)
      config_store.options_config = Pathname.new(__dir__).join("../../config/base.yml")
      options_config = config_store.instance_variable_get("@options_config")

      @standard_config[:ignore].each do |(path, cops)|
        cops.each do |cop|
          options_config[cop] ||= {}
          options_config[cop]["Exclude"] ||= []
          options_config[cop]["Exclude"] |= [Pathname.new(@standard_yml_path).dirname.join(path).to_s]
        end
      end
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
