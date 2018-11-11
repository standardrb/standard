module RuboCop
  class Cop::Lint::AssignmentInCondition
    def message(_)
      "Wrap assignment in parentheses if intentional"
    end
  end
end
