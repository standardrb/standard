module RuboCop::Cop
  module Standard
    # Check for uses of braces around single line blocks, but allows either
    # braces or do/end for multi-line blocks.
    #
    # @example
    #   # bad - single line block
    #   items.each do |item| item / 5 end
    #
    #   # good - single line block
    #   items.each { |item| item / 5 }
    #
    class BlockSingleLineBraces < RuboCop::Cop::Base
      extend RuboCop::Cop::AutoCorrector

      def on_send(node)
        return unless node.arguments?
        return if node.parenthesized?
        return if node.operator_method? || node.assignment_method?

        node.arguments.each do |arg|
          get_blocks(arg) do |block|
            # If there are no parentheses around the arguments, then braces
            # and do-end have different meaning due to how they bind, so we
            # allow either.
            ignore_node(block)
          end
        end
      end

      def on_block(node)
        return if ignored_node?(node)
        return if proper_block_style?(node)

        message = message(node)
        add_offense(node.loc.begin, message: message) do |corrector|
          autocorrect(corrector, node)
        end
      end

      private

      def get_blocks(node, &block)
        case node.type
        when :block
          yield node
        when :send
          get_blocks(node.receiver, &block) if node.receiver
        when :hash
          # A hash which is passed as method argument may have no braces
          # In that case, one of the K/V pairs could contain a block node
          # which could change in meaning if do...end replaced {...}
          return if node.braces?

          node.each_child_node { |child| get_blocks(child, &block) }
        when :pair
          node.each_child_node { |child| get_blocks(child, &block) }
        end
      end

      def proper_block_style?(node)
        node.multiline? || node.braces?
      end

      def message(node)
        "Prefer `{...}` over `do...end` for single-line blocks."
      end

      def autocorrect(corrector, node)
        return if correction_would_break_code?(node)

        replace_do_end_with_braces(corrector, node.loc)
      end

      def correction_would_break_code?(node)
        return unless node.keywords?

        node.send_node.arguments? && !node.send_node.parenthesized?
      end

      def replace_do_end_with_braces(corrector, loc)
        b = loc.begin
        e = loc.end

        corrector.insert_after(b, " ") unless whitespace_after?(b, 2)

        corrector.replace(b, "{")
        corrector.replace(e, "}")
      end

      def whitespace_after?(range, length = 1)
        /\s/.match?(range.source_buffer.source[range.begin_pos + length, 1])
      end
    end
  end
end
