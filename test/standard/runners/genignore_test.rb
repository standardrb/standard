require_relative "../../test_helper"

require "standard/runners/genignore"
require "standard/runners/rubocop"

class Standard::Runners::GenignoreTest < UnitTest
  def setup
    @subject = Standard::Runners::Genignore.new
  end

  def test_todo_generated
    FileUtils.rm_rf("dont_call_it_tmp/genignore_test")
    FileUtils.mkdir_p("dont_call_it_tmp/genignore_test")
    FileUtils.cp_r("test/fixture/genignore/.", "dont_call_it_tmp/genignore_test")

    Dir.chdir("dont_call_it_tmp/genignore_test") do
      config = Standard::BuildsConfig.new.call(["--config", "../../config/base.yml"])
      @subject.call(config)
    end

    assert File.exist?("dont_call_it_tmp/genignore_test/.standard_todo.yml")

    expected_yaml = {"ignore" => [
      {"errors_one.rb" => ["Lint/AssignmentInCondition"]},
      {"errors_two.rb" => ["Lint/UselessAssignment"]}
    ]}
    assert_equal expected_yaml, YAML.load_file("dont_call_it_tmp/genignore_test/.standard_todo.yml")
  ensure
    FileUtils.rm_rf("dont_call_it_tmp")
  end
end
