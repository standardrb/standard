require_relative "../../test_helper"

class Standard::Plugin::MergesPluginsIntoRubocopConfigTest < UnitTest
  def setup
    @subject = Standard::Plugin::MergesPluginsIntoRubocopConfig.new
  end

  class ObjectyPlugin < LintRoller::Plugin
    def initialize(yaml_hash)
      @yaml_hash = yaml_hash
    end

    def rules(context)
      LintRoller::Rules.new(
        type: :object,
        config_format: :rubocop,
        value: @yaml_hash
      )
    end
  end

  class PathyPlugin < LintRoller::Plugin
    def initialize(yaml_path)
      @yaml_path = yaml_path
    end

    def rules(context)
      LintRoller::Rules.new(
        type: :path,
        config_format: :rubocop,
        value: @yaml_path
      )
    end
  end

  class ErroryPlugin < LintRoller::Plugin
    def initialize(error)
      @error = error
    end

    def about
      LintRoller::About.new(name: "Broken Plugin")
    end

    def rules(context)
      LintRoller::Rules.new(
        type: :error,
        config_format: :rubocop,
        value: @error
      )
    end
  end

  module RuboCop::Cop
    module Fake
      class Things < RuboCop::Cop::Cop
      end

      class Stuff < RuboCop::Cop::Cop
      end

      class Junk < RuboCop::Cop::Cop
      end

      class Crap < RuboCop::Cop::Cop
      end
    end
  end

  def test_doesnt_change_config_when_no_plugins_defined
    options_config = RuboCop::Config.new({
      "AllCops" => {}
    }, "")

    @subject.call(options_config, {}, [], permit_merging: true)

    assert_equal({
      "AllCops" => {}
    }, options_config.to_h)
  end

  def test_accepts_both_object_and_path_plugins_and_first_in_wins_without_merge
    options_config = RuboCop::Config.new({
      "AllCops" => {}
    }, "")

    @subject.call(options_config, {}, [
      PathyPlugin.new("test/fixture/plugins/rules.yml"),
      ObjectyPlugin.new("Fake/Things" => {"Enabled" => true, "Dingus" => "never", "Really" => false}, "Fake/Junk" => {"Enabled" => false}),
      ObjectyPlugin.new("Fake/Crap" => {"Enabled" => true})
    ], permit_merging: true)

    assert_equal({
      "AllCops" => {},
      "Fake/Stuff" => {"Enabled" => true, "Plumbus" => "schleem"},
      "Fake/Things" => {"Enabled" => false, "Dingus" => "always"},
      "Fake/Junk" => {"Enabled" => false},
      "Fake/Crap" => {"Enabled" => true}
    }, options_config.to_h)
  end

  def test_handles_plugin_errors
    error = assert_raises do
      @subject.call(RuboCop::Config.new({}), {}, [ErroryPlugin.new(StandardError.new("I'm a bad plugin"))], permit_merging: true)
    end

    assert_equal <<~MSG.chomp, error.message
      Plugin `Broken Plugin' failed to load with error: I'm a bad plugin
    MSG
  end

  def test_handles_plugin_error_strings_too
    error = assert_raises do
      @subject.call(RuboCop::Config.new({}), {}, [ErroryPlugin.new("I'm worse")], permit_merging: true)
    end

    assert_equal <<~MSG.chomp, error.message
      Plugin `Broken Plugin' failed to load with error: I'm worse
    MSG
  end

  def test_that_first_person_to_set_a_rule_cant_have_the_nested_attributes_overridden
    options_config = RuboCop::Config.new({
      "AllCops" => {},
      "Breakfast/Eggs" => {
        "Enabled" => false,
        "EnforcedStyle" => "over_easy"
      }
    }, "")

    @subject.call(options_config, {}, [
      ObjectyPlugin.new(
        "Breakfast/Eggs" => {
          "Enabled" => true,
          "EnforcedStyle" => "scrambled"
        }
      ),
      ObjectyPlugin.new(
        "Breakfast/Eggs" => {
          "EnforcedStyle" => "poached"
        }
      ),
      ObjectyPlugin.new(
        "Breakfast/Eggs" => {
          "Salt" => true
        }
      )
    ], permit_merging: true)

    assert_equal({
      "AllCops" => {},
      "Breakfast/Eggs" => {
        "Enabled" => true,
        "EnforcedStyle" => "scrambled"
      }
    }, options_config.to_h)
  end

  def test_that_first_person_to_set_an_allcop_setting_wins_it_but_not_disallowed_ones
    options_config = RuboCop::Config.new({
      "AllCops" => {
        "A" => "a",
        "B" => "b"
      }
    }, "")

    @subject.call(options_config, {}, [
      ObjectyPlugin.new("AllCops" => {"A" => "a1", "B" => "b1", "C" => "c1"}),
      ObjectyPlugin.new("AllCops" => {"A" => "a2", "B" => "b2", "C" => "c2", "D" => "d2"}),
      ObjectyPlugin.new("AllCops" => {"E" => "e3"})
    ], permit_merging: true)

    assert_equal({
      "AllCops" => {"A" => "a1", "B" => "b1", "C" => "c1", "D" => "d2", "E" => "e3"}
    }, options_config.to_h)
  end

  def test_that_all_cops_arrays_are_concated_but_rule_arrays_are_overwritten
    options_config = RuboCop::Config.new({
      "AllCops" => {
        "fruits" => ["apple"]
      },
      "Some/Rule" => {
        "candies" => ["chocolate"]
      }
    }, "")

    @subject.call(options_config, {}, [
      ObjectyPlugin.new("AllCops" => {"fruits" => ["banana"]}),
      ObjectyPlugin.new("AllCops" => {"nuts" => []}),
      ObjectyPlugin.new("AllCops" => {"fruits" => []}, "Some/Rule" => {"candies" => ["lollipop"]}),
      ObjectyPlugin.new("AllCops" => {"fruits" => ["tomato", "orange"]}),
      ObjectyPlugin.new("AllCops" => {"nuts" => ["cashew"]}, "Some/Rule" => {"candies" => ["suckers", "gum"]}),
      ObjectyPlugin.new("AllCops" => {"nuts" => ["peanut", "cashew"]})
    ], permit_merging: true)

    assert_equal({
      "AllCops" => {
        "fruits" => ["apple", "banana", "tomato", "orange"],
        "nuts" => ["cashew", "peanut"]
      },
      "Some/Rule" => {
        "candies" => ["lollipop"]
      }
    }, options_config.to_h)
  end
end
