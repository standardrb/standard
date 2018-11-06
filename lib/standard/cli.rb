require "rubocop"

module Standard
  class Cli
    SUCCESS_STATUS_CODE=0
    FAILURE_STATUS_CODE=1

    def initialize()
    end

    def run
      paths = ["."]
      rubocop_config_path =  Pathname.new(__dir__).join("../../config/base.yml")
      runner = RuboCop::Runner.new({
        :config => rubocop_config_path,
        :formatters => [["progress", nil]]
      }, create_config_store(rubocop_config_path))

      passed = runner.run(paths)

      runner.warnings.each { |warning| warn warning }
      print_errors(runner.errors)
      if passed
        SUCCESS_STATUS_CODE
      else
        FAILURE_STATUS_CODE
      end
    end

    private

    def create_config_store(rubocop_config_path)
      # Apparently unnecessary:
      # RuboCop::ConfigLoader.options_config = rubocop_config_path
      RuboCop::ConfigStore.new.tap { |config_store|
        config_store.options_config = rubocop_config_path
      }
    end

    # See: https://github.com/rubocop-hq/rubocop/blob/master/lib/rubocop/cli.rb#L263
    def print_errors(errors)
      return if errors.empty?

      errors.each { |error| warn error }

      warn <<~WARNING
        Errors are usually caused by RuboCop bugs.
        Please, report your problems to RuboCop's issue tracker.
        #{Gem.loaded_specs['rubocop'].metadata['bug_tracker_uri']}
        Mention the following information in the issue report:
        #{RuboCop::Version.version(true)}
      WARNING
    end
  end
end
