class Standard::CreatesConfigStore
  class ConfiguresIgnoredPaths
    def call(options_config, standard_config)
      # being careful not to set [] or delete Exclude since that would change inherit_gem users intentions
      if (all_excludes = options_config.dig("AllCops", "Exclude"))
        if standard_config[:default_ignores]
          all_excludes.map! { |path| absolutify(standard_config[:config_root], path) }
        else
          all_excludes.clear
        end
      end

      # add user provided ignores
      standard_config[:ignore].each do |path, cops|
        cops.each do |cop|
          (options_config[cop] ||= {})["Exclude"] ||= []
          options_config[cop]["Exclude"] |= [
            absolutify(standard_config[:config_root], path)
          ]
        end
      end
    end

    private

    # not sure if this is necessary with rubocop already doing this in
    # lib/rubocop/config.rb:77:in `block in make_excludes_absolute'
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
