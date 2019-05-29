require "test_helper"
require "cop_invoker"

class RuboCop::Cop::Standard::SemanticBlocksTest < UnitTest
  include CopInvoker

  def setup
    standard_config = YAML.load_file("config/base.yml")["Standard/SemanticBlocks"]
    config = RuboCop::Config.new("Standard/SemanticBlocks" => standard_config.merge(
      "Enabled" => true
    ))
    @cop = RuboCop::Cop::Standard::SemanticBlocks.new(config)
  end

  def test_do_end_with_assignment_fails
    assert_offense @cop, <<-RUBY
      lulz = [:a].map do
                      ^^ Prefer `{...}` over `do...end` for functional blocks.
        :lol
      end
    RUBY

    assert_correction @cop, <<-RUBY
      lulz = [:a].map {
        :lol
      }
    RUBY
  end

  def test_braces_with_assignment_passes
    assert_no_offense @cop, <<-RUBY
      lulz = [:a].map {
        :lol
      }
    RUBY
  end

  def test_braces_with_side_effect_fails
    assert_offense @cop, <<-RUBY
      42.tap {
             ^ Prefer `do...end` over `{...}` for procedural blocks.
        puts "cool"
      }
    RUBY

    assert_correction @cop, <<-RUBY
      42.tap do
        puts "cool"
      end
    RUBY
  end

  def test_do_end_with_side_effect_passes
    assert_no_offense @cop, <<-RUBY
      42.tap do
        puts "cool"
      end
    RUBY
  end

  def test_lonely_chains_are_functional
    assert_no_offense @cop, <<-RUBY
      CONCENTRATION.find { |end_date, _threshold|
        end_date >= Time.zone.today
      }&.last || 0
    RUBY
  end
end
