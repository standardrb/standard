module RuboCop
  module Cop
    module Bananas
      class BananasOnly < Cop
        def on_lvasgn(node)
          name, = *node

          if name != :bananas
            add_offense(node, message: "Bananas only! No oranges.")
          end
        end
      end
    end
  end
end
