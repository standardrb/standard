# This cop is adapted from:
#
# https://github.com/rubocop-hq/rubocop/blob/master/lib/rubocop/cop/style/block_delimiters.rb
#
# Copyright (c) 2012-18 Bozhidar Batsov

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module RuboCop::Cop
  module Standard
    class SemanticBlocks < RuboCop::Cop::Cop
      include RuboCop::Cop::IgnoredMethods

      def on_send(node)
        return unless node.arguments?
        return if node.parenthesized? || node.operator_method?

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
        return if ignored_node?(node) || proper_block_style?(node)

        add_offense(node, location: :begin)
      end

      def autocorrect(node)
        return if correction_would_break_code?(node)

        if node.single_line?
          replace_do_end_with_braces(node.loc)
        elsif node.braces?
          replace_braces_with_do_end(node.loc)
        else
          replace_do_end_with_braces(node.loc)
        end
      end

      private

      def message(node)
        if node.single_line?
          'Prefer `{...}` over `do...end` for single-line blocks.'
        elsif node.loc.begin.source == '{'
          'Prefer `do...end` over `{...}` for procedural blocks.'
        else
          'Prefer `{...}` over `do...end` for functional blocks.'
        end
      end

      def replace_braces_with_do_end(loc)
        b = loc.begin
        e = loc.end

        lambda do |corrector|
          corrector.insert_before(b, ' ') unless whitespace_before?(b)
          corrector.insert_before(e, ' ') unless whitespace_before?(e)
          corrector.insert_after(b, ' ') unless whitespace_after?(b)
          corrector.replace(b, 'do')
          corrector.replace(e, 'end')
        end
      end

      def replace_do_end_with_braces(loc)
        b = loc.begin
        e = loc.end

        lambda do |corrector|
          corrector.insert_after(b, ' ') unless whitespace_after?(b, 2)

          corrector.replace(b, '{')
          corrector.replace(e, '}')
        end
      end

      def whitespace_before?(range)
        range.source_buffer.source[range.begin_pos - 1, 1] =~ /\s/
      end

      def whitespace_after?(range, length = 1)
        range.source_buffer.source[range.begin_pos + length, 1] =~ /\s/
      end

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
        method_name = node.method_name

        if ignored_method?(method_name)
          true
        elsif node.single_line?
          node.braces?
        elsif node.braces?
          functional_method?(method_name) || functional_block?(node)
        else
          procedural_method?(method_name) || !return_value_used?(node)
        end
      end

      def correction_would_break_code?(node)
        return unless node.keywords?

        node.send_node.arguments? && !node.send_node.parenthesized?
      end

      def functional_method?(method_name)
        config['Style/BlockDelimiters']['FunctionalMethods'].map(&:to_sym).include?(method_name)
      end

      def functional_block?(node)
        return_value_used?(node) || return_value_of_scope?(node)
      end

      def procedural_method?(method_name)
        config['Style/BlockDelimiters']['ProceduralMethods'].map(&:to_sym).include?(method_name)
      end

      def return_value_used?(node)
        return unless node.parent

        # If there are parentheses around the block, check if that
        # is being used.
        if node.parent.begin_type?
          return_value_used?(node.parent)
        else
          node.parent.assignment? || node.parent.send_type?
        end
      end

      def return_value_of_scope?(node)
        return unless node.parent

        conditional?(node.parent) || array_or_range?(node.parent) ||
          node.parent.children.last == node
      end

      def conditional?(node)
        node.if_type? || node.or_type? || node.and_type?
      end

      def array_or_range?(node)
        node.array_type? || node.irange_type? || node.erange_type?
      end
    end
  end
end
