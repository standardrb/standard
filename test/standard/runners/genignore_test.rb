require "test_helper"

require "standard/runners/genignore"
require "standard/runners/rubocop"

class Standard::Runners::GenignoreTest < UnitTest
  def setup
    super

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

    expected_yaml = {"ignore" => %w[errors_one.rb errors_two.rb]}
    assert_equal expected_yaml, YAML.load_file("tmp/genignore_test/.standard_todo.yml")
  end

  private

  def create_config(config_path)
    store = RuboCop::ConfigStore.new.tap do |config_store|
      config_store.options_config = config_path

      # Simulate a `.standard_todo.yml` that contains an ignore file:
      #
      #   ---
      #   ignore:
      #     - errors_one.rb
      #
      options_config = config_store.instance_variable_get("@options_config")
      options_config["AllCops"] ||= []
      options_config["AllCops"]["Exclude"] ||= []
      options_config["AllCops"]["Exclude"] |= [path("errors_one.rb")]
    end

    Standard::Config.new(nil, ["."], {}, store)
  end
end
