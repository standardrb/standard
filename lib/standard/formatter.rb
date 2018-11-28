require "rubocop"

module Standard
  class Formatter < RuboCop::Formatter::BaseFormatter
    def file_finished(file, offenses)
      uncorrected_offenses = offenses.reject(&:corrected?)
      print_header_once unless uncorrected_offenses.empty?
      working_directory = Pathname.new(Dir.pwd)

      uncorrected_offenses.each do |o|
        absolute_path = Pathname.new(file)
        relative_path = absolute_path.relative_path_from(working_directory)
        output.printf("  %s:%d:%d: %s\n", relative_path, o.line, o.real_column, o.message.tr("\n", " "))
      end
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
  end
end
