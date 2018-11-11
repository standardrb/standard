module RuboCop
  class Cop::Lint::AssignmentInCondition
    def message(node)
      "Wrap assignment in parentheses if intentional"
    end
  end
end
