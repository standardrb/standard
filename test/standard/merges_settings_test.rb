require "test_helper"

class Standard::MergesSettingsTest < UnitTest
  def setup
    @subject = Standard::MergesSettings.new
  end

  def test_deletes_config_from_cli_flags
    result = @subject.call(["--config", "some-file"], {})

    assert_nil result.options[:config]
  end

  def test_default_command_is_runs_rubocop
    assert_equal :rubocop, @subject.call([], {}).runner
  end

  def test_help_sets_command_to_help
    assert_equal :help, @subject.call(["--help"], {}).runner
    assert_equal :help, @subject.call(["-h"], {}).runner
  end

  def test_version_sets_command_to_version
    assert_equal :version, @subject.call(["--version"], {}).runner
    assert_equal :version, @subject.call(["-v"], {}).runner
  end
end
