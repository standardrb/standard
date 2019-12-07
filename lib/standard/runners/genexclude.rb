require 'yaml'
require_relative "rubocop"

# REM
module Standard
  module Runners
    class Genexclude
      def call(config)
        # Run Rubocop to generate the files with errors.
        config.rubocop_options[:formatters] = [["files", "exclude.txt"]]
        config.rubocop_options[:format] = "files"
        config.rubocop_options[:out] = "exclude.txt"

        Runners::Rubocop.new().call(config)

        # Read in the files with errors.
        files_with_errors = File.open("exclude.txt").readlines.map(&:chomp)
        files_with_errors.map! { |file|
          #puts file
          #puts Pathname.new(file).relative_path_from(__dir__)
          #puts Dir.pwd
          Pathname.new(file).relative_path_from(Dir.pwd).to_s
        }

        yaml_format_errors = { 'ignore' => files_with_errors }

        # Regenerate the todo file.
        File.delete(".standard_todo.yml") if File.exists?(".standard_todo.yml")
        File.open(".standard_todo.yml", "w") do |file|
          file.puts "# Auto generated files with errors to ignore."
          file.puts "# Remove from this list as you refactor files."
          file.write(yaml_format_errors.to_yaml)
        end

        # Clean up
        File.delete("exclude.txt") if File.exists?("exclude.txt")
      end
    end
  end
end
