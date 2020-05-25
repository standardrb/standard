# Changelog

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

