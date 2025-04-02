module Standard
  module RakeSupport
    # Allow command line flags set in STANDARDOPTS (like MiniTest's TESTOPTS)
    def self.argvify
      if ENV["STANDARDOPTS"]
        ENV["STANDARDOPTS"].split(/\s+/)
      else
        []
      end
    end
  end
end

desc "Lint with the Standard Ruby style guide"
task :standard do
  require "standard"
  exit_code = Standard::Cli.new(Standard::RakeSupport.argvify).run
  fail unless exit_code == 0
end

desc "Lint and automatically make safe fixes with the Standard Ruby style guide"
task :"standard:fix" do
  require "standard"
  exit_code = Standard::Cli.new(Standard::RakeSupport.argvify + ["--fix"]).run
  fail unless exit_code == 0
end

desc "Lint and automatically make fixes (even unsafe ones) with the Standard Ruby style guide"
task :"standard:fix_unsafely" do
  require "standard"
  exit_code = Standard::Cli.new(Standard::RakeSupport.argvify + ["--fix-unsafely"]).run
  fail unless exit_code == 0
end
