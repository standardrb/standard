module Standard
  class Cli
    SUCCESS_STATUS_CODE=0
    FAILURE_STATUS_CODE=1

    def initialize()
    end

    def run
      paths = ["."]
      rubocop_config_path = "../../config/base.yml"
      config_store = RuboCop::ConfigStore.new
      config_store.options_config = rubocop_config_path
      RuboCop::ConfigLoader.options_config = rubocop_config_path
      options = {:config => rubocop_config, :formatters => [["progress", nil]]}

      runner = RuboCop::Runner.new(options, config_store)
      passed = runner.run(paths)

      runner.warnings.each { |warning| warn warning }
      print_errors(errors)

      if passed
        SUCCESS_STATUS_CODE
      else
        FAILURE_STATUS_CODE
      end
    end

    private

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
