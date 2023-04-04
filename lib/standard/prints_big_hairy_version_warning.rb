module Standard
  class PrintsBigHairyVersionWarning
    WARNING = <<~MSG.gsub(/^ {6}/, "")
      ============================================================================
      = WARNING: You do not want to run this very, very old version of Standard! =
      ============================================================================

      What's going on here?
      ---------------------
      Versions of Standard prior to 0.0.37 depended on `>= 0.63' of RuboCop, which
      means that Bundler continues to resolve to those (now ancient) versions
      whenever `gem "standard"' is added to a Gemfile that has already locked
      to a newer version of RuboCop than standard currently depends on.

      "How do I fix this?", you might be asking.

      How to fix this
      ---------------
      If you add a version specifier pinning `standard' to a version newer
      than 0.0.36.1, Bundler will resolve appropriate versions of `standard',
      `rubocop', and any other rubocop-dependent gems you may have installed.

      1. Update your Gemfile to pin standard to be at least one such version:

        gem "standard", ">= 1.0"

      2. Run `bundle`, which will install and lock more appropriate versions

        Example output:
          Using rubocop 1.48.1 (was 1.49.0)
          Using rubocop-performance 1.16.0
          Using standard 1.26.0 (was 0.0.36)

      This version (0.0.36.1) is an inoperative placeholder gem that exists
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
