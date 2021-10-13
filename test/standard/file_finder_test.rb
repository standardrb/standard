require_relative "../test_helper"

class Standard::FileFinderTest < UnitTest
  def setup
    @some_path = path("test/fixture/file_finder/b/c")

    @subject = Standard::FileFinder.new
  end

  def test_finds_nothing_given_nonsense
    result = @subject.call("lol", @some_path)

    assert_nil result
  end

  def test_finds_up_the_closest_file
    result = @subject.call("file.neat", @some_path)

    assert_match %r{test/fixture/file_finder/b/file.neat}, result
  end

  def test_finds_up_grandparent
    result = @subject.call("file.meh", @some_path)

    assert_match %r{test/fixture/file_finder/file.meh}, result
  end
end
