$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
begin
  require "simplecov"
  SimpleCov.start do
    add_filter "vendor"
  end
rescue LoadError
end

$LOAD_PATH << "test"

require "standard"
require "gimme"
require "minitest/autorun"

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

  def do_with_fake_io(fake_in = $stdin)
    og_stdin, og_stdout, og_stderr = $stdin, $stdout, $stderr
    fake_out, fake_err = StringIO.new, StringIO.new

    $stdin, $stdout, $stderr = fake_in, fake_out, fake_err
    result = yield
    $stdin, $stdout, $stderr = og_stdin, og_stdout, og_stderr

    [fake_out, fake_err, result]
  ensure
    $stdin, $stdout, $stderr = og_stdin, og_stdout, og_stderr
  end

  def standard_greeting
    Standard::Formatter::STANDARD_GREETING.chomp
  end
end
