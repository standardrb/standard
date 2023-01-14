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
      {
        "AllCops" => {}
      }.tap do |config|
        standard_config[:extend_config].each do |path|
          extension = RuboCop::ConfigLoader.load_file(Standard::FileFinder.new.call(path, Dir.pwd)).to_h
          config["AllCops"].merge!(extension["AllCops"]) if extension.key?("AllCops")
          config.merge!(extension.except("AllCops"))
        end
      end
    end

    def merge_standard_and_user_all_cops!(options_config, extended_config)
      options_config["AllCops"].merge!(
        extended_config["AllCops"].except(*DISALLOWED_ALLCOPS_KEYS)
      )
    end

    def merge_extended_rules_into_standard!(options_config, extended_config)
      extended_config.except(*options_config.keys).each do |key, value|
        options_config[key] = value
      end
    end
  end
end
