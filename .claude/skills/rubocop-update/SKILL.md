---
name: rubocop-update
description: Bump RuboCop (and standard-performance if a new version exists) to their latest released versions and open a pull request for the standard gem. Use this skill whenever someone asks to update, bump, or upgrade RuboCop, or when preparing a monthly standard release that tracks a new RuboCop version. Also use it when someone asks what new cops RuboCop shipped and how standard should handle them.
---

# Monthly RuboCop Update

This skill automates the monthly RuboCop version bump for the `standard` gem. It updates the RuboCop and standard-performance dependencies, discovers new and changed cops, updates the changelog, bumps the standard version, and opens a pull request — leaving yml configuration of new cops as intentional follow-up work.

## Step 1: Determine current and latest versions

Read `standard.gemspec` to extract the current version constraints. The relevant lines look like:
```ruby
spec.add_dependency "rubocop", "~> 1.84.0"
spec.add_dependency "standard-performance", "~> 1.8"
```

Fetch the latest released versions in parallel from the RubyGems API:
```
GET https://rubygems.org/api/v1/gems/rubocop.json
GET https://rubygems.org/api/v1/gems/standard-performance.json
```
Parse the `version` field from each response.

For rubocop: the current pinned minor is `X.Y` from `~> X.Y.0`. If the latest has the same `X.Y`, this is a patch-only update; otherwise it's a minor bump.

For standard-performance: the current pinned minor is `X.Y` from `~> X.Y`. Compare to the latest.

If neither gem has a newer version, stop and tell the user everything is already up to date.

## Step 2: Update the gemspec

In `standard.gemspec`:

- If rubocop has a new version, change its constraint to `"~> NEW_MAJOR.NEW_MINOR.0"`.  
  Example: `"~> 1.84.0"` → `"~> 1.85.0"`
- If standard-performance has a new minor version, change its constraint to `"~> NEW_MAJOR.NEW_MINOR"`.  
  Example: `"~> 1.8"` → `"~> 1.9"`  
  If standard-performance only has a patch update within the same minor, no gemspec change is needed — the existing pessimistic constraint already allows it.

## Step 3: Update the lockfile

```bash
bundle update rubocop standard-performance
```

(If only one gem changed, pass only that gem's name to `bundle update`.)

## Step 4: Bump the standard version

In `lib/standard/version.rb`, bump the version following this convention:
- Minor bump in rubocop (or standard-performance) → bump standard's minor version
- Patch-only bump in both → bump standard's patch version

Example: `1.54.0` → `1.55.0` for a rubocop minor update.

Then run `bundle` so Bundler writes the new gem version to `Gemfile.lock`.

## Step 5: Find new and modified cops from the RuboCop changelog

Fetch the RuboCop CHANGELOG:
```
GET https://raw.githubusercontent.com/rubocop/rubocop/main/CHANGELOG.md
```

Find all sections with headers between `## <new_rubocop_version>` and `## <old_rubocop_version>` (there may be multiple intermediate releases if we skipped a version). Within those sections, look for two categories:

**New cops** — lines in `### New features` that introduce a brand-new cop:
- Pattern: contains "Add new `Cop/Name`" or "new cop `Cop/Name`"
- Extract: cop name, PR URL, and one-sentence description from the changelog line

**Changed cops** — lines in `### Changes` (not bug fixes) that modify behavior of an existing cop:
- Extract: cop name, PR URL, and what changed

Ignore `### Bug fixes` entries — those don't require configuration decisions.

If standard-performance also bumped, note it in the PR description but no cop-level changelog parsing is needed for it.

## Step 6: Update CHANGELOG.md

Prepend a new entry at the very top of `CHANGELOG.md`, following the existing format exactly:

```markdown
## X.Y.Z

* Updates rubocop to [A.B.C](https://github.com/rubocop/rubocop/releases/tag/vA.B.C)
* Updates standard-performance to [D.E.F](https://github.com/standardrb/standard-performance/releases/tag/vD.E.F)

```

Omit the standard-performance line if it didn't change. Keep every existing line unchanged.

## Step 7: Create a branch, commit, and open a PR

Create a branch named `update-rubocop-A.B.C`.

Stage and commit these files together:
- `standard.gemspec`
- `Gemfile.lock`
- `lib/standard/version.rb`
- `CHANGELOG.md`

Commit message: `Update rubocop to A.B.C` (include `, standard-performance to D.E.F` if it also changed).

Push the branch and open a PR. Title: **"Update rubocop to A.B.C"** (append `and standard-performance to D.E.F` if applicable).

PR description:

```
Updates RuboCop from <old> to <new>.
[If standard-performance changed: Updates standard-performance from <old> to <new>.]

## New cops

These cops were added and need a configuration decision before tests will pass:

| Cop | Description | PR |
|-----|-------------|-----|
| `Style/ExampleCop` | One-line description from changelog | [#12345](link) |

## Changed cops

These existing cops had behavioral changes:

| Cop | Change | PR |
|-----|--------|-----|
| `Style/ExistingCop` | What changed | [#12346](link) |

---

The `config/` YAML files have not been updated for any of the above cops.
Tests are expected to fail until those configurations are added in a follow-up.
```

Omit either table if empty. If there were no new or changed cops, note that in the description instead.
