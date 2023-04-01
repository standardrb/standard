require_relative "../test_helper"

class Standard::FormatterTest < UnitTest
  Offense = Struct.new(:corrected?, :line, :real_column, :message, :cop_name, :correctable?)

  def setup
    @some_path = path("Gemfile")

    @io = StringIO.new
    @subject = Standard::Formatter.new(@io)
  end

  def test_no_offenses_prints_nothing
    simulate_run([])

    assert_empty @io.string
  end

  def test_no_uncorrected_offenses_prints_nothing
    simulate_run([Offense.new(true)])

    assert_empty @io.string
  end

  def test_no_uncorrected_offenses_with_todo_file_prints_todo_congratulations
    @subject = Standard::Formatter.new(@io, todo_file: ".standard_todo.yml", todo_ignore_files: [])

    @subject.started([@some_path, "main.rb"])
    @subject.file_finished(@some_path, [Offense.new(true)])
    @subject.file_finished("main.rb", [Offense.new(true)])
    @subject.finished([@some_path, "main.rb"])

    assert_equal <<~MESSAGE, @io.string
      Congratulations, you've successfully migrated this project to Standard! Delete `.standard_todo.yml` in celebration.
    MESSAGE
  end

  def test_does_not_print_congratulations_if_offenses_were_detected
    @subject = Standard::Formatter.new(@io, todo_file: ".standard_todo.yml", todo_ignore_files: [])

    simulate_run([Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource", true)])

    assert_equal <<~MESSAGE, @io.string
      #{standard_greeting}
      #{fixable_error_message}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_suggests_unsafe_fix_when_correctable_and_safe_autocorrect_is_true
    @subject = Standard::Formatter.new(@io, autocorrect: true, safe_autocorrect: true)

    simulate_run([Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource", true)])

    assert_equal <<~MESSAGE, @io.string
      #{standard_greeting}
      #{fixable_error_message("standardrb --fix-unsafely")}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_does_not_print_fix_command_if_run_with_fix_unsafely
    @subject = Standard::Formatter.new(@io, autocorrect: true, safe_autocorrect: false)

    simulate_run([Offense.new(false, 42, 13, "Neat", "Bundler/SuperUnsafeIGuessBecauseThisShouldntBePossible", true)])

    assert_equal <<~MESSAGE, @io.string
      #{standard_greeting}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_prints_uncorrected_offenses
    simulate_run([Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource", true)])

    assert_equal <<~MESSAGE, @io.string
      #{standard_greeting}
      #{fixable_error_message}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_prints_header_and_fix_suggestion_exactly_once
    @subject.started([@some_path])
    @subject.file_finished(@some_path, [Offense.new(false, 42, 12, "Yuck", "Lint/UselessAssignment", false)])
    @subject.file_finished(@some_path, [])
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource", true)])
    @subject.file_finished(@some_path, [Offense.new(false, 43, 14, "Super", "Bundler/InsecureProtocolSource", true)])
    @subject.finished([@some_path])

    assert_equal <<~MESSAGE, @io.string
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

    simulate_run([Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource", true)])

    assert_equal <<~MESSAGE, @io.string
      #{standard_greeting}
      #{fixable_error_message("rake standard:fix")}
        Gemfile:42:13: Neat
    MESSAGE

    $PROGRAM_NAME = og_name
  end

  def test_prints_call_for_feedback
    @subject.started([@some_path])
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource", true)])
    @subject.file_finished(@some_path, [Offense.new(false, 43, 14, "Super", "Bundler/InsecureProtocolSource", true)])
    @subject.finished([@some_path])

    assert_equal <<~MESSAGE, @io.string
      #{standard_greeting}
      #{fixable_error_message}
        Gemfile:42:13: Neat
        Gemfile:43:14: Super
    MESSAGE
  end

  def test_no_offenses_without_files
    @subject.started([])
    @subject.finished([])

    assert_empty @io.string
  end

  def test_does_not_print_fix_command_if_offense_not_autocorrectable
    simulate_run([Offense.new(false, 42, 13, "Neat", "Lint/FlipFlop")])

    assert_equal <<~MESSAGE, @io.string
      #{standard_greeting}
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_prints_todo_warning
    @subject = Standard::Formatter.new(@io, todo_file: ".standard_todo.yml", todo_ignore_files: %w[file1.rb file2.rb])

    @subject.started([@some_path])

    assert_equal <<~MESSAGE, @io.string
      WARNING: this project is being migrated to standard gradually via `.standard_todo.yml` and is ignoring these files:
        file1.rb
        file2.rb
    MESSAGE
  end

  def test_no_ignored_files_in_todo_file_prints_no_todo_warning
    @subject = Standard::Formatter.new(@io, todo_file: ".standard_todo.yml", todo_ignore_files: [])

    @subject.started([@some_path])

    assert_empty @io.string
  end

  private

  def simulate_run(offenses)
    @subject.started([@some_path])
    @subject.file_finished(@some_path, offenses)
    @subject.finished([@some_path])
  end
end
