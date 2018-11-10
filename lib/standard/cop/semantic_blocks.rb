require "rubocop"

module RuboCop
  module Cop
    module Standard

      # Style/BlockDelimiters with EnforcedStyle: semantic
      # but with the exception of single-line, which always prefers {}
      class SemanticBlocks < RuboCop::Cop::Style::BlockDelimiters

        def style
          :semantic
        end

        def autocorrect(node)
          if !correction_would_break_code?(node) && !node.multiline?
            replace_do_end_with_braces(node.loc)
          else
            super
          end
        end

        private

        def message(node)
          if !node.multiline?
            "Prefer `{...}` for both procedural and functional single-line blocks.'"
          else
            super
          end
        end

        def proper_block_style?(node)
          if !ignored_method?(node.method_name) && !node.multiline?
            line_count_based_block_style?(node)
          else
            super
          end
        end
      end
    end
  end

end
