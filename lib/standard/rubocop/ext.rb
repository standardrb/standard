module RuboCop
  class Cop::Lint::AssignmentInCondition
    undef_method :message
    def message(_)
      "Wrap assignment in parentheses if intentional"
    end
  end
end
