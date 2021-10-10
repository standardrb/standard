$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
begin
  require "simplecov"
  SimpleCov.start
  SimpleCov.start do
    add_filter "vendor"
  end
rescue LoadError
end

$LOAD_PATH << "test"

require "standard"
require "gimme"
require "minitest/autorun"
require "pry"

class UnitTest < Minitest::Test
  make_my_diffs_pretty!

  def self.path(relative)
    Pathname.new(Dir.pwd).join(relative).to_s
  end

  def teardown
    Gimme.reset
  end

  protected

  def path(relative)
    self.class.path(relative)
  end

  def do_with_fake_io
    og_stdout, og_stderr = $stdout, $stderr
    fake_out, fake_err = StringIO.new, StringIO.new

    $stdout, $stderr = fake_out, fake_err
    result = yield
    $stdout, $stderr = og_stdout, og_stderr

    [fake_out, fake_err, result]
  ensure
    $stdout, $stderr = og_stdout, og_stderr
  end

  def standard_greeting
    Standard::Formatter::STANDARD_GREETING.chomp
  end

  def fixable_error_message(command = "standardrb --fix")
    Standard::Formatter.fixable_error_message(command).chomp
  end
end
