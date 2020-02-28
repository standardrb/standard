class Standard::CreatesConfigStore
  class ConfiguresIgnoredPaths
    DEFAULT_IGNORES = [
      # Match RuboCop's defaults: https://github.com/rubocop-hq/rubocop/blob/v0.61.1/config/default.yml#L60-L63
      ".git/**/*",
      "node_modules/**/*",
      "vendor/**/*",
      # Standard's own default ignores:
      "bin/*",
      "db/schema.rb",
      "tmp/**/*"
    ].map { |path| [path, ["AllCops"]] }.freeze

    def call(options_config, standard_config)
      ignored_patterns(standard_config).each do |(path, cops)|
        cops.each do |cop|
          options_config[cop] ||= {}
          options_config[cop]["Exclude"] ||= []
          options_config[cop]["Exclude"] |= [
            absolutify(standard_config[:config_root], path)
          ]
        end
      end
    end

    private

    def ignored_patterns(standard_config)
      (standard_config[:default_ignores] ? DEFAULT_IGNORES : []) +
        standard_config[:ignore]
    end

    def absolutify(config_root, path)
      if !absolute?(path)
        File.expand_path(File.join(config_root || Dir.pwd, path))
      else
        path
      end
    end

    def absolute?(path)
      path =~ %r{\A([A-Z]:)?/}
    end
  end
end
