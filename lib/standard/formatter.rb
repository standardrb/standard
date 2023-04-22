require "yaml"
require "rubocop"

module Standard
  class Formatter < RuboCop::Formatter::BaseFormatter
    STANDARD_GREETING = <<~MSG
      standard: Use Ruby Standard Style (https://github.com/standardrb/standard)
    MSG

    def started(_target_files)
      @header_printed_already = false
      @total_correction_count = 0
      @total_correctable_count = 0
      @total_uncorrected_count = 0
      print_todo_warning
    end

    def file_finished(file, offenses)
      track_stats(offenses)

      if (uncorrected_offenses = offenses.reject(&:corrected?)).any?
        print_header_once

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
      print_fix_suggestion
      print_todo_congratulations
    end

    private

    def print_header_once
      return if @header_printed_already

      output.print STANDARD_GREETING

      @header_printed_already = true
    end

    def print_fix_suggestion
      if (fix_mode = potential_fix_mode)
        run_mode = determine_run_mode

        command = if run_mode == :rake
          "rake standard:#{fix_mode}"
        else
          "standardrb --#{fix_mode.to_s.tr("_", "-")}"
        end

        output.print fixable_error_message(command)
      end
    end

    def print_todo_warning
      todo_file = options[:todo_file]
      return unless todo_file

      todo_ignore_files = options[:todo_ignore_files]
      return unless todo_ignore_files&.any?

      output.print <<~HEADER
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
        output.print <<~HEADER
          Congratulations, you've successfully migrated this project to Standard! Delete `#{options[:todo_file]}` in celebration.
        HEADER
      end
    end

    def path_to(file)
      Pathname.new(file).relative_path_from(Pathname.new(Dir.pwd))
    end

    def potential_fix_mode
      return nil unless @total_correctable_count > 0

      if !options[:autocorrect]
        :fix
      elsif options[:autocorrect] && options[:safe_autocorrect]
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

    def fixable_error_message(command)
      sales_pitch = if !options[:autocorrect]
        if @total_correctable_count > 1
          "fix up to #{@total_correctable_count} problems"
        else
          "potentially fix one problem"
        end
      elsif options[:autocorrect] && options[:safe_autocorrect]
        if @total_correctable_count > 1
          "DANGEROUSLY fix #{@total_correctable_count} problems"
        else
          "DANGEROUSLY fix one problem"
        end
      end

      <<~MSG
        standard: Run `#{command}` to #{sales_pitch}.
      MSG
    end
  end
end
