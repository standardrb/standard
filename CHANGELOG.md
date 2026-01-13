# Changelog

## 1.53.0

* Updates rubocop to [1.82.0](https://github.com/rubocop/rubocop/releases/tag/v1.82.0)
* Starts support for Ruby 4.0

## 1.52.0

* Updates rubocop to [1.81.7](https://github.com/rubocop/rubocop/tree/v1.81.7)

## 1.51.1

* Fixes Layout/EmptyLineAfterGuardClause back to false after [#750](https://github.com/standardrb/standard/issues/750)

## 1.51.0

* Updates rubocop to [1.81.2](https://github.com/rubocop/rubocop/tree/v1.81.2)

## 1.50.0

* Updates rubocop to [1.75.5](https://github.com/rubocop/rubocop/tree/v1.75.5)

## 1.49.0

* Updates standard performance to 1.8.0

## 1.48.0

* Updates rubocop to [1.75.2](https://github.com/rubocop/rubocop/tree/v1.75.2)

## 1.47.0

* Updates standard performance to 1.7.0

## 1.46.0

* Updates rubocop to [1.73.2](https://github.com/rubocop/rubocop/tree/v1.73.2)

## 1.45.0

* Updates rubocop to [1.71.0](https://github.com/rubocop/rubocop/tree/v1.71.0)

## 1.44.0

* Updates rubocop to [1.70.0](https://github.com/rubocop/rubocop/tree/v1.70.0)

## 1.43.0

* Updates rubocop to [1.69.1](https://github.com/rubocop/rubocop/tree/v1.69.1)

## 1.42.1

* Fixes a very noisy typo!

## 1.42.0

* Updates rubocop to [1.68.0](https://github.com/rubocop/rubocop/tree/v1.68.0)
* Inherit from `RuboCop::Cop::Base` fixing deprecation warnings.
* Add new cops

## 1.41.1

* Adds a stub method to the Ruby LSP add-on to avoid a potential runtime exception
for range formatting requests [#655](https://github.com/standardrb/standard/pull/655)

## 1.41.0

* Updates rubocop to [1.66.1](https://github.com/rubocop/rubocop/releases/tag/v1.66.1)
* Updates standard-performance to [1.5.0](https://github.com/standardrb/standard-performance/releases/tag/v1.5.0)

## 1.40.1

* Fix error handling in LSP Server 84ee9f4

## 1.40.0

* Updates rubocop to [1.65.1](https://github.com/rubocop/rubocop/releases/tag/v1.65.1)

## 1.39.2

* Ensure a URI scheme on file paths from the built-in LSP [#642](https://github.com/standardrb/standard/pull/642).

## 1.39.1

* Fix LSP when `format` is set [#638](https://github.com/standardrb/standard/issues/638)
* Fix LSP when todo is present (I think) [vscode-standard-ruby#26](https://github.com/standardrb/vscode-standard-ruby/issues/26)

## 1.39.0

* Add support for LSP Code Actions / Quick Fix under Ruby LSP [#636](https://github.com/standardrb/standard/pull/636)

## 1.38.0

* Update minimum Ruby version to 3.0
* @koic backported a line column bug in our LSP
  [#635](https://github.com/standardrb/standard/pull/635)
* Implement a basic [Ruby LSP
add-on](https://github.com/Shopify/ruby-lsp/blob/main/ADDONS.md), which means
users would no longer need to install [our custom VS Code
extension](https://marketplace.visualstudio.com/items?itemName=testdouble.vscode-standard-ruby)
[#630](https://github.com/standardrb/standard/pull/630)

## 1.37.0

* Updates rubocop to [1.64.1](https://github.com/rubocop/rubocop/releases/tag/v1.64.1)

## 1.36.0

* Updates rubocop to [1.63.5](https://github.com/rubocop/rubocop/releases/tag/v1.63.5)
* Updates standard-performance to [1.4.0](https://github.com/standardrb/standard-performance/releases/tag/v1.4.0)

## 1.35.1

* Corrects rubocop constraint to the patch version, not minor version.

## 1.35.0

* Updates rubocop to [1.62](https://github.com/rubocop/rubocop/releases/tag/v1.62.1)

## 1.34.0

* Updates rubocop to [1.60.2](https://github.com/rubocop/rubocop/releases/tag/v1.60.2)

## 1.33.0

* Updates rubocop to [1.59.0](https://github.com/rubocop/rubocop/releases/tag/v1.59.0)
* Updates standard-performance to [1.3.0](https://github.com/standardrb/standard-performance/releases/tag/v1.3.0)

## 1.32.1

* Fixes regeneration of TODO files ot avoid missing already-ignored rules [#587](https://github.com/standardrb/standard/pull/587)

## 1.32.0

* Updates rubocop to [1.57.2](https://github.com/rubocop/rubocop/releases/tag/v1.57.2)

## 1.31.2

* Updates rubocop to [1.52.4](https://github.com/rubocop/rubocop/releases/tag/v1.52.4)
* Updates standard-performance to [v1.2.1](https://github.com/standardrb/standard-performance/releases/tag/v1.2.1)

## 1.31.1

* Updates rubocop to [1.52.2](https://github.com/rubocop/rubocop/releases/tag/v1.52.2)

## 1.31.0

* Updates standard-performance to [v1.2.0](https://github.com/standardrb/standard-performance/releases/tag/v1.2.0)
* Updates rubocop to [1.56.0](https://github.com/rubocop/rubocop/releases/tag/v1.56.0)

## 1.30.1

* Just kidding about about `Standard::PluginSupport`. Moving it to `LintRoller::Support`
to avoid circular dependencies between Standard Ruby and its plugins

## 1.30.0

* Add `Standard::PluginSupport` module of classes designed to make it a little
easier to author plugins. `MergesUpstreamMetadata#merge` will allow a minimal
YAML config (say, `standard-sorbet`'s, which only contains `Enabled` values for
each rule) to merge in any other defaults from a source YAML (e.g.
`rubocop-sorbet`'s which includes `Description`, `VersionAdded`, and so on).
This way that metadata is neither absent at runtime nor duplicated in a standard
plugin that mirrors a rubocop extension

## 1.29.0

* Updates standard-performance to [1.1.0](https://github.com/standardrb/standard-performance/releases/tag/v1.1.0)
* Updates rubocop to [1.52.0](https://github.com/rubocop/rubocop/releases/tag/v1.52.0)
  * Enables Style/ExactRegexpMatch, Style/RedundantArrayConstructor, Style/RedundantFilterChain, Style/RedundantRegexpConstructor

## 1.28.5

* Make LSP behave more nicely with nvim-lspconfig [#564](https://github.com/standardrb/standard/pull/564)

## 1.28.4

* Fix [standard-rails#7](https://github.com/standardrb/standard-rails/issues/7#issuecomment-1563505365)

## 1.28.3

* Older ruby support fixes from [@pboling](https://github.com/pboling):
  * [#559](https://github.com/standardrb/standard/issues/559)
  * [#561](https://github.com/standardrb/standard/issues/560)
  * [#561](https://github.com/standardrb/standard/issues/561)

## 1.28.2

* Attempts to fix the not-actually fixed plugin behavior in 1.28.1

## 1.28.1

* Fixes plugin behavior caused by setting `DisabledByDefault: true` in `AllCops`
  Effectively, a single lint_roller plugin whose `rules` were of type `:object`
  would inadvertently mark all previously-defined rules as invalid.
  [#557](https://github.com/standardrb/standard/pull/557)

## 1.28.0

* Refactor Standard into 3 gems and convert all built-in configuration into
  [lint_roller](https://github.com/standardrb/lint_roller) plugins. See:
  * [standard-performance](https://github.com/standardrb/standard-performance)
  * [standard-custom](https://github.com/standardrb/standard-custom)
* Standard's behavior when merging multiple `extend_config` that change the same
  set of rules has been fixed to be first-in-wins, as opposed to last-in-wins.
  This ensures a consistent behavior across plugins and extended configurations,
  namely that the first thing to configure a given rule effectively locks it
  from subsequent changes
* Enable `DisabledByDefault: true`. This shouldn't impact anyone, but might
  change the behavior of some `extend_config` users. Because Standard specifies
  every rule in rubocop and rubocop-performance, this configuration's absence
  wasn't felt until we went to the plugin system, where it makes much more sense
  for plugins to _opt-in_ to the cops they want to configure, as opposed to just
  running every single one that they happen to load/require

## 1.27.0

* Update rubocop from 1.48.1 to [1.50.2](https://github.com/rubocop/rubocop/releases/tag/v1.50.2)
  * Enabled [Style/RedundantLineContinuation](https://docs.rubocop.org/rubocop/cops_style.html#styleredundantlinecontinuation)

## 1.26.0

* Introduce `--fix-unsafely` and `rake standard:fix_unsafely` for running
  unsafe corrections. Improve output about fix suggestions, as well
  [#545](https://github.com/testdouble/standard/pull/545)

## 1.25.5

* Temporarily disable registration of `executeCommand` to prevent conflict with
  the VS Code extension's client-side registration of the same name
  [#544](https://github.com/testdouble/standard/pull/544)

## 1.25.4

* Bring the LSP Server's executeCommand capabilities in line with the spec
  [#543](https://github.com/testdouble/standard/pull/543)

## 1.25.3

* Relax the version specifier on `rubocop` and `rubocop-performance` to allow
  patch-level updates

## 1.25.2

* Disable Style/RedundantFetchBlock due to concerns the performance benefit
  isn't worth the inconsistency it causes and the fact it is incompatible with
  ActiveSupport [#527](https://github.com/testdouble/standard/issues/527)

## 1.25.1

* When in `stdin` mode, don't invoke the RuboCop runner with `parallel: true` to
  avoid an interaction that breaks auto-fixing
  [#530](https://github.com/testdouble/standard/issues/530),
  [#536](https://github.com/testdouble/standard/issues/536)

## 1.25.0

* Update rubocop-performance from 1.15.2 to [1.16.0](https://github.com/rubocop/rubocop-performance/releases/tag/v1.16.0)
* Update rubocop from 1.44.1 to [1.48.1](https://github.com/rubocop/rubocop/releases/tag/v1.48.1)
  * Enabled [Style/DirEmpty](https://docs.rubocop.org/rubocop/cops_style.html#styledirempty)
  * Enabled [Style/RedundantHeredocDelimiterQuotes](https://docs.rubocop.org/rubocop/cops_style.html#styleredundantheredocdelimiterquotes)

## 1.24.3

* _Further_ _further_ _further_ improve `--lsp` server to ignore files correctly

## 1.24.2

* _Further_ _further_ improve `--lsp` server to always respond to requests

## 1.24.1

* _Further_ improve `--lsp` server to better support commands used by VS Code

## 1.24.0

* Improve `--lsp` server to better support the commands used by VS Code

## 1.23.0

* Update rubocop from 1.42.0 to [1.44.1](https://github.com/rubocop/rubocop/releases/tag/v1.44.1)

## 1.22.1

* Improve the behavior of `extend_config` to more accurately reflect how Rubocop
extensions would behave when loaded via the `rubocop` CLI (by capturing any
mutations to RuboCop's default configuration)
[#512](https://github.com/testdouble/standard/pull/512)

## 1.22.0

* Add `extend_config` option [#506](https://github.com/testdouble/standard/pull/506)

## 1.21.1

* Fix standard comment directives [#498](https://github.com/testdouble/standard/pull/498)

## 1.21.0

* Update rubocop-performance from 1.15.1 to [1.15.2](https://github.com/rubocop/rubocop-performance/releases/tag/v1.15.2)
* Update rubocop from 1.40.0 to [1.42.0](https://github.com/rubocop/rubocop/releases/tag/v1.42.0)

## 1.20.0

* Update rubocop from 1.39.0 to [1.40.0](https://github.com/rubocop/rubocop/releases/tag/v1.40.0)

## 1.19.1

* Loosen dependency on `language_server-protocol`

## 1.19.0

* Add a language server protocol (LSP) server via the new `standardrb --lsp`
  command line mode. All credit to [@will](https://github.com/)!
  [#475](https://github.com/testdouble/standard/pull/475)

## 1.18.1

* Update rubocop-performance from 1.15.0 to [1.15.1](https://github.com/rubocop/rubocop-performance/releases/tag/v1.15.1)

## 1.18.0

* Update rubocop from 1.38.0 to [1.39.0](https://github.com/rubocop/rubocop/releases/tag/v1.39.0)

## 1.17.0

* Update rubocop-performance from 1.14.3 to [1.15.0](https://github.com/rubocop/rubocop-performance/releases/tag/v1.15.0)
* Update rubocop from 1.35.1 to [1.38.0](https://github.com/rubocop/rubocop/releases/tag/v1.38.0)
* Require parentheses around complex ternary conditions [3b0b499a](https://github.com/testdouble/standard/commit/3b0b499a480f8ed90dda1272d31b5617dc340b27)

## 1.16.1

* Update rubocop from 1.35.0 to [1.35.1](https://github.com/rubocop/rubocop/releases/tag/v1.35.1)

## 1.16.0

* Update rubocop from 1.33.0 to [1.35.0](https://github.com/rubocop/rubocop/releases/tag/v1.35.0)

## 1.15.0

* Update rubocop from 1.32.0 to [1.33.0](https://github.com/rubocop/rubocop/releases/tag/v1.33.0)

## 1.14.0

* Update rubocop from 1.31.2 to [1.32.0](https://github.com/rubocop/rubocop/releases/tag/v1.32.0)

## 1.13.0

* Update rubocop-performance from 1.13.3 to [1.14.3](https://github.com/rubocop/rubocop-performance/releases/tag/v1.14.3)
* Update rubocop from 1.29.1 to [1.31.2](https://github.com/rubocop/rubocop/releases/tag/v1.31.2)

## 1.12.1

* Update rubocop from 1.29.0 to [1.29.1](https://github.com/rubocop/rubocop/releases/tag/v1.29.1), fixing [#413](https://github.com/testdouble/standard/issues/413)

## 1.12.0

* Update rubocop from 1.28.2 to [1.29.0](https://github.com/rubocop/rubocop/releases/tag/v1.29.0)

## 1.11.0

* Update rubocop from 1.27.0 to [1.28.2](https://github.com/rubocop/rubocop/releases/tag/v1.28.2)

## 1.10.0

* Update rubocop from 1.26.1 to [1.27.0](https://github.com/rubocop/rubocop/releases/tag/v1.27.0)

## 1.9.1

* Update rubocop from 1.26.0 to [1.26.1](https://github.com/rubocop/rubocop/releases/tag/v1.26.1)

## 1.9.0

* Rule change to `Layout/CaseIndentation` to have the `when` and `in`s inside a case statement aligned with the `end` of the case. The `end` will be aligned with a variable instead of the `case` keyword if applicable.

## 1.8.0

* Update rubocop from 1.25.1 to [1.26.0](https://github.com/rubocop/rubocop/releases/tag/v1.26.0)

## 1.7.3

* Update rubocop-performance from 1.13.2 to [1.13.3](https://github.com/rubocop/rubocop-performance/tag/v1.13.3)

## 1.7.2

* Removes Style/RedundantBegin from Ruby versions <= 2.4

## 1.7.1

* Update rubocop from 1.25.0 to [1.25.1](https://github.com/rubocop/rubocop/releases/tag/v1.25.1)

## 1.7.0

* Update rubocop-performance from 1.13.1 to [1.13.2](https://github.com/rubocop/rubocop-performance/tag/v1.13.2)
* Update rubocop from 1.24.1 to [1.25.0](https://github.com/rubocop/rubocop/releases/tag/v1.25.0)

## 1.6.0

* Update rubocop-performance from 1.12.0 to [1.13.1](https://github.com/rubocop/rubocop-performance/tag/v1.13.1)
* Update rubocop from 1.23.0 to [1.24.1](https://github.com/rubocop/rubocop/releases/tag/v1.24.1)

## 1.5.0

* Update rubocop-performance from 1.11.5 to [1.12.0](https://github.com/rubocop/rubocop-performance/tag/v1.12.0)
* Update rubocop from 1.22.3 to [1.23.0](https://github.com/rubocop/rubocop/releases/tag/v1.23.0)

## 1.4.0

* Update rubocop from 1.19.1 to [1.22.3](https://github.com/rubocop-hq/rubocop/releases/tag/v1.22.3)
* Remove [`Style/NegatedIf`](https://github.com/TODO)

## 1.3.0

* Update rubocop from 1.19.1 to [1.20.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.20.0)

## 1.2.0

* Update rubocop from 1.18.4 to [1.19.1](https://github.com/rubocop-hq/rubocop/releases/tag/v1.19.1)
* Update rubocop-performance from 1.11.4 to [1.11.5](https://github.com/rubocop-hq/rubocop-performance/releases/tag/v1.11.5)

## 1.1.7

* Fix an issue with nested generated todos being ignored
[#311](https://github.com/testdouble/standard/pull/311)

## 1.1.6

* Update rubocop from 1.18.3 to [1.18.4](https://github.com/rubocop-hq/rubocop/releases/tag/v1.18.4)

## 1.1.5

* Update rubocop from 1.18.2 to [1.18.3](https://github.com/rubocop-hq/rubocop/releases/tag/v1.18.3)
* Update rubocop-performance from 1.11.3 to [1.11.4](https://github.com/rubocop-hq/rubocop-performance/releases/tag/v1.11.4)
* Disabled `Performance/DeletePrefix` because it was marked as unsafe.

## 1.1.4

* Update rubocop from 1.18.1 to [1.18.2](https://github.com/rubocop-hq/rubocop/releases/tag/v1.18.2)
* Update rubocop-performance from 1.11.2 to [1.11.3](https://github.com/rubocop-hq/rubocop-performance/releases/tag/v1.11.3)

## 1.1.3

* Update rubocop from 1.17.0 to [1.18.1](https://github.com/rubocop-hq/rubocop/releases/tag/v1.18.1)

## 1.1.2

* Update rubocop from 1.14.0 to [1.17.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.17.0)

## 1.1.1

* Update rubocop from 1.13.0 to [1.14.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.14.0)
* Update rubocop-performance from 1.11.1 to [1.11.2](https://github.com/rubocop-hq/rubocop-performance/releases/tag/v1.11.2)

## 1.1.0

* Update rubocop from 1.12.1 to [1.13.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.13.0)
* Update rubocop-performance from 1.9.2 to [1.11.1](https://github.com/rubocop-hq/rubocop-performance/releases/tag/v1.11.1)
* Enabled the following rules:
  * [`Performance/RedundantSplitRegexpArgument`](https://github.com/rubocop/rubocop-performance/pull/190)
  * [`Style/IfWithBooleanLiteralBranches`](https://github.com/rubocop-hq/rubocop/pull/9396)
  * [`Lint/TripleQuotes`](https://github.com/rubocop-hq/rubocop/pull/9402)
  * [`Lint/SymbolConversion`](https://github.com/rubocop/rubocop/pull/9362)
  * [`Lint/OrAssignmentToConstant`](https://github.com/rubocop-hq/rubocop/pull/9363)
  * [`Lint/NumberedParameterAssignment`](https://github.com/rubocop-hq/rubocop/pull/9326)
  * [`Style/HashConversion`](https://github.com/rubocop-hq/rubocop/pull/9478)
  * [`Gemspec/DateAssignment`](https://github.com/rubocop-hq/rubocop/pull/9496)
  * [`Style/StringChars`](https://github.com/rubocop/rubocop/pull/9615)

## 1.0.5

* Update rubocop from 1.11.0 to [1.12.1](https://github.com/rubocop-hq/rubocop/releases/tag/v1.12.1)

## 1.0.4

* Workaround RuboCop's CLI from erroring when it detects a cop named
  BlockDelimiters by renaming it to BlockSingleLineBraces
  ([#271](https://github.com/testdouble/standard/issues/271))

## 1.0.3

* Fix an exit code bug introduced in 1.0.2
  ([#272](https://github.com/testdouble/standard/pull/272)

## 1.0.2

* Preserve RuboCop's CLI exit codes
  ([#270](https://github.com/testdouble/standard/pull/270)) by
  [@nicksieger](https://github.com/nicksieger)

## 1.0.1

* Update rubocop from 1.10.0 to [1.11.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.11.0)
* Update rubocop-performance from 1.9.2 to [1.10.1](https://github.com/rubocop-hq/rubocop-performance/releases/tag/v1.10.1)

## 1.0.0

* Relax multi-line block rules, moving away from enforcing semantic blocks to
  instead allowing code to adhere to whatever multi-line format the author deems
  best [#263](https://github.com/testdouble/standard/pull/263)
* Allow a `standard:disable` comment directive in addition to `rubocop:disable`
  [#186](https://github.com/testdouble/standard/pull/186)
* Remove the banner text that standard outputs after failure
  [#264](https://github.com/testdouble/standard/pull/264)

## 0.13.0

* Update rubocop from 1.7.0 to [1.10.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.10.0) enabling:
  * [`Lint/AmbiguousAssignment`](https://github.com/rubocop-hq/rubocop/issues/9223)
  * [`Style/HashExcept`](https://github.com/rubocop-hq/rubocop/pull/9283)
  * [`Lint/DeprecatedConstants`](https://github.com/rubocop-hq/rubocop/pull/9324)

## 0.12.0

* Update rubocop from 1.7.0 to [1.8.1](https://github.com/rubocop-hq/rubocop/releases/tag/v1.8.1)
* Enabled [`Style/SlicingWithRange`](https://github.com/testdouble/standard/issues/175)

## 0.11.0

* Update rubocop-performance from 1.9.1 to [1.9.2](https://github.com/rubocop-hq/rubocop-performance/releases/tag/v1.9.2)
* Update rubocop from 1.4.2 to [1.7.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.7.0)
* Changed `Style/NegatedIf` to `postfix`

## 0.10.2

* Remove
  [`Lint/DuplicateBranch`](https://github.com/testdouble/standard/pull/228)

## 0.10.1

* Remove [`Performance/ArraySemiInfiniteRangeSlice`](https://github.com/testdouble/standard/pull/225#discussion_r532678908)

## 0.10.0

* Update rubocop-performance from 1.8.1 to [1.9.1](https://github.com/rubocop-hq/rubocop-performance/releases/tag/v1.9.1) enabling:
  * [`Performance/BlockGivenWithExplicitBlock`](https://github.com/rubocop-hq/rubocop-performance/pull/173)
  * [`Performance/ConstantRegexp`](https://github.com/rubocop-hq/rubocop-performance/pull/174)
  * [`Performance/ArraySemiInfiniteRangeSlice`](https://github.com/rubocop-hq/rubocop-performance/pull/175)
* Update rubocop from 1.2.0 to [1.4.2](https://github.com/rubocop-hq/rubocop/releases/tag/v1.4.2) enabling:
  * [`Style/NilLambda`](https://github.com/rubocop-hq/rubocop/pull/9020)
  * [`Lint/DuplicateBranch`](https://github.com/rubocop-hq/rubocop/pull/8404)

## 0.9.0

* Update rubocop from 1.0.0 to [1.2.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.2.0) enabling:
  * [`Lint/DuplicateRegexpCharacterClassElement`](https://github.com/rubocop-hq/rubocop/pull/8896)
  * [`Style/ArgumentsForwarding`](https://github.com/rubocop-hq/rubocop/pull/7646)
* Don't find offense in `Style/SemanticBlocks` when a top-level `rescue` is used
  in a `do`/`end` functional block, fixing
  [#205](https://github.com/testdouble/standard/issues/205)

## 0.8.1

* Make it match semver

## 0.8

* Update rubocop from 0.93.1 to [1.0.0](https://github.com/rubocop-hq/rubocop/releases/tag/v1.0.0)
* Update rubocop from 0.92 to
  [0.93](https://github.com/rubocop-hq/rubocop/releases/tag/v0.93) to
  [0.93.1](https://github.com/rubocop-hq/rubocop/releases/tag/v0.93.1) enabling:
  * [`Style/ClassEqualityComparison`](https://github.com/rubocop-hq/rubocop/pull/8833)
* Disable `Performance/Sum` because #208 and the lack of actual auto-correcting is also causing more trouble

## 0.7

* Update rubocop from 0.91.1 to
  [0.92](https://github.com/rubocop-hq/rubocop/releases/tag/v0.92)

## 0.6.2

* Update rubocop from 0.91 to
  [0.91.1](https://github.com/rubocop-hq/rubocop/releases/tag/v0.91.1)
* Update rubocop-performance from 1.8.0 to 1.8.1:
  * Enable `Performance/Sum`

## 0.6.1

* Update Rubocop from
  [0.90](https://github.com/rubocop-hq/rubocop/releases/tag/v0.90.0)
  to
  [0.91](https://github.com/rubocop-hq/rubocop/releases/tag/v0.91.0),
  enabling:
  * [`Lint/UselessTimes`](https://github.com/rubocop-hq/rubocop/pull/8702)
  * [`Layout/BeginEndAlignment`](https://github.com/rubocop-hq/rubocop/pull/8628)
  * [`Lint/ConstantDefinitionInBlock`](https://github.com/rubocop-hq/rubocop/pull/8707)
  * [`Lint/IdentityComparison`](https://github.com/rubocop-hq/rubocop/pull/8699/)
  re-enabling after bug fixes:
  * [`Bundler/DuplicatedGem`](https://github.com/rubocop-hq/rubocop/pull/8666)
  * [`Naming/BinaryOperatorParameterName`](https://github.com/rubocop-hq/rubocop/issues/8664)

## 0.6.0

* Update Rubocop from
  [0.89.1](https://github.com/rubocop-hq/rubocop/releases/tag/v0.89.1)
  to
  [0.90](https://github.com/rubocop-hq/rubocop/releases/tag/v0.90.0),
  enabling:
  * [`Style/KeywordParametersOrder`](https://github.com/rubocop-hq/rubocop/pull/8563)
  * [`Lint/DuplicateRequire`](https://github.com/rubocop-hq/rubocop/pull/8474)
  * [`Lint/TrailingCommaInAttributeDeclaration`](https://github.com/rubocop-hq/rubocop/pull/8549)
* Update [`Style/Alias` to prefer `alias_method`](https://github.com/testdouble/standard/pull/196)
* Update rubocop-performance from 1.7.1 to 1.8.0:
  * Plan to enable [`Performance/Sum`](https://github.com/rubocop-hq/rubocop-performance/pull/137) in the future, but there is currently a bug in the implementation
* Add `ruby-2.3.yml` to add support for 2.3.

## 0.5.2

* Turned off `Lint/MissingSuper`, because it effectively bans a common idiom in
  Sorbet ([#195](https://github.com/testdouble/standard/issues/195)) and might
  be a bit too heavy-handed/opinionated for cases where a class is designed
  intentionally to not run its parent's initializer (like abstract superclasses
  more generally)

## 0.5.1

* Enabled `Style/MultilineWhenThen`

## 0.5.0

* Update Rubocop from
  [0.85.0](https://github.com/rubocop-hq/rubocop/blob/master/CHANGELOG.md#0850-2020-06-01)
  to
  [0.89.1](https://github.com/rubocop-hq/rubocop/releases/tag/v0.89.1),
  enabling:
  * `Lint/BinaryOperatorWithIdenticalOperands`
  * `Lint/DuplicateElsifCondition`
  * `Lint/DuplicateRescueException`
  * `Lint/FloatComparison`
  * `Lint/MissingSuper`
  * `Lint/OutOfRangeRegexpRef`
  * `Lint/RedundantRequireStatement`
  * `Lint/RedundantSplatExpansion`
  * `Lint/SafeNavigationWithEmpty`
  * `Lint/SelfAssignment`
  * `Lint/TopLevelReturnWithArgument`
  * `Style/GlobalStdStream`
  * `Style/RedundantAssignment`
  * `Style/RedundantFetchBlock`
  * `Style/RedundantFileExtensionInRequire`
* Update rubocop-performance from 1.6.0 to 1.7.1, enabling:
  * `Performance/BigDecimalWithNumericArgument`
  * `Performance/RedundantSortBlock`
  * `Performance/RedundantStringChars`
  * `Performance/ReverseFirst`
  * `Performance/SortReverse`
  * `Performance/Squeeze`

## 0.4.7

* Update Rubocop from
  [0.83.0](https://github.com/rubocop-hq/rubocop/blob/master/CHANGELOG.md#0830-2020-05-11)
  to
  [0.85.0](https://github.com/rubocop-hq/rubocop/blob/master/CHANGELOG.md#0850-2020-06-01), notably:

  * Enable
    [Lint/MixedRegexpCaptureTypes](https://rubocop.readthedocs.io/en/stable/cops_lint/#lintmixedregexpcapturetypes)
  * Enable
    [Lint/DeprecatedOpenSSLConstant](https://rubocop.readthedocs.io/en/stable/cops_lint/#lintdeprecatedopensslconstant)
  * Enable
    [Style/RedundantRegexpCharacterClass](https://github.com/rubocop-hq/rubocop/pull/8055)
  * Enable
    [Style/RedundantRegexpEscape](https://github.com/rubocop-hq/rubocop/pull/7908)
* Update rubocop-performance to
  [1.6.0](https://github.com/rubocop-hq/rubocop-performance/blob/master/CHANGELOG.md#160-2020-05-22),
  enabling:
  * [Performance/BindCall](https://github.com/rubocop-hq/rubocop-performance/issues/77)
  * [Performance/DeletePrefix](https://github.com/rubocop-hq/rubocop-performance/pull/105)
  * [Performance/DeleteSuffix](https://github.com/rubocop-hq/rubocop-performance/pull/105)

## 0.4.6

* Disable `Naming/BinaryOperatorParameterName` because (when non-ascii method
  names are used), it incorrectly identifies them as being `+()` operator
  overrides (overly aggressive)

## 0.4.5

* Disable `Naming/AsciiIdentifiers` for the same reason as mentioned below in
  0.4.4 (specifically to allow programs written in non-Latin languages to define
  identifiers)

## 0.4.4

* Disable `Naming/MethodName` cop. While `snake_case` is the conventional way to
  name a Ruby method, the cop is too restrictive in that it also prevents
  non-ASCII characters from being included in method names

## 0.4.3

* Improve output of the todo feature

## 0.4.2

* Track Rubocop
  [0.83.0](https://github.com/rubocop-hq/rubocop/blob/master/CHANGELOG.md#0830-2020-05-11)
  * Update our default to allow trailing whitespace in heredocs
  * Disable auto-correct for a cop that changed `:true` to `true`, as that's not
    safe
  * Allow comments in empty `when` blocks

## 0.4.1

* add given/given! as `{}` friendly blocks [#172](https://github.com/testdouble/standard/pull/172)

## 0.4.0

* Add `--todo` mode for incremental adoption of Standard to a project ([PR](https://github.com/testdouble/standard/pull/155) by [@mrbiggred](https://github.com/mrbiggred))

## 0.3.0

* Update Standard to track Rubocop 0.82.0 ([commit](https://github.com/testdouble/standard/commit/d663ea62d519c659087ad606bfed031c6303ff20))
