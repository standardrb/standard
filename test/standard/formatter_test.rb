require_relative "../test_helper"

class Standard::FormatterTest < UnitTest
  Offense = Struct.new(:corrected?, :line, :real_column, :message, :cop_name)

  def setup
    @some_path = path("Gemfile")

    @io = StringIO.new
    @subject = Standard::Formatter.new(@io)
  end

  def test_no_offenses_prints_nothing
    @subject.file_finished(@some_path, [])
    @subject.finished([@some_path])

    assert_empty @io.string
  end

  def test_no_uncorrected_offenses_prints_nothing
    @subject.file_finished(@some_path, [Offense.new(true)])
    @subject.finished([@some_path])

    assert_empty @io.string
  end

  def test_no_uncorrected_offenses_with_todo_file_prints_todo_congratulations
    @subject = Standard::Formatter.new(@io, todo_file: ".standard_todo.yml", todo_ignore_files: [])
    @subject.file_finished(@some_path, [Offense.new(true)])
    @subject.file_finished("main.rb", [Offense.new(true)])
    @subject.finished([@some_path, "main.rb"])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      Congratulations, you've successfully migrated this project to Standard! Delete `.standard_todo.yml` in celebration.
    MESSAGE
  end

  def test_does_not_print_congratulations_if_offenses_were_detected
    @subject = Standard::Formatter.new(@io, todo_file: ".standard_todo.yml", todo_ignore_files: [])
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      #{standard_greeting}
      #{fixable_error_message}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_does_not_print_fix_command_if_run_with_fix
    @subject = Standard::Formatter.new(@io, safe_autocorrect: true)
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      #{standard_greeting}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_prints_uncorrected_offenses
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      #{standard_greeting}
      #{fixable_error_message}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_prints_header_and_fix_suggestion_exactly_once
    @subject.file_finished(@some_path, [Offense.new(false, 42, 12, "Yuck", "Lint/UselessAssignment")])
    @subject.file_finished(@some_path, [])
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.file_finished(@some_path, [Offense.new(false, 43, 14, "Super", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      #{standard_greeting}
        Gemfile:42:12: Yuck
      #{fixable_error_message}
        Gemfile:42:13: Neat
        Gemfile:43:14: Super
    MESSAGE
  end

  def test_prints_rake_message
    og_name = $PROGRAM_NAME
    $PROGRAM_NAME = "/usr/bin/rake"

    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      #{standard_greeting}
      #{fixable_error_message("rake standard:fix")}
        Gemfile:42:13: Neat
    MESSAGE

    $PROGRAM_NAME = og_name
  end

  def test_prints_call_for_feedback
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.file_finished(@some_path, [Offense.new(false, 43, 14, "Super", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      #{standard_greeting}
      #{fixable_error_message}
        Gemfile:42:13: Neat
        Gemfile:43:14: Super
    MESSAGE
  end

  def test_no_offenses_without_files
    @subject.finished([@some_path])

    assert_empty @io.string
  end

  def test_does_not_print_fix_command_if_offense_not_autocorrectable
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Lint/FlipFlop")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      #{standard_greeting}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_prints_todo_warning
    @subject = Standard::Formatter.new(@io, todo_file: ".standard_todo.yml", todo_ignore_files: %w[file1.rb file2.rb])
    @subject.started([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      WARNING: this project is being migrated to standard gradually via `.standard_todo.yml` and is ignoring these files:
        file1.rb
        file2.rb
    MESSAGE
  end

  def test_no_ignored_files_in_todo_file_prints_nothing
    @subject = Standard::Formatter.new(@io, todo_file: ".standard_todo.yml", todo_ignore_files: [])
    @subject.started([@some_path])

    assert_empty @io.string
  end
end
