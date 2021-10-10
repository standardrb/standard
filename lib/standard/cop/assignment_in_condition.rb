# shorten the otherwise long and confusing message
module RuboCop::Cop
  module Standard
    class AssignmentInCondition < RuboCop::Cop::Lint::AssignmentInCondition
      def message(_)
        "Wrap assignment in parentheses if intentional"
      end
    end
  end
end
