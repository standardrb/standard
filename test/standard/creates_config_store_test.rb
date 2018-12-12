require "test_helper"

class Standard::CreatesConfigStoreTest < UnitTest
  def setup
    @subject = Standard::CreatesConfigStore.new
  end

  def test_minimal_config
    result = @subject.call(config({}))

    assert_equal DEFAULT_RUBOCOP_CONFIG_STORE, result.for("").to_h
  end

  private

  def config(props = {})
    DEFAULT_STANDARD_CONFIG.merge(props)
  end
end
