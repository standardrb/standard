require "test_helper"

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

    expected_yaml = {"ignore" => %w[errors_one.rb errors_two.rb]}

    Dir.chdir("tmp/genignore_test") do
      @subject.call(create_config)
    end

    assert_equal true, File.exist?("tmp/genignore_test/.standard_todo.yml")
    assert_equal expected_yaml, YAML.load_file("tmp/genignore_test/.standard_todo.yml")
  end

  private

  def create_config
    Standard::Config.new(nil, ["."], {}, RuboCop::ConfigStore.new)
  end
end
