# Ruby versions

## Handling new releases

When a new Ruby version comes out, you shouldn't have to make any immediate
changes to Standard Ruby. The default configuration is the `base.yml`
configuration and should continue to work correctly.

Often, Rubocop will add new rules to encourage usage of new language features in
new Ruby versions. When that happens:

1. Add the rule to the `base.yml` file and disable it.
1. Assess the new rule and see if it should be added to Standard Ruby. If not,
   you're done. If so, enable it in `base.yml` and read on.
1. Add a new config file for the penultimate minor version of Ruby. For example,
   if the new version is `3.1` then the new config file would be for `3.0`.
1. In the new config file, make sure it inherits from `base.yml` and disable the
   new rule.
1. In what was previously the latest config file, make sure it inherits from
   your new config file.

That should add new rules to Standard Ruby safely and gracefully.

## Maintenance and support

We will support the actively maintained ruby versions from the [ruby maintenance
policy](https://www.ruby-lang.org/en/downloads/branches/) along with the most
recently EOL version for an additional ~9 months, dropping support for EOL
versions around the time that a new supported ruby version is released and
added.

With the current ruby release cadence (new version near end of year, EOL drop
around April 1), this means we'll have a release of all the Standard gems around
the new year which adds support for the new ruby version and drops support for
what was an already-EOL but still-supported older ruby version.

## Coordination across gems

We will align versions/dependencies amongst the Standard gems:

- [standard-custom](https://github.com/standardrb/standard-custom)
- [standard-performance](https://github.com/standardrb/standard-performance)
- [standard-rails](https://github.com/standardrb/standard-rails)
- [standard-sorbet](https://github.com/standardrb/standard-sorbet)
- [standard](https://github.com/standardrb/standard)

This means keeping them consistent in regard to:

- The minimum required ruby version configured in their `gemspec`
- Using that version in their internal `.standard.yml` configurations
- Including the full range of supported rubies in their CI ruby matrix
