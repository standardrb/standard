module Standard
  module Plugin
    class MergesPluginsIntoRubocopConfig
      DISALLOWED_ALLCOPS_KEYS = [
        "Include",
        "Exclude",
        "StyleGuideCopsOnly",
        "TargetRubyVersion",

        # The AllCops[Enabled] key is an unused artifact of #merge_with_default.
        # See: https://github.com/rubocop/rubocop/blob/master/lib/rubocop/config_loader_resolver.rb#L81-L85
        "Enabled"
      ].freeze

      def initialize
        @creates_runner_context = Standard::Plugin::CreatesRunnerContext.new
      end

      def call(options_config, standard_config, plugins, permit_merging: false)
        runner_context = @creates_runner_context.call(standard_config)
        extended_config = load_and_merge_extended_rubocop_configs(options_config, runner_context, plugins).to_h
        merge_standard_and_user_all_cops!(options_config, extended_config)
        merge_extended_rules_into_standard!(options_config, extended_config, permit_merging: permit_merging)
      end

      private

      def load_and_merge_extended_rubocop_configs(options_config, runner_context, plugins)
        fake_out_rubocop_default_configuration(options_config) do |fake_config|
          plugins.reduce(fake_config) do |config, plugin|
            RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, config)
            rules = plugin.rules(runner_context)
            extension = RuboCop::ConfigLoader.load_file(rules.value)
            RuboCop::ConfigLoader.merge_with_default(extension, rules.value)
          end
        end
      end

      def merge_standard_and_user_all_cops!(options_config, extended_config)
        options_config["AllCops"].merge!(
          except(extended_config["AllCops"], DISALLOWED_ALLCOPS_KEYS)
        )
      end

      def merge_extended_rules_into_standard!(options_config, extended_config, permit_merging:)
        if permit_merging
          extended_config.each do |key, value|
            options_config[key] = if options_config[key].is_a?(Hash)
              merge(options_config[key], value)
            else
              value
            end
          end
        else
          except(extended_config, options_config.keys).each do |key, value|
            options_config[key] = value
          end
        end
      end

      def fake_out_rubocop_default_configuration(options_config)
        og_default_config = RuboCop::ConfigLoader.instance_variable_get(:@default_configuration)
        result = yield blank_rubocop_config(options_config)
        RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, og_default_config)
        result
      end

      # Blank configuration object to merge extensions into, with all known
      #   - AllCops keys set to avoid warnings about unknown properties
      #   - Lint/Syntax must be set to avoid a nil error when verifying inherited configs
      def blank_rubocop_config(example_config)
        RuboCop::Config.new(example_config.to_h.slice("AllCops", "Lint/Syntax"), "")
      end

      def except(hash_or_config, keys)
        hash_or_config.to_h.reject { |key, _| keys.include?(key) }.to_h
      end

      # Always deletes nil entries, always overwrites arrays
      # Simplified version of rubocop's ConfigLoader#merge:
      # https://github.com/rubocop/rubocop/blob/v1.48.1/lib/rubocop/config_loader_resolver.rb#L98
      def merge(old_hash, new_hash)
        result = old_hash.merge(new_hash)
        keys_appearing_in_both = old_hash.keys & new_hash.keys
        keys_appearing_in_both.each do |key|
          if new_hash[key].nil?
            result.delete(key)
          elsif old_hash[key].is_a?(Hash) && new_hash[key].is_a?(Hash)
            result[key] = merge(old_hash[key], new_hash[key])
          end
        end
        result
      end
    end
  end
end
