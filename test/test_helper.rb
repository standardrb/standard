$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "standard"
require "minitest/autorun"

begin
  require "pry"
rescue LoadError
end

class UnitTest < Minitest::Test
end
