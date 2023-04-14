require "lint_roller"
require_relative "bananas"

module Banana
  class Plugin < LintRoller::Plugin
    def rules(context)
      LintRoller::Rules.new(
        type: :object,
        value: {
          "Bananas/BananasOnly" => {
            "Enabled" => true
          }
        }
      )
    end
  end
end
