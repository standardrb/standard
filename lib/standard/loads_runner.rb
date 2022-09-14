require_relative "runners/rubocop"
require_relative "runners/version"
require_relative "runners/verbose_version"
require_relative "runners/help"

module Standard
  class LoadsRunner
    RUNNERS = {
      rubocop: ::Standard::Runners::Rubocop,
      version: ::Standard::Runners::Version,
      verbose_version: ::Standard::Runners::VerboseVersion,
      help: ::Standard::Runners::Help
    }.freeze

    def call(command)
      RUNNERS[command].new
    end
  end
end
