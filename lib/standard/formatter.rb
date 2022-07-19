require "yaml"
require "rubocop"
require_relative "detects_fixability"

module Standard
  class Formatter < RuboCop::Formatter::BaseFormatter
    STANDARD_GREETING = <<-MSG.gsub(/^ {6}/, "")
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
    MSG

    def self.fixable_error_message(command)
      <<-MSG.gsub(/^ {8}/, "")
        standard: Run `#{command}` to automatically fix some problems.
      MSG
    end

    def initialize(*args)
      super
      @detects_fixability = DetectsFixability.new
      @header_printed_already = false
      @fix_suggestion_printed_already = false
      @offenses_encountered = false
    end

    def started(_target_files)
      print_todo_warning
    end

    def file_finished(file, offenses)
      uncorrected_offenses = offenses.reject(&:corrected?)

      return unless uncorrected_offenses.any?

      @offenses_encountered = true

      print_header_once
      print_fix_suggestion_once(uncorrected_offenses)

      uncorrected_offenses.each do |o|
        output.printf("  %s:%d:%d: %s\n", path_to(file), o.line, o.real_column, o.message.tr("\n", " "))
      end
    end

    def finished(inspected_files)
      print_todo_congratulations
    end

    private

    def print_header_once
      return if @header_printed_already

      output.print STANDARD_GREETING

      @header_printed_already = true
    end

    def print_fix_suggestion_once(offenses)
      if !@fix_suggestion_printed_already && should_suggest_fix?(offenses)
        command = if File.split($PROGRAM_NAME).last == "rake"
          "rake standard:fix"
        else
          "standardrb --fix"
        end

        output.print self.class.fixable_error_message(command)
        @fix_suggestion_printed_already = true
      end
    end

    def print_todo_warning
      todo_file = options[:todo_file]
      return unless todo_file

      todo_ignore_files = options[:todo_ignore_files]
      return unless todo_ignore_files&.any?

      output.print <<-HEADER.gsub(/^ {8}/, "")
        WARNING: this project is being migrated to standard gradually via `#{todo_file}` and is ignoring these files:
      HEADER

      todo_ignore_files.each do |f|
        output.printf("  %s\n", f)
      end
    end

    def print_todo_congratulations
      return if @offenses_encountered

      todo_file = options[:todo_file]
      return unless todo_file

      todo_ignore_files = options[:todo_ignore_files]
      return if todo_ignore_files&.any?

      output.print <<-HEADER.gsub(/^ {8}/, "")
        Congratulations, you've successfully migrated this project to Standard! Delete `#{todo_file}` in celebration.
      HEADER
    end

    def path_to(file)
      Pathname.new(file).relative_path_from(Pathname.new(Dir.pwd))
    end

    def autocorrect_option_provided?
      options[:autocorrect]
    end

    def should_suggest_fix?(offenses)
      !autocorrect_option_provided? && @detects_fixability.call(offenses)
    end
  end
end
