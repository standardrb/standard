module RuboCop
  module Cop
    module Bananas
      class BananasOnly < Cop
        def on_lvasgn(node)
          # cracks me up that we have to disable this cop inside itself
          name, = *node # standard:disable Bananas/BananasOnly

          if name != :bananas
            bananas = Array(cop_config["PreferredBananaReplacement"] || "olives").join(" or ")
            add_offense(node, message: "Bananas only! No #{bananas}.")
          end
        end
      end
    end
  end
end
