require "tempfile"
require "yaml"
require_relative "rubocop"

module Standard
  module Runners
    class Genignore
      def call(config)
        # Place to temporally store the ignored files.
        temp_file = Tempfile.new("excluded.txt")
        begin
          # Run Rubocop to generate the files with errors into the temp file.
          config.rubocop_options[:formatters] = [["files", temp_file.path]]
          config.rubocop_options[:format] = "files"
          config.rubocop_options[:out] = temp_file.path
          exit_code = Runners::Rubocop.new.call(config)

          # Read in the files with errors.  It will have the absolute paths
          # of the files but we only want the relative path.
          files_with_errors = temp_file.readlines.map(&:chomp)
          files_with_errors.map! do |file|
            # Get the relative file path.  Don't use the
            # relative_path_from method as it will raise an
            # error in Ruby 2.4.1 and possibly other versions.
            #
            # https://bugs.ruby-lang.org/issues/10011
            #
            file.sub(Dir.pwd + File::SEPARATOR, "")
          end

          # Read the files with errors from the temp file.
          yaml_format_errors = {"ignore" => files_with_errors}

          # Regenerate the todo file.
          File.open(".standard_todo.yml", "w") do |file|
            file.puts "# Auto generated files with errors to ignore."
            file.puts "# Remove from this list as you refactor files."
            file.write(yaml_format_errors.to_yaml)
          end
          exit_code
        ensure
          # Clean up temp file.
          temp_file.close
          temp_file.unlink
        end
      end
    end
  end
end
