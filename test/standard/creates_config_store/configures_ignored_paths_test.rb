require_relative "../../test_helper"

class Standard::CreatesConfigStore::ConfiguresIgnoredPathsTest < UnitTest
  def setup
    @subject = Standard::CreatesConfigStore::ConfiguresIgnoredPaths.new
  end

  def test_leaves_existing_excludes_alone
    options_config = {"AllCops" => {"Exclude" => ["foo"]}}

    @subject.call(options_config, {
      ignore: [],
      default_ignores: true
    })

    assert_equal(
      {"AllCops" => {"Exclude" => [File.expand_path(File.join(Dir.pwd, "foo"))]}},
      options_config
    )
  end

  def test_leaves_missing_excludes_alone
    options_config = {}

    @subject.call(options_config, {
      ignore: [],
      default_ignores: true
    })

    assert_equal({}, options_config)
  end

  def test_defaults_with_config_file_defined_somewhere_in_the_ancestry
    options_config = {"AllCops" => {"Exclude" => ["foo"]}}

    @subject.call(options_config, {
      ignore: [],
      default_ignores: true,
      config_root: "/hi/project"
    })

    assert_equal(
      {"AllCops" => {"Exclude" => ["/hi/project/foo"]}},
      options_config
    )
  end

  def test_disabled_default_ignores
    options_config = {
      "AllCops" => {"Exclude" => ["foo"]}
    }

    @subject.call(options_config, {
      ignore: [],
      default_ignores: false
    })

    assert_equal({"AllCops" => {"Exclude" => []}}, options_config)
  end

  def test_absolute_path
    options_config = {}

    @subject.call(options_config, {
      ignore: [["/foo/bar/baz/**/*", ["AllCops"]]],
      default_ignores: false
    })

    assert_equal({
      "AllCops" => {
        "Exclude" => ["/foo/bar/baz/**/*"]
      }
    }, options_config)
  end
end
