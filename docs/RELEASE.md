# How to release Standard Ruby

Because this gem was generated with the [bundler `gem`
command](https://bundler.io/man/bundle-gem.1.html), [our Rakefile](/Rakefile)
loads `bundler/gem_tasks`, which provides a lot of the commands one needs
to manage a gem's release lifecycle:

```
$ rake -T
rake build            # Build standard-x.x.x.gem into the pkg directory
rake clean            # Remove any temporary products
rake clobber          # Remove any generated files
rake install          # Build and install standard-x.x.x.gem into system gems
rake install:local    # Build and install standard-x.x.x.gem into system gems without network access
rake release[remote]  # Create tag vx.x.x and build and push standard-0.5.2.gem to rubygems.org
```

Most of these commands are depended on (read: run by) `./bin/rake release`, which is
really the only one we'll need for releasing the gem to
[Rubygems.org](https://rubygems.org/gems/standard).

## Release steps

1. Make sure git is up to date and `./bin/rake` exits cleanly
1. If you upgraded a Rubocop dependency, be sure to lock it down in
   `standard.gemspec`. To avoid being broken transitively, we stick to exact
   release dependencies (e.g. "0.91.0" instead of "~> 0.91")
1. Update `CHANGELOG.md` as exhaustively as you are able and set the top header
   to "Unreleased"
1. Bump the appropriate version segment in `lib/standard/version.rb` (basic
   semantic versioning rules apply; if the release updates Rubocop, follow its
   version bump at a minimum—if rubocop saw minor bump, we'll also bump the
   minor version)
1. Run `bundle` so that Bundler writes this version to `Gemfile.lock`
1. Commit `lib/standard/version.rb`, `Gemfile.lock`, and `CHANGELOG.md` together
   with the message equal to the new version (e.g. "0.42.1")
1. Finally, run `./bin/rake release`, which will hopefully succeed
1. Provide your multi-factor-auth token when prompted to finish publishing the
   gem
1. [Tweet](https://twitter.com) about your awesome new release! (Shameless
   self-promotion is the most important part of open source software)
