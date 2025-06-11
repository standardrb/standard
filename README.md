<img src="https://user-images.githubusercontent.com/79303/233717126-9fd13e6d-9a66-4f1c-b40c-fe875cb1d1b4.png" style="width: 100%"/>

[![Tests](https://github.com/standardrb/standard/actions/workflows/test.yml/badge.svg)](https://github.com/standardrb/standard/actions/workflows/test.yml)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/standardrb/standard)
[![Gem Version](https://badge.fury.io/rb/standard.svg)](https://rubygems.org/gems/standard)

The `standard` gem brings the ethos of [StandardJS](https://standardjs.com) to
Ruby. It's a linter & formatter built on
[RuboCop](https://github.com/rubocop/rubocop) and provides an **unconfigurable
configuration** to all of RuboCop's built-in rules as well as those included in
[rubocop-performance](https://github.com/rubocop/rubocop-performance). It also
supports plugins built with
[lint_roller](https://github.com/standardrb/lint_roller), like
[standard-rails](https://github.com/standardrb/standard-rails) and
[standard-sorbet](https://github.com/standardrb/standard-sorbet).

Standard Ruby was created and is maintained by the team at [Test
Double](https://testdouble.com), because we appreciate the importance of
balancing predictable, consistent code with preserving developer autonomy. 💚

Topics covered in this README:

* [Wait, what?!](#wait-did-you-say-unconfigurable-configuration)
* [Basic usage](#usage)
* [Editor & CI integrations](#integrating-standard-into-your-workflow)
* [Ignoring errors](#ignoring-errors)
* [Configuration options](#configuring-standard)
* [Plugins and extensions](#extending-standard)
* [Community](#who-uses-standard-ruby)

## Wait, did you say unconfigurable configuration?

Yes, Standard is unconfigurable. See, pretty much every developer can agree that
automatically identifying and fixing slow, insecure, and error-prone code is a
good idea. People also agree it's easier to work in codebases that exhibit a
consistent style and format. So, what's the problem? **No two developers will
ever agree on what all the rules and format should be.**

This has resulted in innumerable teams arguing about how to configure their linters
and formatters over literal decades. Some teams routinely divert time and energy
from whatever they're building to reach consensus on where commas should go.
Other teams have an overzealous tech lead who sets up everything _his favorite
way_ and then imposes his will on others. It's not uncommon to witness
passive-aggressive programmers change a contentious rule back-and-forth,
resulting in both acrimony and git churn (and acrimony _about_ git churn).
Still, most developers give way to whoever cares more, often resulting in an
inconsistent configuration that nobody understands and isn't kept up-to-date
with changes to their linter and its target language. Whatever the approach,
time spent
[bikeshedding](https://blog.testdouble.com/posts/2019-09-17-bike-shed-history/)
is time wasted.

**But you can't configure Standard Ruby.** You can take it or leave it. If this
seems presumptive, constraining, and brusque: you're right, it usually does feel
that way at first. But [since
2018](https://www.youtube.com/watch?v=uLyV5hOqGQ8), the Ruby community has
debated Standard Ruby's ruleset, ultimately landing us on a
[sensible](/config/base.yml)
[set](https://github.com/standardrb/standard-performance/blob/main/config/base.yml)
of
[defaults](https://github.com/standardrb/standard-custom/blob/main/config/base.yml)
that—_while no one person's favorite way to format Ruby_—seems to be good enough
for most of the ways people use Ruby, most of the time.

If you adopt Standard Ruby, what's in it for you? Time saved that would've been
spent arguing over how to set things up. Also, seamless upgrades: we stay on top
of each new RuboCop rule and update our configuration on a monthly release
cadence. But the best part of adopting Standard as your linter and formatter?
**You'll spend a whole lot less time thinking about linters and formatters.**

So please, give Standard Ruby a try. If you're like [these
folks](#who-uses-standard-ruby), you'll soon realize that the value of a linter
is in using one at all and not in the particulars of how it's configured.

## Usage

### Install

Getting started is as easy as `gem install standard` or throwing it in your
project's Gemfile and running `bundle install`:

```ruby
gem "standard"
```

### Running Standard Ruby

Once installed, you can run Standard from the command line via its built-in
executable or as a Rake task.

Standard Ruby's binary is named `standardrb` to distinguish it from
[StandardJS](https://github.com/standard/standard):

```
$ standardrb
```

And the Rake task can be run if your Rakefile includes `require
"standard/rake"`.  This will load the `standard` task, allowing you to run:

```
$ rake standard
```

Either way, Standard will inspect any Ruby files found in the current directory
tree. If any errors are found, it'll report them. If your code is
standard-compliant, it will get out of your way by quietly exiting code 0.

### Fixing errors

A majority of Standard's rules can be safely fixed automatically.

```
# CLI
$ standardrb --fix

# Rake
$ rake standard:fix
```

Because we're confident Standard's fixes won't change the behavior of our code,
we typically run with fix enabled _all the time_ because it saves us from having
to look at and think about problems the computer can solve for us.

### Applying unsafe fixes

There are a number of other rules that can be automatically remedied, but not
without the risk of changing your code's behavior. While we wouldn't recommend
running it all the time, if the CLI suggests that additional errors can be fixed
_unsafely_, here's how to do that:

```
# CLI
$ standardrb --fix-unsafely

# Rake
$ rake standard:fix_unsafely
```

So long as your code is checked into source control, there's no mortal harm in
running with unsafe fixes enabled. If the changes look good to you and your
tests pass, then it's probably no more error prone than manually editing
every change by hand.

## Integrating Standard into your workflow

Because code formatting is so integral to programming productivity and linter
violations risk becoming bugs if released into production, tools like
Standard Ruby are only as useful as their integration into code editors and
continuous integration systems.

### Editor support

We've added a number of editing guides for getting started:

- [Atom](https://github.com/standardrb/standard/wiki/IDE:-Atom)
- [emacs](https://www.flycheck.org/en/latest/languages.html#syntax-checker-ruby-standard)
- [Helix](https://github.com/helix-editor/helix/wiki/Formatter-configurations#standardrb)
- [neovim](https://github.com/standardrb/standard/wiki/IDE:-neovim)
- [Nova](https://codeberg.org/edwardloveall/nova-standard)
- [RubyMine](https://www.jetbrains.com/help/ruby/rubocop.html#disable_rubocop)
- [vim](https://github.com/standardrb/standard/wiki/IDE:-vim)
- [VS Code](https://github.com/standardrb/standard/wiki/IDE:-vscode)
- [Zed](https://zed.dev/docs/languages/ruby#setting-up-ruby-lsp)
- [Sublime Text](https://github.com/standardrb/standard/wiki/IDE:-Sublime-Text)

If you'd like to help by creating a guide, please draft one [in an
issue](https://github.com/standardrb/standard/issues/new) and we'll get it
added!

#### Language Server Protocol support

If you don't see your preferred editor above, Standard Ruby also offers robust
[language server](https://microsoft.github.io/language-server-protocol/) support,
in two ways, both included with the `standard` gem:

1. A [Ruby LSP](https://github.com/Shopify/ruby-lsp) add-on, which (if
the `standard` gem is in your `Gemfile`) will be loaded automatically
2. A language server executable, which can be run from the command line
   with `standardrb --lsp`

| Capability  | Ruby LSP Add-on | Internal Server |
| ------------- | ------------- | ------------- |
| Diagnostics (Linting) | ✅ ([Pull](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_pullDiagnostics)) | ✅ ([Push](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_publishDiagnostics)) |
| [Formatting](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_formatting)  | ✅ | ✅ |
| [Code Actions](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_codeAction) | ✅ | ❌ |
| Everything else  | ❌  | ❌ |

Due to the advantages of Pull diagnostics and its inclusion of Code Actions
("Quick Fixes" in VS Code parlance), we recommend using Standard's [Ruby LSP
add-on](https://github.com/standardrb/standard/wiki/IDE:-vscode#using-ruby-lsp)
where possible.

Regardless of which language server you use, many editors have added LSP
support, with each bringing their own approach to configuration. Many LSP
features should "just work", but when in doubt, please consult our [editor
guides above](#editor-support) as well as your editor's own documentation on how
to configure LSP formatters and linters.

### CI support

Various continuous integration and quality-checking tools have been made to
support Standard Ruby, as well.

* [GitHub Actions](https://github.com/standardrb/standard-ruby-action)
* [Code Climate](https://github.com/standardrb/standard/wiki/CI:-Code-Climate)
* [Pronto](https://github.com/julianrubisch/pronto-standardrb)
* [Danger](https://github.com/ashfurrow/danger-rubocop/)

Of course, no special plugin is necessary to run Standard Ruby in a CI
environment, as `standardrb` and `rake standard` work just fine on their own!

### Other tools

These tool integrations are also available:

* [Guard](https://github.com/JodyVanden/guard-standardrb)
* [Spring](https://github.com/lakim/spring-commands-standard)

## Ignoring errors

While Standard is very strict in how each formatting and linting rule is configured,
it's mercifully flexible when you need to ignore a violation to focus on a higher
priority (like, say, keeping the build running). There are a number of ways to
ignore any errors, with the right answer depending on the situation.

### Ignoring a line with a comment

Individual lines can be ignored with a comment directive at the end of the line.
As an example, the line `text = 'hi'` violates two rules,
[Lint/UselessAssignment](https://docs.rubocop.org/rubocop/cops_lint.html#lintuselessassignment)
and
[Style/StringLiterals](https://docs.rubocop.org/rubocop/cops_style.html#stylestringliterals).

You could ignore one, both, or all errors with the following comments:

```ruby
# Disable one error but keep Lint/UselessAssignment
text = 'hi' # standard:disable Style/StringLiterals

# Disable both errors explicitly
text = 'hi' # standard:disable Style/StringLiterals, Lint/UselessAssignment

# Disable all errors on the line with "all"
text = "hi" # standard:disable all
```

### Ignoring multiple lines with comments

Similarly to individual lines, you can also disable multiple lines by wrapping
them in comments that disable and re-enable them:

```ruby
# standard:disable Style/StringLiterals, Lint/UselessAssignment
text = "hi"
puts 'bye'
# standard:enable Style/StringLiterals, Lint/UselessAssignment
```

### Ignoring entire files and globs

You can ignore entire files and file patterns by adding them to `ignore:` in
your project's `.standard.yml` file:

```yaml
ignore:
  - 'some/file/in/particular.rb'
  - 'a/whole/directory/**/*'
```

### Ignoring specific rules in files and globs

For a given file or glob, you can even ignore only specific rules by nesting an
array of the rules you'd like to ignore:

```yaml
ignore:
  - 'test/**/*':
    - Layout/AlignHash
```

### Ignoring every violation and converting them into a todo list

If you're adopting Standard in a large codebase and you don't want to convert
everything all at once, you can work incrementally by generating a "todo" file
which will cause Standard to ignore every violation present in each file of the
codebase.

This way, you can gradually work through the todo list, removing ignore
directives and fixing any associated errors, while also being alerted to any
regressions if they're introduced into the project.

Here are the commands you might run to get started:

```
# Start by clearing any auto-fixable errors:
$ standardrb --fix

# Generate a `.standard_todo.yml' to work from
$ standardrb --generate-todo
```

## Configuring Standard

While the rules aren't configurable, Standard offers a number of options that
can be configured as CLI flags and YAML properties.

### CLI flags

The easiest way to summarize the available CLI flags is to invoke `standardrb -h`:

```
Usage: standardrb [--fix] [--lsp] [-vh] [--format <name>] [--] [FILE]...

Options:

  --fix             Apply automatic fixes that we're confident won't break your code
  --fix-unsafely    Apply even more fixes, including some that may change code behavior
  --no-fix          Do not automatically fix failures
  --format <name>   Format output with any RuboCop formatter (e.g. "json")
  --generate-todo   Create a .standard_todo.yml that lists all the files that contain errors
  --lsp             Start a LSP server listening on STDIN
  -v, --version     Print the version of Standard
  -V, --verbose-version   Print the version of Standard and its dependencies.
  -h, --help        Print this message
  FILE              Files to lint [default: ./]

Standard also forwards most CLI arguments to RuboCop. To see them, run:

  $ rubocop --help
```

If you run Standard via Rake, you can specify your CLI flags in an environment
variable named `STANDARDOPTS` like so:

```
$ rake standard STANDARDOPTS="--format progress"
```

### YAML options

In addition to CLI flags, Standard will search for a `.standard.yml` file
(ascending to parent directories if the current working directory doesn't
contain one). If you find yourself repeatedly running Standard with the same
CLI options, it probably makes more sense to set it once in a YAML file:

```yaml
fix: true               # default: false
parallel: true          # default: false
format: progress        # default: Standard::Formatter
ruby_version: 3.0       # default: RUBY_VERSION
default_ignores: false  # default: true

ignore:                 # default: []
  - 'vendor/**/*'

plugins:                # default: []
  - standard-rails

extend_config:                # default: []
  - .standard_ext.yml
```

#### Configuring ruby_version

One notable YAML setting is `ruby_version`, which allows you to set the **oldest
version of Ruby the project needs to support** [RuboCop's `TargetRubyVersion`
setting](https://docs.rubocop.org/rubocop/configuration.html#setting-the-target-ruby-version)
explicitly. Because this value is inferred from any `.ruby-version`,
`.tool-versions`, `Gemfile.lock`, and `*.gemspec` files that might be present,
most applications won't need to set this.

However, gems and libraries that support older versions of Ruby will want
to lock the `ruby-version:` explicitly in their `.standard.yml` file to ensure
new rules don't break old rubies:

```yaml
ruby_version: 2.7
```

## Extending Standard

Standard includes two extension mechanisms: plugins and configuration
extensions. While neither can _change_ the rules configured out-of-the-box by
Standard, they can define, require, and configure _additional_ RuboCop rules.

Both are "first-in-wins", meaning once a rule is configured by a plugin or
extension, it can't be changed or reconfigured by a later plugin or extension.
This way, each Standard plugin you add becomes a de facto "standard" of its
own. Plugins have precedence over extensions as they are loaded first.

### Plugins

Adding a plugin to your project is as easy as adding it to your Gemfile and
specifying it in `.standard.yml` in the root of your project. For example, after
installing [standard-rails](https://github.com/standardrb/standard-rails), you
can configure it by adding it to `plugins`:

```yaml
plugins:
  - standard-rails
```

Each plugin can be passed configuration options by specifying them in a nested
hash. For example, `standard-rails` allows you to configure its rules for
a particular version of Rails (though this will usually be detected for you
automatically):

```yaml
plugins:
  - standard-rails:
      target_rails_version: 7.0
```

You can develop your own plugins, too! Check out the
[lint_roller](https://github.com/standardrb/lint_roller) gem to learn how. For a
simple example, you can look at
[standard-custom](https://github.com/standardrb/standard-custom), which is one
of the default plugins included by Standard.

### Extended config files

Of course, you may want to add more rules without going to the trouble
of packaging them in a plugin gem. For cases like this, you can define one or
more [RuboCop configuration
files](https://docs.rubocop.org/rubocop/configuration.html) and then list them
in your `.standard.yml` file under `extend_config`.

For example, after installing the
[betterlint](https://github.com/Betterment/betterlint) gem from our friends at
[Betterment](https://www.betterment.com), we could create a RuboCop config
file named `.betterlint.yml`:

```yaml
require:
  - rubocop/cop/betterment.rb

Betterment/UnscopedFind:
  Enabled: true

  unauthenticated_models:
    - SystemConfiguration
```

And then reference it in our `.standard.yml`:

```yml
extend_config:
  - .betterlint.yml
```

### Running Standard's rules via RuboCop

**Please note that the following usage is not supported and may break at any
time. Use at your own risk and please refrain from opening GitHub issues with
respect to loading Standard or its plugins' YAML configurations for use by
the `rubocop` CLI.**

If you find that neither plugins or configuration extensions meet your needs or
if you have some other reason to run Standard's rules with RuboCop's CLI (e.g.,
to continue using your favorite IDE/tooling/workflow with RuboCop support) Evil
Martians also maintains [a regularly updated
guide](https://evilmartians.com/chronicles/rubocoping-with-legacy-bring-your-ruby-code-up-to-standard)
on how to configure RuboCop to load and execute Standard's ruleset.

In short, you can configure this in your `.rubocop.yml` to load Standard's three
default rulesets, just as you would any other gem:

```yaml
require:
  - standard
  - standard-custom
  - standard-performance
  - rubocop-performance

inherit_gem:
  standard: config/base.yml
  standard-custom: config/base.yml
  standard-performance: config/base.yml
```

## Who uses Standard Ruby?

Here are a few examples of Ruby Standard-compliant teams & projects:

* [Test Double](https://testdouble.com/agency)
* [AdBarker](https://adbarker.com)
* [AlchemyCMS](https://alchemy-cms.com)
* [Amazon Web Services](https://aws.amazon.com/)
* [Arrows](https://arrows.to/)
* [Avo Admin](https://avohq.io/)
* [Babylist](https://www.babylist.com/)
* [BLISH](https://blish.cloud)
* [Brand New Box](https://brandnewbox.com)
* [Brave Software](https://github.com/brave-intl/publishers)
* [Collective Idea](https://collectiveidea.com/)
* [Culture Foundry](https://www.culturefoundry.com/)
* [Datadog](https://www.datadoghq.com/)
* [Donut](https://www.donut.com/)
* [Elevate Labs](https://elevatelabs.com)
* [Envoy](https://www.envoy.com)
* [Evil Martians](https://evilmartians.com)
* [Firstline](https://firstline.org/)
* [Hashrocket](https://hashrocket.com)
* [Honeybadger](https://www.honeybadger.io)
* [JetThoughts](https://www.jetthoughts.com/)
* [Level UP Solutions](https://levups.com)
* [Lobsters](https://github.com/lobsters/lobsters)
* [Monterail](https://www.monterail.com)
* [myRent](https://www.myrent.co.nz)
* [OBLSK](https://oblsk.com/)
* [Oyster](https://www.oysterhr.com/)
* [Planet Argon](https://www.planetargon.com/)
* [PLT4M](https://plt4m.com/)
* [Podia](https://www.podia.com/)
* [Privy](https://www.privy.com/)
* [Rebase Interactive](https://www.rebaseinteractive.com/)
* [Renuo](https://www.renuo.ch/)
* [RubyCI](https://ruby.ci)
* [SearchApi](https://www.searchapi.io/)
* [Spinal](https://spinalcms.com/)
* [Teamtailor](https://www.teamtailor.com/)
* [thoughtbot](https://thoughtbot.com/)
* [Topkey](https://topkey.io)
* [University of Wisconsin-Eau Claire](https://www.uwec.edu/)
* [Cartwheel](https://www.cartwheel.org)

Does your team use Standard? [Add your name to the list](https://github.com/standardrb/standard/edit/main/README.md)!

If you really want to show off, you can also add a badge to your project's README, like this one:

[![Ruby Code Style](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/standardrb/standard)

```md
[![Ruby Code Style](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/standardrb/standard)
```

## Help, I'm seeing an install error!

This section is really only here to feed Google, but if you see an error like
any of the following:

```
ERROR:  Could not find a valid gem 'standard' (= 0.0.36) in any repository
```

```
Could not find gem 'standard (= 0.0.36)' in rubygems repository https://rubygems.org/ or installed locally.
```

```
Your bundle is locked to standard (0.0.36) from rubygems repository https://rubygems.org/ or installed locally, but that version can no longer be found in that source. That means the author of standard (0.0.36) has removed it. You'll need to update your bundle to a version other than standard (0.0.36) that hasn't been removed in order to install.
```

This is because on August 18th, 2023, we yanked versions 0.0.1~0.0.36.1 from
[RubyGems.org](https://rubygems.org) for the reasons discussed in [this
issue](https://github.com/standardrb/standard/issues/340). Because these
versions are now over four years old and no longer track supported versions of
Ruby or RuboCop, the correct fix for any of the above errors is probably to
**upgrade to the latest version of Standard Ruby**.

If for whatever reason you need to install one of these versions, you can
change your Gemfile to point to the corresponding git tag from the source
repository:

```ruby
gem "standard", git: "https://github.com/testdouble/standard.git", tag: "v0.0.36"
```

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.
