require "test_helper"

class Standard::CreatesConfigStore::ConfiguresIgnoredPathsTest < UnitTest
  def setup
    @subject = Standard::CreatesConfigStore::ConfiguresIgnoredPaths.new
  end

  def test_defaults
    options_config = OpenStruct.new

    @subject.call(options_config, {ignore: [], config_root: nil})

    assert_equal({
      AllCops: {
        "Exclude" => [
          "node_modules/**/*",
          "vendor/**/*",
          ".git/**/*",
          "bin/*",
          "tmp/**/*",
        ].map { |path| File.expand_path(File.join(Dir.pwd, path)) },
      },
    }, options_config.to_h)
  end

  def test_defaults_with_config_file_defined_somewhere_in_the_ancestry
    options_config = OpenStruct.new

    @subject.call(options_config, {ignore: [], config_root: "/hi/project"})

    assert_equal({
      AllCops: {
        "Exclude" => [
          "/hi/project/node_modules/**/*",
          "/hi/project/vendor/**/*",
          "/hi/project/.git/**/*",
          "/hi/project/bin/*",
          "/hi/project/tmp/**/*",
        ],
      },
    }, options_config.to_h)
  end
end
