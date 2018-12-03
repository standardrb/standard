require "test_helper"

class Standard::MergesSettingsTest < UnitTest
  def setup
    @subject = Standard::MergesSettings.new
  end

  def test_deletes_config_from_cli_flags
    result = @subject.call(["--config", "some-file"], {})

    assert_nil result.options[:config]
  end
end
