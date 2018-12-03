require "test_helper"

require "standard/runners/version"

class Standard::Runners::VersionTest < UnitTest
  def setup
    @subject = Standard::Runners::Version.new
  end

  def test_prints_help
    fake_out, _ = do_with_fake_io {
      @subject.call(nil)
    }

    assert_equal Standard::VERSION.to_s, fake_out.string.chomp
  end
end
