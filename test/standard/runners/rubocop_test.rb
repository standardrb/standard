require "test_helper"

require "standard/runners/rubocop"
require "fixture/runner/bad_cop"

class Standard::Runners::RubocopTest < UnitTest
  DEFAULT_OPTIONS = {
    formatters: [["quiet", nil]]
  }.freeze

  def setup
    @subject = Standard::Runners::Rubocop.new
  end

  def test_empty_output_on_quiet_success
    fake_out, fake_err = do_with_fake_io {
      @subject.call(create_config)
    }

    assert_equal "", fake_out.string
    assert_equal "", fake_err.string
  end

  def test_error_output_on_cop_error
    RuboCop::Cop::Standard::BadCop.send(:define_method, :on_send) { |_| raise "hell" }

    fake_out, fake_err = do_with_fake_io {
      @subject.call(create_config(
        only: ["Standard/BadCop"]
      ))
    }

    assert_equal "", fake_out.string
    assert_match(/An error occurred while Standard\/BadCop cop was inspecting/, fake_err.string)

    RuboCop::Cop::Standard::BadCop.send(:define_method, :on_send) { |_| }
  end

  def test_print_corrected_output_on_stdin
    fake_out, fake_err = do_with_fake_io {
      @subject.call(create_config(
        auto_correct: true,
        safe_auto_correct: true,
        stdin: "def Foo;'hi'end\n"
      ))
    }

    expected_out = <<-OUT.gsub(/^ {6}/, "")
      == test/fixture/runner/agreeable.rb ==
      C:  1:  1: Style/FrozenStringLiteralComment: Missing frozen string literal comment.
      C:  1:  1: [Corrected] Style/SingleLineMethods: Avoid single-line method definitions.
      C:  1:  5: Naming/MethodName: Use snake_case for method names.
      C:  1:  8: [Corrected] Layout/SpaceAfterSemicolon: Space missing after semicolon.
      C:  1:  8: [Corrected] Style/Semicolon: Do not use semicolons to terminate expressions.
      C:  1:  9: [Corrected] Layout/TrailingWhitespace: Trailing whitespace detected.

      1 file inspected, 6 offenses detected, 4 offenses corrected
      ====================
      def Foo
        'hi'
      end
    OUT
    assert_equal expected_out, fake_out.string
    assert_equal "", fake_err.string
  end

  private

  def create_config(options = {}, path = "test/fixture/runner/agreeable.rb")
    Standard::Config.new(nil, [path], DEFAULT_OPTIONS.merge(options),
      RuboCop::ConfigStore.new)
  end
end
