$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "simplecov"
SimpleCov.start

require "standard"
require "minitest/autorun"

begin
  require "pry"
rescue LoadError
end

class UnitTest < Minitest::Test
  make_my_diffs_pretty!

  def self.path(relative)
    Pathname.new(Dir.pwd).join(relative).to_s
  end

  def path(relative)
    self.class.path(relative)
  end
end
