require_relative "../../test_helper"

require "standard/runners/verbose_version"

class Standard::Runners::VerboseVersionTest < UnitTest
  def setup
    @subject = Standard::Runners::VerboseVersion.new
  end

  def test_verbose_version
    fake_out, _ = do_with_fake_io {
      @subject.call(nil)
    }

    expect = <<~EXPECT
      Standard version: #{Standard::VERSION}
      RuboCop version:  #{RuboCop::Version.version(debug: true)}
    EXPECT

    assert_equal expect, fake_out.string
  end

  def test_includes_rubocop_sub_dependencies
    fake_out, _ = do_with_fake_io {
      @subject.call(nil)
    }

    assert_match(/Parser/, fake_out.string)
    assert_match(/rubocop-ast/, fake_out.string)
  end
end
