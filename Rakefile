require "bundler/gem_tasks"
require "rake/clean"
require "rake/testtask"
require_relative "lib/standard/rake"

CLOBBER.include "*.gem"

task default: [:test, "standard:fix"]

Rake::TestTask.new(:test) do |t|
  t.warning = false
  t.test_files = FileList["test/**/*_test.rb"]
end
