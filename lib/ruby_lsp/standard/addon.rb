require "standard"
require_relative "wraps_built_in_lsp_standardizer"

module RubyLsp
  module Standard
    class Addon < ::RubyLsp::Addon
      def name
        "Standard Ruby"
      end

      def activate(global_state, message_queue)
        @logger = ::Standard::Lsp::Logger.new(prefix: "[Standard Ruby]")
        @logger.puts "Activating Standard Ruby LSP addon v#{::Standard::VERSION}"
        ::RuboCop::LSP.enable
        @wraps_built_in_lsp_standardizer = WrapsBuiltinLspStandardizer.new
        global_state.register_formatter("standard", @wraps_built_in_lsp_standardizer)
        register_additional_file_watchers(global_state, message_queue)
        @logger.puts "Initialized Standard Ruby LSP addon #{::Standard::VERSION}"
      end

      def deactivate
        @wraps_built_in_lsp_standardizer = nil
      end

      def register_additional_file_watchers(global_state, message_queue)
        return unless global_state.supports_watching_files

        message_queue << Request.new(
          id: "standard-file-watcher",
          method: "client/registerCapability",
          params: Interface::RegistrationParams.new(
            registrations: [
              Interface::Registration.new(
                id: "workspace/didChangeWatchedFilesStandard",
                method: "workspace/didChangeWatchedFiles",
                register_options: Interface::DidChangeWatchedFilesRegistrationOptions.new(
                  watchers: [
                    Interface::FileSystemWatcher.new(
                      glob_pattern: "**/.standard{,_todo}.yml",
                      kind: Constant::WatchKind::CREATE | Constant::WatchKind::CHANGE | Constant::WatchKind::DELETE
                    )
                  ]
                )
              )
            ]
          )
        )
      end

      def workspace_did_change_watched_files(changes)
        if changes.any? { |change| change[:uri].end_with?(".standard.yml") }
          @wraps_built_in_lsp_standardizer.init!
          @logger.puts "Re-initialized Standard Ruby LSP addon #{::Standard::VERSION} due to .standard.yml file change"
        end
      end
    end
  end
end
