module Standard
  class LoadsRunner
    # Warning: clever metaprogramming. 99% of the time this is Runners::Rubocop
    def call(command)
      require_relative "runners/#{command}"
      ::Standard::Runners.const_get(command.to_s.capitalize).new
    end
  end
end
