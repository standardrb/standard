require_relative "../../test_helper"
require "cop_invoker"

class RuboCop::Cop::Standard::BlockSingleLineBracesTest < UnitTest
  include CopInvoker

  def setup
    config = RuboCop::Config.new("Standard/BlockSingleLineBraces" => {
      "Enabled" => true
    })
    @cop = RuboCop::Cop::Standard::BlockSingleLineBraces.new(config)
  end

  def test_single_line_with_braces
    assert_no_offense @cop, <<-RUBY
      result = [:a].map { |arg| arg }
    RUBY
  end

  def test_single_line_with_do_end
    assert_offense @cop, <<-RUBY
      result = [:a].map do |arg| arg end
                        ^^ Prefer `{...}` over `do...end` for single-line blocks.
    RUBY

    assert_correction @cop, <<-RUBY
      result = [:a].map { |arg| arg }
    RUBY
  end

  def test_multiline_with_braces
    assert_no_offense @cop, <<-RUBY
      lulz = [:a].map {
        :lol
      }
    RUBY
  end

  def test_multiline_with_do_end
    assert_no_offense @cop, <<-RUBY
      lulz = [:a].map do
        :lol
      end
    RUBY
  end

  def test_braces_with_rescue_does_not_fail
    assert_no_offense @cop, <<-RUBY
      lulz = [:a].map do
        :lol
      rescue StandardError
        :nolol
      end
    RUBY
  end
end
