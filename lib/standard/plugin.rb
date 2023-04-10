module Standard
  module Plugin
  end
end

require_relative "plugin/creates_runner_context"
require_relative "plugin/combines_plugin_configs"
require_relative "plugin/merges_plugins_into_rubocop_config"
require_relative "plugin/standardizes_configured_plugins"
require_relative "plugin/determines_class_constant"
require_relative "plugin/initializes_plugins"
