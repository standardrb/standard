require "test_helper"

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

  def test_does_not_print_fix_command_if_run_with_fix
    @subject = Standard::Formatter.new(@io, auto_correct: true, safe_auto_correct: true)
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
        Gemfile:42:13: Neat

      #{call_to_action_message}
    MESSAGE
  end

  def test_prints_uncorrected_offenses
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `standardrb --fix` to automatically fix some problems.
        Gemfile:42:13: Neat

      #{call_to_action_message}
    MESSAGE
  end

  def test_prints_header_and_fix_suggestion_exactly_once
    @subject.file_finished(@some_path, [Offense.new(false, 42, 12, "Yuck", "Lint/UselessAssignment")])
    @subject.file_finished(@some_path, [])
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.file_finished(@some_path, [Offense.new(false, 43, 14, "Super", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
        Gemfile:42:12: Yuck
      standard: Run `standardrb --fix` to automatically fix some problems.
        Gemfile:42:13: Neat
        Gemfile:43:14: Super

      #{call_to_action_message}
    MESSAGE
  end

  def test_prints_rake_message
    og_name = $PROGRAM_NAME
    $PROGRAM_NAME = "/usr/bin/rake"

    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `rake standard:fix` to automatically fix some problems.
        Gemfile:42:13: Neat

      #{call_to_action_message}
    MESSAGE

    $PROGRAM_NAME = og_name
  end

  def test_prints_call_for_feedback
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Bundler/InsecureProtocolSource")])
    @subject.file_finished(@some_path, [Offense.new(false, 43, 14, "Super", "Bundler/InsecureProtocolSource")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `standardrb --fix` to automatically fix some problems.
        Gemfile:42:13: Neat
        Gemfile:43:14: Super

      #{call_to_action_message}
    MESSAGE
  end

  def test_no_offenses_without_files
    @subject.finished([@some_path])

    assert_empty @io.string
  end

  def test_does_not_print_fix_command_if_offense_not_autocorrectable
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat", "Lint/UselessAssignment")])
    @subject.finished([@some_path])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.string
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
        Gemfile:42:13: Neat

      #{call_to_action_message}
    MESSAGE
  end

  def test_prints_todo_warning
    mock_options = {todo_file: ".standard_todo.yml", todo_ignore_files: %w[file1.rb file2.rb]}
    @subject.stub :options, mock_options do
      @subject.finished([@some_path])

      assert_equal <<-MESSAGE.gsub(/^ {8}/, ""), @io.string
        WARNING: this project is being migrated to standard gradually via `.standard_todo.yml` and is ignoring these files:
          file1.rb
          file2.rb
      MESSAGE
    end
  end

  private

  def call_to_action_message
    Standard::Formatter::CALL_TO_ACTION_MESSAGE.chomp
  end
end
