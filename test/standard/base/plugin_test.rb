require_relative "../../test_helper"

module Standard::Base
  class PluginTest < UnitTest
    def setup
      require "standard/base/plugin" # <-- This is actually loaded during plugin configuration
      @subject = Plugin.new({})
    end

    def test_paths
      assert_match "base.yml", @subject.rules(LintRoller::Context.new(target_ruby_version: "3.2.1")).value.to_s
      assert_match "ruby-2.7.yml", @subject.rules(LintRoller::Context.new(target_ruby_version: Gem::Version.new("2.8.2"))).value.to_s
      assert_match "ruby-1.9.yml", @subject.rules(LintRoller::Context.new(target_ruby_version: Gem::Version.new("1.9.3"))).value.to_s
    end
  end
end
