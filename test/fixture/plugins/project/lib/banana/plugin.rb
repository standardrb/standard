require "lint_roller"
require_relative "bananas"
require_relative "banana_bomb"

module Banana
  class Plugin < LintRoller::Plugin
    def initialize(config)
      @config = config
    end

    def rules(context)
      LintRoller::Rules.new(
        type: :object,
        value: {
          "Bananas/BananasOnly" => {
            "Enabled" => true,
            "PreferredBananaReplacement" => @config["preferred_banana_replacement"]
          },
          "Bananas/BananaBomb" => {
            "Exclude" => ["nothinglolwtf"],
            "Enabled" => true
          }
        }
      )
    end
  end
end
