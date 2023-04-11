require_relative "../../test_helper"

require "standard/runners/genignore"
require "standard/runners/rubocop"

class Standard::Runners::GenignoreTest < UnitTest
  def setup
    @subject = Standard::Runners::Genignore.new
  end

  def test_todo_generated
    FileUtils.rm_rf("tmp/genignore_test")
    FileUtils.mkdir_p("tmp/genignore_test")
    FileUtils.cp_r("test/fixture/genignore/.", "tmp/genignore_test")

    Dir.chdir("tmp/genignore_test") do
      @subject.call(create_config("../../config/base.yml"))
    end

    assert File.exist?("tmp/genignore_test/.standard_todo.yml")

    expected_yaml = {"ignore" => [
      {"errors_one.rb" => ["Style/Documentation", "Style/FrozenStringLiteralComment", "Lint/AssignmentInCondition"]},
      {"errors_two.rb" => ["Lint/UselessAssignment", "Style/FrozenStringLiteralComment", "Style/StringLiterals"]}
    ]}
    assert_equal expected_yaml, YAML.load_file("tmp/genignore_test/.standard_todo.yml")
  end

  private

  def create_config(config_path)
    store = RuboCop::ConfigStore.new.tap do |config_store|
      config_store.options_config = config_path
    end

    Standard::Config.new(nil, ["."], {}, store)
  end
end
