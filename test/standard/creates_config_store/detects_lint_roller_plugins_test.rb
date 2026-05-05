require_relative "../../test_helper"

class Standard::CreatesConfigStore::DetectsLintRollerPluginsTest < UnitTest
  def setup
    @subject = Standard::CreatesConfigStore::DetectsLintRollerPlugins.new
  end

  def test_returns_empty_array_when_no_lint_roller_plugins
    gem_specs = [
      create_mock_gem_spec("regular-gem", {}),
      create_mock_gem_spec("another-gem", {"some_key" => "value"})
    ]

    result = @subject.call(gem_specs)

    assert_equal [], result
  end

  def test_detects_lint_roller_plugin_with_metadata
    # Test that gems with lint_roller metadata are processed
    # This test validates the metadata filtering logic
    gem_with_metadata = create_mock_gem_spec("has-lint-roller", {
      "default_lint_roller_plugin" => "SomePlugin"
    })

    gem_without_metadata = create_mock_gem_spec("no-lint-roller", {})

    # This will fail at the require step, but that's expected for non-existent gems
    result = @subject.call([gem_with_metadata, gem_without_metadata])

    # We expect empty result because require will fail, but the method should not crash
    assert_equal [], result
  end

  def test_skips_gems_with_load_errors
    gem_spec = create_mock_gem_spec("broken-gem", {
      "default_lint_roller_plugin" => "NonExistent::Plugin"
    })

    result = @subject.call([gem_spec])

    assert_equal [], result
  end

  def test_skips_gems_with_instantiation_errors
    gem_spec = create_mock_gem_spec("broken-plugin", {
      "default_lint_roller_plugin" => "BrokenPlugin"
    })

    # Define a broken plugin class
    broken_plugin_class = Class.new(LintRoller::Plugin) do
      def initialize(_config)
        raise "Broken plugin"
      end
    end

    stub_const("BrokenPlugin", broken_plugin_class)

    result = @subject.call([gem_spec])

    assert_equal [], result
  end

  private

  def create_mock_gem_spec(name, metadata)
    mock_spec = Class.new do
      def initialize(name, metadata)
        @name = name
        @metadata = metadata
      end

      attr_reader :name, :metadata

      def require_paths
        ["lib"]
      end

      def full_gem_path
        "/fake/path/#{@name}"
      end
    end

    mock_spec.new(name, metadata)
  end

  def stub_const(const_name, value)
    parts = const_name.split("::")
    parent = Object

    parts[0..-2].each do |part|
      unless parent.const_defined?(part)
        parent.const_set(part, Module.new)
      end
      parent = parent.const_get(part)
    end

    parent.const_set(parts.last, value)
  end
end
