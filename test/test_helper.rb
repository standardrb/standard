$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "simplecov"
SimpleCov.start
SimpleCov.start do
  add_filter "vendor"
end

require "standard"
require "gimme"
require "minitest/autorun"
require "pry"

class UnitTest < Minitest::Test
  make_my_diffs_pretty!

  def self.path(relative)
    Pathname.new(Dir.pwd).join(relative).to_s
  end

  def setup
    # Rubocop will cache and reuse the current working directory, which can
    # be different the actual working directory.  This can mess up tests that
    # use the quite/simple formatter as they can write out either relative or
    # absolute paths.  This is not in the Rubocop documentation but can be
    # found in this PR:
    #
    # https://github.com/rubocop-hq/rubocop/pull/262#issuecomment-19265766
    #
    # This forces RuboCop to use current working directory.
    RuboCop::PathUtil.reset_pwd
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
end
