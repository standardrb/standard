require "pathname"

class Standard::CreatesConfigStore
  class AssignsRubocopYaml
    def call(config_store, standard_config)
      config_store.options_config = Pathname.new(__dir__).join("../../../config/default.yml")
      config_store.instance_variable_get(:@options_config)
    end
  end
end
