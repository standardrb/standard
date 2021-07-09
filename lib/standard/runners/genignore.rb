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
          config.rubocop_options[:formatters] = [["json", temp_file.path]]
          config.rubocop_options[:out] = temp_file.path
          exit_code = Runners::Rubocop.new.call(config)

          result = JSON.parse(temp_file.read)
          ignore = result["files"].select { |file|
            file["offenses"].size > 0
          }.map { |file|
            {
              file["path"] => file["offenses"].map { |o| o["cop_name"] }.uniq
            }
          }

          # Read the files with errors from the temp file.
          yaml_format_errors = {"ignore" => ignore}

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
