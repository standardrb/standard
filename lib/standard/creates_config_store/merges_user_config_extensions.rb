require_relative "../file_finder"

class Standard::CreatesConfigStore
  class MergesUserConfigExtensions
    DISALLOWED_ALLCOPS_KEYS = [
      "Include",
      "Exclude",
      "StyleGuideCopsOnly",
      "TargetRubyVersion"
    ].freeze

    def call(options_config, standard_config)
      return unless standard_config[:extend_config]&.any?

      extended_config = load_and_merge_extended_rubocop_configs(standard_config)
      merge_standard_and_user_all_cops!(options_config, extended_config)
      merge_extended_rules_into_standard!(options_config, extended_config)
    end

    private

    def load_and_merge_extended_rubocop_configs(standard_config)
      # Blank configuration object to merge extensions into
      config = RuboCop::Config.new({"AllCops" => {}}, "")

      orig_default_config = RuboCop::ConfigLoader.instance_variable_get(:@default_configuration)

      standard_config[:extend_config].each do |path|
        # RuboCop plugins often modify the default configuration in-place
        # (e.g., load custom base configurations)
        #
        # So, we provide our blank configuration as a default one,
        # to make sure all modifications have been applied
        RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, config)

        path = Standard::FileFinder.new.call(path, Dir.pwd)

        extension = RuboCop::ConfigLoader.load_file(path)

        config = RuboCop::ConfigLoader.merge_with_default(extension, path)
      end

      # Restore default configuration to the original state
      RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, orig_default_config)

      # The Enabled key is an unused artefact of #merge_with_default
      config["AllCops"].delete("Enabled")

      config.to_h
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

    def except(hash, keys)
      hash.reject { |key, _| keys.include?(key) }.to_h
    end
  end
end
