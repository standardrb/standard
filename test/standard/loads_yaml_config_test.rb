require "test_helper"

class Standard::LoadsYamlConfigTest < UnitTest
  def setup
    @subject = Standard::LoadsYamlConfig.new
  end

  def test_no_file
    result = @subject.call([], "/")

    assert_equal(DEFAULT_STANDARD_CONFIG, result)
  end
end
