---
name: rubocop-update
description: Bump RuboCop and standard-performance to their latest versions and generate a markdown summary with cop recommendations for Slack.
---

# RuboCop Update

This skill automates the RuboCop version bump and generates a markdown summary of new/changed cops, including placeholders for recommendations and rationale.

## Step 1: Check for Updates

Identify outdated gems and their versions:
```bash
bundle outdated rubocop standard-performance
```

## Step 2: Update Gemspec and Lockfile

Use `sed` to update `standard.gemspec` and then update the lockfile:
```bash
# Update standard.gemspec constraints
sed -i '/"rubocop"/s/OLD_VERSION/NEW_VERSION/' standard.gemspec
bundle update rubocop standard-performance
```

## Step 3: Generate Slack Summary

Generate the "New Cops" and "Changed Cops" tables for your Slack announcement:
```bash
curl -s https://raw.githubusercontent.com/rubocop/rubocop/main/CHANGELOG.md | \
  .claude/skills/rubocop-update/scripts/parse_changelog.rb --old OLD_RUBOCOP_VER --new NEW_RUBOCOP_VER > slack_summary.md
```

## Step 4: Evaluate New Rules

Edit `slack_summary.md`. For each cop in the "New cops" table, replace the `{RECOMMENDATION}` and `{RATIONALE}` placeholders with your recommendation and rationale based on the Standard Ruby ethos.

**Recommendation Format:**
- **Recommendation:** `Enable` or `Ignore`.
- **Rationale:** A concise paragraph explaining how the rule aligns with or deviates from the Standard ethos.

Finally, copy the contents of `slack_summary.md` to your team Slack channel.
