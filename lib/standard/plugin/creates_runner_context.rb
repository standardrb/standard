module Standard
  module Plugin
    class CreatesRunnerContext
      def call(standard_config)
        LintRoller::Context.new(
          runner: :standard,
          runner_version: Standard::VERSION,
          engine: :rubocop,
          engine_version: RuboCop::Version.version,
          target_ruby_version: standard_config[:ruby_version]
        )
      end
    end
  end
end
