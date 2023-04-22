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
          "standard-base" => {
            "enabled" => true,
            "require_path" => "standard/base",
            "plugin_class_name" => "Standard::Base::Plugin"
          },
          "standard-custom" => StandardizesConfiguredPlugins::DEFAULT_PLUGIN_CONFIG.merge("require_path" => "standard-custom"),
          "standard-performance" => StandardizesConfiguredPlugins::DEFAULT_PLUGIN_CONFIG.merge("require_path" => "standard-performance"),
          "foo" => StandardizesConfiguredPlugins::DEFAULT_PLUGIN_CONFIG.merge("require_path" => "foo")
        }.to_a, result.to_a) # We are relying on insertion order here
      end
    end
  end
end
