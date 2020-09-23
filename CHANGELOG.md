# Changelog

## unreleased

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
