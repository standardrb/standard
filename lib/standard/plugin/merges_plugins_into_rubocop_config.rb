module Standard
  module Plugin
    class MergesPluginsIntoRubocopConfig
      # Blank configuration object to merge plugins into, with only the following spared:
      #   - AllCops keys set to avoid warnings about unknown properties
      #   - Lint/Syntax must be set to avoid a nil error when verifying inherited configs
      MANDATORY_RUBOCOP_CONFIG_KEYS = ["AllCops", "Lint/Syntax"].freeze

      # AllCops keys that standard does not allow to be set by plugins
      DISALLOWED_ALLCOPS_KEYS = [
        "Include",
        "Exclude",
        "StyleGuideBaseURL",
        "StyleGuideCopsOnly",
        "TargetRubyVersion",
        "EnabledByDefault",
        "DisabledByDefault",

        # The AllCops[Enabled] key is an unused artifact of #merge_with_default.
        # See: https://github.com/rubocop/rubocop/blob/master/lib/rubocop/config_loader_resolver.rb#L81-L85
        "Enabled"
      ].freeze

      def initialize
        @creates_runner_context = Standard::Plugin::CreatesRunnerContext.new
      end

      def call(options_config, standard_config, plugins, permit_merging:)
        runner_context = @creates_runner_context.call(standard_config)
        plugin_config = combine_rubocop_configs(options_config, runner_context, plugins, permit_merging: permit_merging).to_h
        merge_config_into_all_cops!(options_config, plugin_config)
        merge_config_into_standard!(options_config, plugin_config, permit_merging: permit_merging)
      end

      private

      def combine_rubocop_configs(options_config, runner_context, plugins, permit_merging:)
        all_cop_keys_configured_by_plugins = all_cop_keys_previously_configured_by_plugins(options_config, permit_merging: permit_merging)
        fake_out_rubocop_default_configuration(options_config) do |fake_config|
          plugins.reduce(fake_config) do |combined_config, plugin|
            RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, combined_config)
            next_config, path = config_for_plugin(plugin, runner_context)

            next_config["AllCops"], all_cop_keys_configured_by_plugins = merge_all_cop_settings(
              combined_config["AllCops"],
              next_config["AllCops"],
              all_cop_keys_configured_by_plugins
            )
            delete_already_configured_keys!(combined_config.keys, next_config, dont_delete_keys: ["AllCops"])

            RuboCop::ConfigLoader.merge_with_default(next_config, path, unset_nil: false)
          end
        end
      end

      def config_for_plugin(plugin, runner_context)
        rules = plugin.rules(runner_context)

        if rules.type == :path
          [RuboCop::ConfigLoader.load_file(rules.value), rules.value]
        elsif rules.type == :object
          path = plugin.method(:rules).source_location[0]
          [RuboCop::Config.create(rules.value, path, check: true), path]
        elsif rules.type == :error
          raise "Plugin `#{plugin.about&.name || plugin.inspect}' failed to load with error: #{rules.value.respond_to?(:message) ? rules.value.message : rules.value}"
        end
      end

      # This is how we ensure "first-in wins": plugins can override AllCops settings that are
      # set by RuboCop's default configuration, but once a plugin sets an AllCop setting, they
      # have exclusive first-in-wins rights to that setting.
      #
      # The one exception to this are array fields, because we don't want to
      # overwrite the AllCops defaults but rather munge the arrays (`existing |
      # new`) to allow plugins to add to the array, for example Include and
      # Exclude paths and patterns.
      def merge_all_cop_settings(existing_all_cops, new_all_cops, already_configured_keys)
        return [existing_all_cops, already_configured_keys] unless new_all_cops.is_a?(Hash)

        combined_all_cops = existing_all_cops.dup
        combined_configured_keys = already_configured_keys.dup

        new_all_cops.each do |key, value|
          if combined_all_cops[key].is_a?(Array) && value.is_a?(Array)
            combined_all_cops[key] |= value
            combined_configured_keys |= [key]
          elsif !combined_configured_keys.include?(key)
            combined_all_cops[key] = value
            combined_configured_keys << key
          end
        end

        [combined_all_cops, combined_configured_keys]
      end

      def delete_already_configured_keys!(configured_keys, next_config, dont_delete_keys: [])
        duplicate_keys = configured_keys & Array(next_config&.keys)

        (duplicate_keys - dont_delete_keys).each do |key|
          next_config.delete(key)
        end
      end

      def merge_config_into_all_cops!(options_config, plugin_config)
        options_config["AllCops"].merge!(
          except(plugin_config["AllCops"], DISALLOWED_ALLCOPS_KEYS)
        )
      end

      def merge_config_into_standard!(options_config, plugin_config, permit_merging:)
        if permit_merging
          plugin_config.each do |key, value|
            options_config[key] = if options_config[key].is_a?(Hash)
              merge(options_config[key], value)
            else
              value
            end
          end
        else
          except(plugin_config, options_config.keys).each do |key, value|
            options_config[key] = value
          end
        end
      end

      def all_cop_keys_previously_configured_by_plugins(options_config, permit_merging:)
        if permit_merging
          []
        else
          Array(options_config["AllCops"]&.keys) - RuboCop::ConfigLoader.default_configuration["AllCops"].keys
        end
      end

      def fake_out_rubocop_default_configuration(options_config)
        og_default_config = RuboCop::ConfigLoader.default_configuration
        set_target_rails_version_on_all_cops_because_its_technically_not_allowed!(options_config)
        result = yield blank_rubocop_config(options_config)
        RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, og_default_config)
        result
      end

      # Avoid a warning that would otherwise be emitted by any plugin that set TargetRailsVersion
      # because it's not a default AllCops key specified in RuboCop's embedded default config.
      #
      # See: https://github.com/rubocop/rubocop/pull/11833
      def set_target_rails_version_on_all_cops_because_its_technically_not_allowed!(options_config)
        return if !options_config.key?("AllCops") || options_config["AllCops"].key?("TargetRailsVersion")

        options_config["AllCops"]["TargetRailsVersion"] = nil
      end

      def blank_rubocop_config(example_config)
        RuboCop::Config.new(example_config.to_h.slice(*MANDATORY_RUBOCOP_CONFIG_KEYS), "")
      end

      def except(hash_or_config, keys)
        hash_or_config.to_h.except(*keys).to_h
      end

      # Always deletes nil entries, always overwrites arrays
      # This is a simplified version of rubocop's ConfigLoader#merge:
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
