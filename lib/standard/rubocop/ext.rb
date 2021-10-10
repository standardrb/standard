module RuboCop
  class DirectiveComment
    remove_const :DIRECTIVE_COMMENT_REGEXP
    DIRECTIVE_COMMENT_REGEXP = Regexp.new(
      ('# (?:standard|rubocop) : ((?:disable|enable|todo))\b ' + COPS_PATTERN)
        .gsub(" ", '\s*')
    )
  end
end
