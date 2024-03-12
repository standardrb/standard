module Standard
  class PrintsBigHairyVersionWarning
    WARNING = <<~MSG.gsub(/^ {6}/, "")
      ============================================================================
      = WARNING: You do not want to run this version of Standard!                =
      ============================================================================

      What's going on here?
      ---------------------
      Version 1.35.0 of Standard was set to depend on `~> 1.62' of RuboCop. This
      constraint is too loose, and covers all minor versions of RuboCop 1.x.

      "How do I fix this?", you might be asking.

      How to fix this
      ---------------
      If you add a version specifier pinning `standard' to a version newer
      than 1.35.1, Bundler will resolve appropriate versions of `standard',
      `rubocop', and any other rubocop-dependent gems you may have installed.

      1. Update your Gemfile to pin standard to be at least one such version:

        gem "standard", ">= 1.35.1"

      2. Run `bundle`, which will install and lock more appropriate versions

        Example output:
          Using rubocop 1.48.1 (was 1.49.0)
          Using standard 1.26.0 (was 0.0.36)

      This version (1.35.0.1) is an inoperative placeholder gem that exists
      solely to print this message.

      We're very sorry for this inconvenience!

      ============================================================================
      =                         END OF BIG SCARY WARNING                         =
      ============================================================================
    MSG

    def call
      warn WARNING
    end
  end
end
