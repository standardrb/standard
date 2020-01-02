require "yaml"
require_relative "rubocop"

module Standard
  module Runners
    class Genignore
      def call(config)
        # Run Rubocop to generate the files with errors.
        config.rubocop_options[:formatters] = [["files", "temp_exclude.txt"]]
        config.rubocop_options[:format] = "files"
        config.rubocop_options[:out] = "temp_exclude.txt"

        File.delete("exclude.txt") if File.exist?("temp_exclude.txt")
        Runners::Rubocop.new.call(config)

        # Read in the files with errors.  It will have the absolute paths
        # of the files but we only want the relative path.
        files_with_errors = File.open("temp_exclude.txt").readlines.map(&:chomp)
        files_with_errors.map! do |file|
          # Get the relative file path.  Don't use the
          # relative_path_from method as it will raise an
          # error in Ruby 2.4.1 and possibly other versions.
          #
          # https://bugs.ruby-lang.org/issues/10011
          #
          file.sub(Dir.pwd + File::SEPARATOR, "")
        end

        yaml_format_errors = {"ignore" => files_with_errors}

        # Regenerate the todo file.
        File.open(".standard_todo.yml", "w") do |file|
          file.puts "# Auto generated files with errors to ignore."
          file.puts "# Remove from this list as you refactor files."
          file.write(yaml_format_errors.to_yaml)
        end

        # Clean up
        File.delete("temp_exclude.txt") if File.exist?("temp_exclude.txt")
      end
    end
  end
end
