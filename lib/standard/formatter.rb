require "rubocop"

module Standard
  class Formatter < RuboCop::Formatter::BaseFormatter
    CALL_TO_ACTION_MESSAGE = <<-CALL_TO_ACTION.gsub(/^ {6}/, "")
      Notice: Disagree with these rules? While StandardRB is pre-1.0.0, feel free to submit suggestions to:
        https://github.com/testdouble/standard/issues/new
    CALL_TO_ACTION

    def initialize(*args)
      super
      @header_printed_already = false
      @all_uncorrected_offenses = []
    end

    def file_finished(file, offenses)
      uncorrected_offenses = offenses.reject(&:corrected?)
      @all_uncorrected_offenses += uncorrected_offenses
      print_header_once unless uncorrected_offenses.empty?
      working_directory = Pathname.new(Dir.pwd)

      uncorrected_offenses.each do |o|
        absolute_path = Pathname.new(file)
        relative_path = absolute_path.relative_path_from(working_directory)
        output.printf("  %s:%d:%d: %s\n", relative_path, o.line, o.real_column, o.message.tr("\n", " "))
      end
    end

    def finished(_inspected_files)
      print_call_for_feedback unless @all_uncorrected_offenses.empty?
    end

    private

    def print_header_once
      return if @header_printed_already
      command = if File.split($PROGRAM_NAME).last == "rake"
        "rake standard:fix"
      else
        "standardrb --fix"
      end

      output.print <<-HEADER.gsub(/^ {8}/, "")
        standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
        standard: Run `#{command}` to automatically fix some problems.
      HEADER
      @header_printed_already = true
    end

    def print_call_for_feedback
      output.print "\n"
      output.print CALL_TO_ACTION_MESSAGE
    end
  end
end
