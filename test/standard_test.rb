require "test_helper"

class StandardTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Standard::VERSION
  end
end
