require "rubocop"

require "standard/rubocop/ext"

require "standard/version"
require "standard/cli"
require "standard/railtie" if defined?(Rails) && defined?(Rails::Railtie)

require "standard/formatter"
require "standard/cop/block_single_line_braces"

module Standard
end
