require "test_helper"
require "standard/helpers/autocorrectable"

class Standard::Helpers::AutocorrectableTest < UnitTest
  class MockClass
    include Standard::Helpers::Autocorrectable
  end

  Offense = Struct.new(:cop_name)

  def setup
    @subject = MockClass.new
  end

  def test_returns_false_when_offense_is_not_autocorrectable
    result = @subject.autocorrectable_offense?(Offense.new("Lint/UselessAssignment"))

    assert_equal(false, result)
  end

  def test_returns_true_when_offense_is_autocorrectable
    result = @subject.autocorrectable_offense?(Offense.new("Bundler/InsecureProtocolSource"))

    assert_equal(true, result)
  end
end
