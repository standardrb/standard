# Upgrading Standard

Since standard now encompasses both a tool itself and a series of plug-ins it makes sense to first update the standard plug-ins and then the standard tool itself. Each plug-in is a configuration for its corresponding rubocop plug-in.

The official standard plug-ins that are included in standard are:

- **Standard Performance:** corresponding to rubocop-performance
- **Standard Custom:** for custom cops created for standard

## Updating Standard Plugins

1. Update Rubocop plugin in the gemspec file and gem file.
1. Keep standard in the gem file up-to-date. This will bring any testing utilities in standard into the plug-in repository.
1. Run `./bin/rake` to run the tests
1. Configure any cops that need to be configured so that the tests pass
1. Update the change log to the best of your ability and title it as unreleased
1. Make your commit for these updates and push to the main branch
1. Update the version in version.rb and update the version in the Changelog replacing the word “Unreleased”
1. Run bundle to write the new version number to the lock file
1. Run `./bin/rake release` to release the gem to RubyGems and create the version git tag. Push the tag to GitHub.

## Updating Standard

1. Update Rubocop as well as Standard Performance in the gemspec file and gem file.
1. Run `./bin/rake` to run the tests
1. Configure any cops that need to be configured so that the tests pass
1. Update the change log to the best of your ability and title it as unreleased
1. Make your commit for these updates and push to the main branch
1. Update the version in version.rb and update the version in the Changelog replacing the word “Unreleased”
1. Run bundle to write the new version number to the lock file
1. Run `./bin/rake` to release the gem to RubyGems and create the version git tag. Push the tag to GitHub.
