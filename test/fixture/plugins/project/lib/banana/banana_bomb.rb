# A cop that always fails. Forces a test that proves ignore works on plugin cops
module RuboCop
  module Cop
    module Bananas
      class BananaBomb < Cop
        def on_class(node)
          add_offense(node, message: "🍌💣 - Better ignore me!")
        end
      end
    end
  end
end
