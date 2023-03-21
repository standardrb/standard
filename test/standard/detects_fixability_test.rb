require_relative "../test_helper"

class Standard::DetectsFixabilityTest < UnitTest
  Offense = Struct.new(:cop_name)

  def setup
    @subject = Standard::DetectsFixability.new
  end

  def test_returns_false_when_offense_is_not_autocorrectable
    result = @subject.call([Offense.new("Lint/UselessAssignment")])

    assert_equal(false, result)
  end

  def test_returns_true_when_offense_is_autocorrectable
    result = @subject.call([Offense.new("Bundler/InsecureProtocolSource")])

    assert_equal(true, result)
  end

  def test_returns_false_when_offense_autocorrection_is_unsafe
    result = @subject.call([Offense.new("Lint/BooleanSymbol")])

    assert_equal(false, result)
  end

  def test_can_find_a_config_option_for_everything_we_prescribe_with_asploding
    our_cop_names = YAML.load_file("config/base.yml").keys - ["AllCops", "require"]

    result = @subject.call(our_cop_names.map { |cop_name| Offense.new(cop_name) })

    assert_equal(true, result)
  end
end
