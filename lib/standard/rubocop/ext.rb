module RuboCop
  class Cop::Lint::AssignmentInCondition
    undef_method :message
    def message(_)
      "Wrap assignment in parentheses if intentional"
    end
  end

  class DirectiveComment
    # Accept `# standard:` alongside `# rubocop:`, keeping every directive
    # mode RuboCop supports (e.g. `disable-next`, `push`, `pop`)
    rubocop_directive_comment_regexp = remove_const(:DIRECTIVE_COMMENT_REGEXP)
    DIRECTIVE_COMMENT_REGEXP = Regexp.new(
      rubocop_directive_comment_regexp.source.sub("rubocop", "(?:standard|rubocop)")
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
