require "test_helper"

module Standard
  module Plugin
    class StandardizesConfiguredPluginsTest < UnitTest
      def setup
        @subject = StandardizesConfiguredPlugins.new
      end

      def test_basic
        result = @subject.call(["foo"])

        assert_equal({
          Standard::Base::Plugin => StandardizesConfiguredPlugins::DEFAULT_PLUGIN_CONFIG,
          "standard-performance" => StandardizesConfiguredPlugins::DEFAULT_PLUGIN_CONFIG,
          "foo" => StandardizesConfiguredPlugins::DEFAULT_PLUGIN_CONFIG
        }.to_a, result.to_a) # We are relying on insertion order here
      end

      def test_disables_and_reorders_performance
        result = @subject.call(["foo", {"standard-performance" => {"enabled" => false, "other" => "stuff"}}])

        assert_equal({
          Standard::Base::Plugin => StandardizesConfiguredPlugins::DEFAULT_PLUGIN_CONFIG,
          "foo" => StandardizesConfiguredPlugins::DEFAULT_PLUGIN_CONFIG,
          "standard-performance" => {"enabled" => false, "plugin_class_name" => nil, "other" => "stuff"}
        }.to_a, result.to_a) # We are relying on insertion order here
      end
    end
  end
end
