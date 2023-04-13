require "test_helper"

module Standard
  module Plugin
    class DeterminesClassConstantTest < UnitTest
      def setup
        @subject = DeterminesClassConstant.new
      end

      class SomePlugin < LintRoller::Plugin
      end

      def test_custom_class_name_goes_great
        result = @subject.call("doesnt_matter", {"plugin_class_name" => "Standard::Plugin::DeterminesClassConstantTest::SomePlugin"})

        assert_equal SomePlugin, result
      end

      def test_custom_class_name_goes_sideways
        error = assert_raises {
          @subject.call("doesnt_matter", {"plugin_class_name" => "Standard::Plugin::DeterminesClassConstantTest::NotAThing"})
        }

        assert_equal "Failed while configuring plugin `doesnt_matter': no constant with name `Standard::Plugin::DeterminesClassConstantTest::NotAThing' was found", error.message
      end

      def test_gem_metadata_is_used
        result = @subject.call("standard-performance", {})

        assert_equal Standard::Performance::Plugin, result
      end

      def test_gem_metadata_lookup_failure_cases
        assert_equal "Failed while configuring plugin `not-a-gem'. LoadError: cannot load such file -- not-a-gem", assert_raises {
          @subject.call("not-a-gem", {})
        }.message

        assert_match "Failed while configuring plugin `lint_roller'. TypeError", assert_raises {
          @subject.call("lint_roller", {})
        }.message
      end
    end
  end
end
