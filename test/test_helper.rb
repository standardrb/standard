$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "simplecov"
SimpleCov.start

require "standard"
require "gimme"
require "minitest/autorun"
require "pry"

class UnitTest < Minitest::Test
  make_my_diffs_pretty!

  def self.path(relative)
    Pathname.new(Dir.pwd).join(relative).to_s
  end

  DEFAULT_RUBOCOP_CONFIG_STORE = RuboCop::ConfigStore.new.tap do |config_store|
    config_store.options_config = path("config/base.yml")
    options_config = config_store.instance_variable_get("@options_config")
    options_config["AllCops"]["TargetRubyVersion"] = RUBY_VERSION.to_f
  end.for("").to_h.freeze

  DEFAULT_STANDARD_CONFIG = {
    ruby_version: Gem::Version.new(RUBY_VERSION),
    fix: false,
    format: nil,
    parallel: false,
    ignore: [],
    default_ignores: true,
    config_root: "",
  }.freeze

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
