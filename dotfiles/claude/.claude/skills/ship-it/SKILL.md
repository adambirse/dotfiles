---
name: ship-it
description: Run QA gates, commit with a conventional commit message, and push. Called by /deliver for each slice, or invoked directly for one-off changes.
---

You are shipping code. Follow these steps in order, stopping immediately if any step fails.

## Step 1: Find the QA gates

Take the gates (build, lint, format check, type check, tests) from the first source that defines them:

1. The caller. `/deliver` passes the commands from the plan's Delivery section.
2. The project CLAUDE.md (or claude.md).

If neither defines them, ask the user which gates to run, or whether there are none. Never skip gates on your own, and never guess commands.

## Step 2: Run QA gates

Run every gate one at a time. If **any** gate fails, stop and report the failure to the user. Do NOT commit or push.

## Step 3: Review

Unless the caller says the user has already approved this diff, show the user `git status` and the diff, and wait for their approval. Don't commit until they approve.

## Step 4: Commit

1. If nothing is staged, stage the relevant changed files by name (prefer specific files over `git add -A`).
2. If the changes span multiple unrelated concerns, suggest splitting them into separate commits before continuing.
3. Write a conventional commit message and create the commit.

```
<type>(<optional scope>): <subject>

<optional body>
```

- **Types**: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`
- **Subject**: imperative mood, lowercase, no period, max 72 characters
- **Body**: explain *why*, not what — one or two sentences, wrapped at 72 characters
- Do not amend previous commits. Do not skip pre-commit hooks (no `--no-verify`).

## Step 5: Push

Push to the branch and remote given by the caller (the plan's branch/PR flow). Otherwise use the current branch's upstream. If the push fails (e.g. behind remote), or the flow needs a PR you weren't told how to open, stop and report the issue to the user.

## Step 6: Confirm

Tell the user (or the caller) what was pushed: the commit hash, message, and branch.
