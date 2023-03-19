module RuboCop
  class Cop::Lint::AssignmentInCondition
    undef_method :message
    def message(_)
      "Wrap assignment in parentheses if intentional"
    end
  end

  class DirectiveComment
    remove_const :DIRECTIVE_COMMENT_REGEXP
    DIRECTIVE_COMMENT_REGEXP = Regexp.new(
      ('# (?:standard|rubocop) : ((?:disable|enable|todo))\b ' + COPS_PATTERN)
        .gsub(" ", '\s*')
    )
  end

  class CommentConfig
    alias_method :old_initialize, :initialize

    def initialize(processed_source)
      old_initialize(processed_source)
      @no_directives &&= !processed_source.raw_source.include?("standard")
    end
  end
end
