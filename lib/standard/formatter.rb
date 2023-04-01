require "yaml"
require "rubocop"

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

    def started(_target_files)
      @header_printed_already = false
      @fix_suggestion_printed_already = false
      @total_correction_count = 0
      @total_correctable_count = 0
      @total_uncorrected_count = 0
      print_todo_warning
    end

    def file_finished(file, offenses)
      track_stats(offenses)

      if (uncorrected_offenses = offenses.reject(&:corrected?)).any?
        print_header_once
        print_fix_suggestion_once(uncorrected_offenses)

        uncorrected_offenses.each do |o|
          output.printf("  %s:%d:%d: %s\n", path_to(file), o.line, o.real_column, o.message.tr("\n", " "))
        end
      end
    end

    def track_stats(offenses)
      corrected = offenses.count(&:corrected?)
      @total_correction_count += corrected
      @total_correctable_count += offenses.count(&:correctable?) - corrected
      @total_uncorrected_count += offenses.count - corrected
    end

    def finished(_inspected_files)
      print_todo_congratulations
    end

    private

    def print_header_once
      return if @header_printed_already

      output.print STANDARD_GREETING

      @header_printed_already = true
    end

    def print_fix_suggestion_once(offenses)
      return if @fix_suggestion_printed_already
      if (fix_mode = potential_fix_mode(offenses))
        run_mode = determine_run_mode

        command = if run_mode == :rake
          "rake standard:#{fix_mode}"
        else
          "standardrb --#{fix_mode.to_s.tr("_", "-")}"
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
      if @total_uncorrected_count == 0 &&
          options[:todo_file] &&
          options[:todo_ignore_files]&.none?
        output.print <<-HEADER.gsub(/^ {10}/, "")
          Congratulations, you've successfully migrated this project to Standard! Delete `#{options[:todo_file]}` in celebration.
        HEADER
      end
    end

    def path_to(file)
      Pathname.new(file).relative_path_from(Pathname.new(Dir.pwd))
    end

    def potential_fix_mode(offenses)
      return nil unless @total_correctable_count > 0

      if !options[:autocorrect]
        :fix
      elsif options[:safe_autocorrect]
        :fix_unsafely
      end
    end

    def determine_run_mode
      if File.split($PROGRAM_NAME).last == "rake"
        :rake
      else
        :cli
      end
    end
  end
end
