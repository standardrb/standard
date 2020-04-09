require "test_helper"

class Standard::MergesSettingsTest < UnitTest
  def setup
    @subject = Standard::MergesSettings.new
  end

  def test_deletes_config_from_cli_flags
    result = @subject.call(["--config", "some-file"], {}, nil)

    assert_nil result.options[:config]
  end

  def test_default_command_is_runs_rubocop
    assert_equal :rubocop, @subject.call([], {}, nil).runner
  end

  def test_help_sets_command_to_help
    assert_equal :help, @subject.call(["--help"], {}, nil).runner
    assert_equal :help, @subject.call(["-h"], {}, nil).runner
  end

  def test_version_sets_command_to_version
    assert_equal :version, @subject.call(["--version"], {}, nil).runner
    assert_equal :version, @subject.call(["-v"], {}, nil).runner
  end

  def test_gen_ignore_sets_command_to_gen_ignore
    assert_equal :genignore, @subject.call(["--generate-todo"], {}, nil).runner
  end

  def test_fix_flag_sets_auto_correct_options
    options = @subject.call(["--fix"], {}, nil).options

    assert_equal options[:auto_correct], true
    assert_equal options[:safe_auto_correct], true
  end

  def test_no_fix_flag_inverts_auto_correct_options
    options = @subject.call(["--no-fix"], {}, nil).options

    assert_equal options[:auto_correct], false
    assert_equal options[:safe_auto_correct], false
  end

  def test_last_fix_flag_wins
    fix_options = @subject.call(["--no-fix", "--fix"], {}, nil).options
    no_fix_options = @subject.call(["--fix", "--no-fix"], {}, nil).options

    assert_equal fix_options[:auto_correct], true
    assert_equal fix_options[:safe_auto_correct], true
    assert_equal no_fix_options[:auto_correct], false
    assert_equal no_fix_options[:safe_auto_correct], false
  end

  def test_todo_file_option
    options = @subject.call([], {}, "path/to/todo.yml").options

    assert_equal "path/to/todo.yml", options[:todo_file]
  end
end
