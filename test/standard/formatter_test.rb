require "test_helper"

class Standard::FormatterTest < UnitTest
  Offense = Struct.new(:corrected?, :line, :real_column, :message)
  class FauxIO < StringIO
    def read
      rewind
      super
    end
  end

  def setup
    @some_path = path("Gemfile")

    @io = FauxIO.new
    @subject = Standard::Formatter.new(@io)
  end

  def test_no_offenses_prints_nothing
    @subject.file_finished(@some_path, [])

    assert_empty @io.read
  end

  def test_no_uncorrected_offenses_prints_nothing
    @subject.file_finished(@some_path, [Offense.new(true)])

    assert_empty @io.read
  end

  def test_prints_uncorrected_offenses
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat")])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.read
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `standard --fix` to automatically fix some problems.
        Gemfile:42:13: Neat
    MESSAGE
  end

  def test_prints_header_only_once
    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat")])
    @subject.file_finished(@some_path, [Offense.new(false, 43, 14, "Super")])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.read
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `standard --fix` to automatically fix some problems.
        Gemfile:42:13: Neat
        Gemfile:43:14: Super
    MESSAGE
  end

  def test_prints_rake_message
    og_name = $PROGRAM_NAME
    $PROGRAM_NAME = "/usr/bin/rake"

    @subject.file_finished(@some_path, [Offense.new(false, 42, 13, "Neat")])

    assert_equal <<-MESSAGE.gsub(/^ {6}/, ""), @io.read
      standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
      standard: Run `rake standard:fix` to automatically fix some problems.
        Gemfile:42:13: Neat
    MESSAGE

    $PROGRAM_NAME = og_name
  end
end
