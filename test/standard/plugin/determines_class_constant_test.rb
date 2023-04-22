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

      def test_require_path_is_required
        result = @subject.call("standard-base", {
          "enabled" => true,
          "require_path" => "standard/base",
          "plugin_class_name" => "Standard::Base::Plugin"
        })

        assert_equal Standard::Base::Plugin, result
      end

      class Foob
      end

      def test_require_path_can_be_nil
        result = @subject.call("foob", {
          "enabled" => true,
          "require_path" => nil,
          "plugin_class_name" => "Standard::Plugin::DeterminesClassConstantTest::Foob"
        })

        assert_equal Foob, result
      end

      def test_complains_when_not_a_gem_and_plugin_class_name_is_not_set
        error = assert_raises do
          @subject.call("incomplete", {
            "enabled" => true,
            "require_path" => nil,
            "plugin_class_name" => nil
          })
        end

        assert_equal <<~MSG.chomp, error.message
          Failed loading plugin `incomplete' because we couldn't determine
          the corresponding plugin class to instantiate.

          Standard plugin class names must either be:

            - If the plugin is a gem, defined in the gemspec as `default_lint_roller_plugin'

              spec.metadata["default_lint_roller_plugin"] = "MyModule::Plugin"

            - Set in YAML as `plugin_class_name'; example:

              plugins:
                - incomplete:
                    require_path: my_module/plugin
                    plugin_class_name: "MyModule::Plugin"

        MSG
      end

      def test_gem_metadata_is_used
        result = @subject.call("standard-performance", {})

        assert_equal Standard::Performance::Plugin, result
      end
    end
  end
end
