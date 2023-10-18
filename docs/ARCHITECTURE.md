# Standard Ruby's Architecture

Architecture is not a 4-letter word (but the silly abbreviation 'a10e' is!), so
as Standard's internal structure has introduced more moving parts, it's
important to plant a stake in the ground and explain where all the cops are
buried.

Starting with version 1.28.0, Standard Ruby introduced plugin support and
refactored how it loads its own rules from one large YAML file into several
plugins. As a result, what was a single `standard` gem is now spread across 3
gems.

Here's how it's all organized:

* [standard](https://github.com/standardrb/standard) - The main gem. The one
people install and think of. Because `standard` has a hard dependency on `rubocop`,
the base configuration of RuboCop's built-in rules is bundled into the gem, even
though it's now [defined as a plugin](lib/standard/base/plugin.rb)
* [standard-performance](https://github.com/standardrb/standard-performance) - A
plugin that depends on and configures
[rubocop-performance](https://github.com/rubocop/rubocop-performance)
* [standard-custom](https://github.com/standardrb/standard-custom) - A plugin
that implements and configures any custom rules that the Standard team writes
and maintains itself with the intention that they be part of the default
Standard Ruby experience (there's only one of these rules so far)

To glue these things together, yet another gem was created (gems are free,
right?) to define a very simple plugin API. That gem is called
[lint_roller](https://github.com/standardrb/lint_roller) and it can be used by
any gem that provides or consumes linting and formatting rules. Because Standard
Ruby is built on RuboCop's configuration and runner, RuboCop could adopt
`lint_roller` as its plugin system and plugins could support both `rubocop`
and `standard` out of the box.
