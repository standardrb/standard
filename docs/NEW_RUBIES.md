# Handling New Ruby Versions

When a new Ruby version comes out, you shouldn't have to make any immediate changes to StandardRb. The default configuration is the `base.yml` configuration and should continue to work correctly.

Often, Rubocop will add new rules to encourage usage of new language features in new Ruby versions. When that happens:

1. Add the rule to the base.yml file and disable it.
1. Assess the new rule and see if it should be added to StandardRb. If not, you're done. If so, enable in `base.yml` and read on.
1. Add a new config file for the penultimate minor version of Ruby, so for example, if the new Ruby version is `3.1` then the new config file would be for `3.0`.
1. In the new config file, make sure it inherits from `base.yml` and disable the new rule.
1. In the previous latest config file, make sure it inherits from your new config file.

And that should add new rules to StandardRb safely and gracefully.
