require_relative "test_helper"

class StandardTest < UnitTest
  def test_loads_stuff
    refute_nil RuboCop
    refute_nil Standard::Cli
    refute_nil RuboCop::Cop::Standard::BlockSingleLineBraces
    assert_instance_of Gem::Version, ::Standard::VERSION
  end
end
