module RuboCop::Cop
  module Standard
    class BadCop < RuboCop::Cop::Base
      include RuboCop::Cop::IgnoredMethods
      extend RuboCop::Cop::AutoCorrector

      def on_send(node)
      end

      def on_block(node)
      end
    end
  end
end
