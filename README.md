## Standard - Ruby style guide, linter, and formatter

[![CircleCI](https://circleci.com/gh/testdouble/standard.svg?style=svg)](https://circleci.com/gh/testdouble/standard)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/standard.svg)](https://rubygems.org/gems/standard)

This gem is a spiritual port of [StandardJS](https://standardjs.com) and aims
to save you (and others!) time in the same three ways:

* **No configuration.** The easiest way to enforce consistent style in your
  project. Just drop it in.
* **Automatically format code.** Just run `standardrb --fix` and say goodbye to
  messy or inconsistent code.
* **Catch style issues & programmer errors early.** Save precious code review
  time by eliminating back-and-forth between reviewer & contributor.

No decisions to make. It just works. Here's a [⚡ lightning talk ⚡](https://www.youtube.com/watch?v=uLyV5hOqGQ8) about it.

Install by adding it to your Gemfile:

```ruby
gem "standard", group: [:development, :test]
```

And running `bundle install`.

Run Standard from the command line with:

```ruby
$ bundle exec standardrb
```

And if you'd like, Standard can autocorrect your code by tacking on a `--fix`
flag.

## StandardRB — The Rules

- **2 spaces** – for indentation
- **Double quotes for string literals** - because pre-committing to whether
  you'll need interpolation in a string slows people down
- **1.9 hash syntax** - When all the keys in a hash literal are symbols,
  Standard enforces Ruby 1.9's `{hash: syntax}`
- **Semantic blocks** - `{`/`}` for functional blocks that return a value, and
  `do`/`end` for procedural blocks that have side effects. More
  [here](http://www.virtuouscode.com/2011/07/26/the-procedurefunction-block-convention-in-ruby/)
  and [here](https://github.com/rubocop-hq/ruby-style-guide/issues/162)
- **Leading dots on multi-line method chains** - chosen for
  [these](https://github.com/testdouble/standard/issues/75) reasons.
- **Spaces inside blocks, but not hash literals** - In Ruby, the `{` and `}`
  characters do a lot of heavy lifting. To visually distinguish array literals
  from blocks, Standard enforces that (like arrays), no leading or trailing
  spaces be added to pad hashes
- **And a good deal more**

If you're familiar with [RuboCop](https://github.com/rubocop-hq/rubocop), you
can look at Standard's current base configuration in
[config/base.yml](/config/base.yml).

**[NOTE: until StandardRB hits 1.0.0, we consider this configuration to be a
non-final work in progress and we encourage you to submit your opinions (and
reasoned arguments) for the addition, removal, or change to a rule by [opening
an issue](https://github.com/testdouble/standard/issues/new). If you start using
Standard, don't be shocked if things change a bit!]**

## Usage

Once you've installed Standard, you should be able to use the `standardrb`
program. The simplest use case would be checking the style of all Ruby
files in the current working directory:

```bash
$ bundle exec standardrb
standard: Use Ruby Standard Style (https://github.com/testdouble/standard)
standard: Run `standardrb --fix` to automatically fix some problems.
  /Users/code/cli.rb:31:23: Style/Semicolon: Do not use semicolons to terminate expressions.
```

You can optionally pass in a directory (or directories) using the glob pattern. Be
sure to quote paths containing glob patterns so that they are expanded by
`standardrb` instead of your shell:

```bash
$ bundle exec standardrb "lib/**/*.rb" test
```

**Note:** by default, StandardRB will look for all `*.rb` files (and some other
files typically associated with Ruby like `*.gemspec` and `Gemfile`)

### Using with Rake

Standard also ships with Rake tasks. If you're using Rails, these should
autoload and be available after installing Standard. Otherwise, just require the
tasks in your `Rakefile`:

```ruby
require "standard/rake"
```

Here are the tasks bundled with Standard:

```
$ rake standard     # equivalent to running `standardrb`
$ rake standard:fix # equivalent to running `standardrb --fix`
```

You may also pass command line options to Standard's Rake tasks by embedding
them in a `STANDARDOPTS` environment variable (similar to how the Minitest Rake
task accepts CLI options in `TESTOPTS`).

```
# equivalent to `standardrb --format progress`:
$ rake standard STANDARDOPTS="--format progress"

# equivalent to `standardrb lib "app/**/*"`, to lint just certain paths:
$ rake standard STANDARDOPTS="lib \"app/**/*\""
```

## What you might do if you're clever

If you want or need to configure Standard, there are a _handful_ of options
are available creating a `.standard.yml` file in the root of your project.

Here's an example yaml file with every option set:

```yaml
fix: true               # default: false
parallel: true          # default: false
format: progress        # default: Standard::Formatter
ruby_version: 2.3.3     # default: RUBY_VERSION
default_ignores: false  # default: true

ignore:                 # default: []
  - 'db/schema.rb'
  - 'vendor/**/*'
  - 'test/**/*':
    - Layout/AlignHash
```

Note: If you're running Standard in a context where your `.standard.yml` file
cannot be found by ascending the current working directory (i.e. against a
temporary file buffer in your editor), you can specify the config location with
`--config path/to/.standard.yml`.

## What you might do if you're REALLY clever

Because StandardRB is essentially a wrapper on top of
[RuboCop](https://github.com/rubocop-hq/rubocop), it will actually forward the
vast majority of CLI and ENV arguments forward to RuboCop.

You can see a list of
[RuboCop](https://docs.rubocop.org/en/latest/basic_usage/#other-useful-command-line-flags)'s
CLI flags here.

## Why should I use Ruby Standard Style?

(This section will [look
familiar](https://github.com/standard/standard#why-should-i-use-javascript-standard-style)
if you've used StandardJS.)

The beauty of Ruby Standard Style is that it's simple. No one wants to
maintain multiple hundred-line style configuration files for every module/project
they work on. Enough of this madness!

This gem saves you (and others!) time in three ways:

- **No configuration.** The easiest way to enforce consistent style in your
  project. Just drop it in.
- **Automatically format code.** Just run `standardrb --fix` and say goodbye to
  messy or inconsistent code.
- **Catch style issues & programmer errors early.** Save precious code review
  time by eliminating back-and-forth between reviewer & contributor.

Adopting Standard style means ranking the importance of code clarity and
community conventions higher than personal style. This might not make sense for
100% of projects and development cultures, however open source can be a hostile
place for newbies. Setting up clear, automated contributor expectations makes a
project healthier.

## Who uses Ruby Standard Style?

(This section will not [look very
familiar](https://github.com/standard/standard#who-uses-javascript-standard-style)
if you've used StandardJS.)

* [Test Double](https://testdouble.com/agency)
* [Collective Idea](https://collectiveidea.com/)
* [Culture Foundry](https://www.culturefoundry.com/)
* [Evil Martians](https://evilmartians.com)
* [Rebase Interactive](https://www.rebaseinteractive.com/)
* [Hashrocket](https://hashrocket.com)
* [Brand New Box](https://brandnewbox.com)
* [Monterail](https://www.monterail.com)
* And that's about it so far!

If your team starts using Standard, [send a pull
request](https://github.com/testdouble/standard/edit/master/README.md) to let us
know!

## Is there a readme badge?

Yes! If you use Standard in your project, you can include one of these
badges in your readme to let people know that your code is using the StandardRB
style.

[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

```md
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
```

## I disagree with rule X, can you change it?

**[NOTE: until StandardRB hits 1.0.0, the answer is yes! It just requires
[opening an issue](https://github.com/testdouble/standard/issues/new) and
convincing [@searls](https://twitter.com/searls) (the BDFNow) to make the
change.]**

No. The whole point of Standard is to save you time by avoiding
[bikeshedding](https://www.freebsd.org/doc/en/books/faq/misc.html#bikeshed-painting)
about code style. There are lots of debates online about tabs vs. spaces, etc.
that will never be resolved. These debates just distract from getting stuff
done. At the end of the day you have to 'just pick something', and that's the
whole philosophy of Standard -- its a bunch of sensible 'just pick something'
opinions. Hopefully, users see the value in that over defending their own
opinions.

Pro tip: Just use Standard and move on. There are actual real problems that
you could spend your time solving! :P

## Is there an automatic formatter?

Yes! You can use `standardrb --fix` to fix most issues automatically.

`standardrb --fix` is built into `standardrb` for maximum convenience. Most
problems are fixable, but some errors must be fixed manually.

## Can I override the `fix: true` config setting?

Also yes! You can use `standardrb --no-fix`. Not `fix`ing is the default behavior, but this flag will override the `fix: true` setting in your [`.standard.yml` config](#what-you-might-do-if-youre-clever). This is especially useful for checking your projects compliance with `standardrb` in CI environments while keeping the `fix: true` option enabled locally.

## How do I ignore files?

Sometimes you need to ignore additional folders or specific minified files. To
do that, add a `.standard.yml` file to the root of your project and specify a
list of files and globs that should be excluded:

```yaml
ignore:
  - 'some/file/in/particular.rb'
  - 'a/whole/directory/**/*'
```

You can see the files Standard ignores by default
[here](https://github.com/testdouble/standard/blob/master/lib/standard/creates_config_store/configures_ignored_paths.rb#L3-L13)

## How do I hide a certain warning?

In rare cases, you'll need to break a rule and hide the warning generated by
Standard.

Ruby Standard Style uses [RuboCop](https://github.com/rubocop-hq/rubocop)
under-the-hood and you can hide warnings as you normally would if you used
RuboCop directly.

To ignore only certain rules from certain globs (not recommended, but maybe your
test suite uses a non-standardable DSL, you can specify an array of RuboCop
rules to ignore for a particular glob:

```yaml
ignore:
  - 'test/**/*':
    - Style/BlockDelimiters
```

You can also use special comments to disable all or certain rules within your
source code. See [RuboCop's
docs](https://docs.rubocop.org/en/latest/configuration/#disabling-cops-within-source-code)
for details.

## How do I specify a Ruby version? What is supported?

Because Standard wraps RuboCop, they share the same [runtime
requirements](https://github.com/rubocop-hq/rubocop#compatibility)—currently,
that's MRI 2.3 and newer. While Standard can't avoid this runtime requirement,
it does allow you to lint codebases that target Ruby versions older than 2.3 by
narrowing the ruleset somewhat.

Standard will default to telling RuboCop to target the currently running version
of Ruby (by inspecting `RUBY_VERSION` at runtime. But if you want to lock it
down, you can specify `ruby_version` in `.standard.yml`.

```
ruby_version: 1.8.7
```

See
[testdouble/suture](https://github.com/testdouble/suture/blob/master/.standard.yml)
for an example.

It's a little confusing to consider, but the targeted Ruby version for linting
may or may not match the version of the runtime (suppose you're on Ruby 2.5.1,
but your library supports Ruby 2.3.0). In this case, specify `ruby_version` and
you should be okay. However, note that if you target a _newer_ Ruby version than
the runtime, RuboCop may behave in surprising or inconsistent ways.

If you are targeting a Ruby older than 2.3 and run into an issue, check out
Standard's [version-specific RuboCop
configurations](https://github.com/testdouble/standard/tree/master/config) and
consider helping out by submitting a pull request if you find a rule that won't
work for older Rubies.

## How do I change the output?

Standard's built-in formatter is intentionally minimal, printing only unfixed
failures or (when successful) printing nothing at all. If you'd like to use a
different formatter, you can specify any of RuboCop's built-in formatters or
write your own.

For example, if you'd like to see colorful progress dots, you can either run
Standard with:

```
$ bundle exec standardrb --format progress
Inspecting 15 files
...............

15 files inspected, no offenses detected
```

Or, in your project's `.standard.yml` file, specify:

```yaml
format: progress
```

Refer to RuboCop's [documentation on
formatters](https://rubocop.readthedocs.io/en/latest/formatters/) for more
information.

## How do I run standard in my editor?

It can be very handy to know about failures while editing to shorten the
feedback loop. Some editors support asynchronously running linters.

- [Atom](https://github.com/testdouble/standard/wiki/IDE:-Atom)
- [emacs (via flycheck)](https://github.com/julianrubisch/flycheck-standardrb)
- [RubyMine](https://www.jetbrains.com/help/ruby/rubocop.html#disable_rubocop)
- [vim (via ALE)](https://github.com/testdouble/standard/wiki/IDE:-vim)
- [VS Code](https://github.com/testdouble/standard/wiki/IDE:-vscode)

## Does Standard work with [Insert other tool name here]?

Maybe! Start by searching the repository to see if there's an existing issue open for 
the tool you're interested in. That aside, here are other known integrations aside
from editor plugins:

* [Pronto](https://github.com/julianrubisch/pronto-standardrb)

## Contributing

Follow the steps below to setup Standard using [Docker](https://www.docker.com/):

```bash
$ git clone https://github.com/testdouble/standard
$ cd standard
$ docker-compose build
$ docker-compose run app rake # to run test suite
```

The Docker image is built using [Alpine Linux](https://alpinelinux.org/) which 
uses `sh` instead of `bash`.  So to access the image you need to run:

```bash
$ docker-compose run app sh
```

Don't feel like using Docker?  The follow the steps below to setup standard locally:

```bash
$ git clone https://github.com/testdouble/standard
$ cd standard
$ gem install bundler # if working with ruby version below 2.6.0
$ bundle install
$ bundle exec rake # to run test suite
```

## Code of Conduct
This project follows Test Double's [code of conduct](https://testdouble.com/code-of-conduct) for all community interactions, including (but not limited to) one-on-one communications, public posts/comments, code reviews, pull requests, and GitHub issues. If violations occur, Test Double will take any action they deem appropriate for the infraction, up to and including blocking a user from the organization's repositories.
