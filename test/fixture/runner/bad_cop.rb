module RuboCop::Cop
  module Standard
    class BadCop < RuboCop::Cop::Cop
      include RuboCop::Cop::IgnoredMethods

      def on_send(node)
      end

      def on_block(node)
      end

      def autocorrect(node)
      end
    end
  end
end
