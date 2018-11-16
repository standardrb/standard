require "test_helper"

class Standard::ConfigTest < UnitTest
  DEFAULT_OPTIONS = {
    auto_correct: false,
    safe_auto_correct: false,
    formatters: [["Standard::Formatter", nil]],
    parallel: false,
  }.freeze

  DEFAULT_CONFIG = RuboCop::ConfigStore.new.tap do |config_store|
    # FYI: This is going to load the real .standard.yml of this project, which
    #      targets 2.2, therefore that one gets loaded when we pass nothing.
    config_store.options_config = Pathname.new(Dir.pwd).join("config/ruby-2.2.yml")
  end.for("").to_h.freeze

  def setup
  end

  def test_no_argv_and_no_standard_dot_yml
    @subject = Standard::Config.new([])

    result = @subject.to_rubocop

    assert_equal DEFAULT_OPTIONS, result.options
    assert_equal DEFAULT_CONFIG, result.config_store.for("").to_h
  end
end
