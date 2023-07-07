require "rubocop"
require "lint_roller"

module Standard
end

require "standard/rubocop/ext"

require "standard/version"
require "standard/cli"
require "standard/railtie" if defined?(Rails) && defined?(Rails::Railtie)

require "standard/formatter"

require "standard/plugin"
