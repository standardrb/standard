require_relative "../file_finder"

class Standard::CreatesConfigStore
  class MergesUserConfigExtensions
    DISALLOWED_ALLCOPS_KEYS = [
      "Include",
      "Exclude",
      "StyleGuideCopsOnly",
      "TargetRubyVersion",

      # The AllCops[Enabled] key is an unused artifact of #merge_with_default.
      # See: https://github.com/rubocop/rubocop/blob/master/lib/rubocop/config_loader_resolver.rb#L81-L85
      "Enabled"
    ].freeze

    def call(options_config, standard_config)
      return unless standard_config[:extend_config]&.any?

      extended_config = load_and_merge_extended_rubocop_configs(options_config, standard_config).to_h
      merge_standard_and_user_all_cops!(options_config, extended_config)
      merge_extended_rules_into_standard!(options_config, extended_config)
    end

    private

    def load_and_merge_extended_rubocop_configs(options_config, standard_config)
      fake_out_rubocop_default_configuration(options_config) do |fake_config|
        standard_config[:extend_config].reduce(fake_config) do |config, path|
          RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, config)

          user_rubocop_yaml_path = Standard::FileFinder.new.call(path, Dir.pwd)
          extension = RuboCop::ConfigLoader.load_file(user_rubocop_yaml_path)
          RuboCop::ConfigLoader.merge_with_default(extension, path)
        end
      end
    end

    def merge_standard_and_user_all_cops!(options_config, extended_config)
      options_config["AllCops"].merge!(
        except(extended_config["AllCops"], DISALLOWED_ALLCOPS_KEYS)
      )
    end

    def merge_extended_rules_into_standard!(options_config, extended_config)
      except(extended_config, options_config.keys).each do |key, value|
        options_config[key] = value
      end
    end

    def fake_out_rubocop_default_configuration(options_config)
      og_default_config = RuboCop::ConfigLoader.instance_variable_get(:@default_configuration)
      result = yield blank_rubocop_config(options_config)
      RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, og_default_config)
      result
    end

    # Blank configuration object to merge extensions into, with all known
    # AllCops keys set to avoid warnings about unknown properties
    def blank_rubocop_config(example_config)
      RuboCop::Config.new(example_config.to_h.slice("AllCops"), "")
    end

    def except(hash_or_config, keys)
      hash_or_config.to_h.reject { |key, _| keys.include?(key) }.to_h
    end
  end
end
