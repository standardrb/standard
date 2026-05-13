---
name: rubocop-update
description: Bump RuboCop and standard-performance to their latest versions and open a PR. Use this for monthly updates or when tracking new cops.
---

# RuboCop Update

This skill automates the RuboCop version bump for `standard`. It uses CLI tools for efficiency and consistency with the project's GitHub Actions.

## Step 1: Check for Updates

Identify outdated gems and their versions:
```bash
bundle outdated rubocop standard-performance
```
Note the **current** and **newest** versions for both gems.

## Step 2: Update Gemspec and Lockfile

Use `sed` to update `standard.gemspec` for any gem with a new minor/patch version.
Example for RuboCop:
```bash
sed -i '/"rubocop"/s/OLD_VERSION/NEW_VERSION/' standard.gemspec
```
*Note: RuboCop constraint should be `~> MAJOR.MINOR.0`. standard-performance should be `~> MAJOR.MINOR`.*

Then update the lockfile:
```bash
bundle update rubocop standard-performance
```

## Step 4: Parse RuboCop Changelog

Generate the "New Cops" and "Changed Cops" tables for the PR description:
```bash
curl -s https://raw.githubusercontent.com/rubocop/rubocop/main/CHANGELOG.md | \
  .claude/skills/rubocop-update/scripts/parse_changelog.rb --old OLD_RUBOCOP_VER --new NEW_RUBOCOP_VER > pr_body.md
```

## Step 5: Evaluate New Rules (Standard Ethos)

For each cop in the "New cops" table, replace the `{RECOMMENDATION}` and `{RATIONALE}` placeholders with a recommendation and a paragraph explaining the rationale.

**Ethos Guidelines (from Standard Ruby):**
- **Enable if:** It has a **safe autocorrect**, improves readability, encourages modern Ruby, or reduces errors without being niche.
- **Ignore/Disable if:** It is purely stylistic (bikeshedding), has an unsafe autocorrect, is overly restrictive, or causes high friction/noise for little gain.

**Recommendation Format:**
- **Recommendation:** `Enable` or `Ignore`.
- **Rationale:** A concise paragraph explaining how the rule aligns with or deviates from the Standard ethos.

## Step 6: Update CHANGELOG.md


Prepend the update note after the `# Changelog` header. Since the standard version is bumped separately, add this under a `## Unreleased` header if it doesn't exist, or at the top of the existing unreleased section:
```bash
sed -i '3i\
\
## Unreleased\
\
* Updates rubocop to [NEW_RUBOCOP_VER](https://github.com/rubocop/rubocop/releases/tag/vNEW_RUBOCOP_VER)\
* Updates standard-performance to [NEW_PERF_VER](https://github.com/standardrb/standard-performance/releases/tag/vNEW_PERF_VER)' CHANGELOG.md
```
*(Adjust the `sed` line number or content if the gem list differs.)*

## Step 5: Create Branch and Commit

```bash
git checkout -b update-rubocop-NEW_RUBOCOP_VER
git add standard.gemspec Gemfile.lock CHANGELOG.md
git commit -m "Update rubocop to NEW_RUBOCOP_VER, standard-performance to NEW_PERF_VER"
```

## Step 6: Open Pull Request

Prepare the full PR description by prepending the header to `pr_body.md`:
```bash
echo -e "Updates RuboCop from OLD_VER to NEW_VER.\nUpdates standard-performance to NEW_PERF_VER.\n\n$(cat pr_body.md)\n\n---\n\nThe \`config/\` YAML files have not been updated for any of the above cops.\nTests are expected to fail until those configurations are added in a follow-up." > pr_full_body.md
```

Then create the PR:
```bash
gh pr create --title "Update rubocop to NEW_RUBOCOP_VER" --body-file pr_full_body.md
```
Delete temporary files: `rm pr_body.md pr_full_body.md`.
