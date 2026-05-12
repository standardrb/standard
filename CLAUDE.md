# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
# Run all tests and auto-fix standard violations
./bin/rake

# Run only tests
./bin/rake test

# Run a single test file
ruby -Ilib -Itest test/standard/cli_test.rb

# Run standard linter (fix mode)
./bin/rake standard:fix

# Release the gem
./bin/rake release
```

## Architecture

Standard Ruby is a linter/formatter built on top of RuboCop that provides an unconfigurable ruleset. The gem is intentionally opinionated — users cannot change the rules, only ignore violations.

### Request flow

`exe/standardrb` → `Standard::Cli` → `BuildsConfig` → `LoadsRunner` → runner

- **`BuildsConfig`** is the central orchestrator: it resolves `.standard.yml` and `.standard_todo.yml`, loads and merges settings from YAML + CLI args, then builds a `Standard::Config` struct (`runner`, `paths`, `rubocop_options`, `rubocop_config_store`).
- **`CreatesConfigStore`** builds the `RuboCop::ConfigStore` by composing several single-responsibility objects: `AssignsRubocopYaml`, `SetsTargetRubyVersion`, `ConfiguresIgnoredPaths`, `MergesUserConfigExtensions`, and `Plugin::CombinesPluginConfigs`.
- **`LoadsRunner`** resolves the correct runner class from `lib/standard/runners/` (`:rubocop`, `:lsp`, `:genignore`, `:help`, `:version`, `:verbose_version`).

### Plugin system

Since v1.28.0, Standard's own rules are loaded as plugins via [lint_roller](https://github.com/standardrb/lint_roller). The `standard` gem bundles `Standard::Base::Plugin` (`lib/standard/base/plugin.rb`), which selects a versioned YAML config from `config/` based on the project's target Ruby version (e.g. `config/ruby-3.3.yml` inherits from `config/base.yml`). Default plugins also include `standard-performance` and `standard-custom` (separate gems).

User-defined plugins are declared in `.standard.yml` under `plugins:` and loaded through `lib/standard/plugin/` — `StandardizesConfiguredPlugins` normalizes the plugin list, `InitializesPlugins` instantiates them, `CombinesPluginConfigs` merges their RuboCop YAML into the config store.

### LSP

`lib/standard/lsp/` provides a built-in LSP server (push diagnostics, formatting). A separate Ruby LSP add-on at `lib/ruby_lsp/standard/addon.rb` hooks into the [ruby-lsp](https://github.com/Shopify/ruby-lsp) ecosystem and supports pull diagnostics and code actions.

### Config files

- `config/base.yml` — the canonical RuboCop rule configuration
- `config/ruby-X.Y.yml` — per-version overrides that inherit from `base.yml`
- `.standard.yml` — user project config (ignored globs, plugins, `ruby_version`, etc.)
- `.standard_todo.yml` — auto-generated per-file ignore list for incremental adoption

### Testing

Tests use Minitest. `test/test_helper.rb` defines `UnitTest < Minitest::Test` with helpers. Test fixtures live in `test/fixture/` and cover CLI behavior, config loading, plugin loading, LSP, and extend_config scenarios. The `test/fixture/**/*` directory is excluded from Standard's own linting (see `.standard.yml`).

### Release process

See `docs/RELEASE.md`. RuboCop dependencies in `standard.gemspec` are pinned to exact versions. Version bump, `bundle`, and CHANGELOG update are committed together with the version string as the commit message before running `./bin/rake release`.
