require "rubocop"

module Standard
  class Formatter < RuboCop::Formatter::BaseFormatter
    def file_finished(file, offenses)
      if offenses.size > 0
        output.print <<~NOTE
          standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
          standard: Run `standard --fix` to automatically fix some problems.
        NOTE
      end

      offenses.each do |o|
        output.printf("  %s:%d:%d: %s\n", file, o.line, o.real_column, o.message.tr("\n", ' '))
      end
    end
  end
end
