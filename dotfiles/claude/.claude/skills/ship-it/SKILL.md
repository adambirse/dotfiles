---
name: ship-it
description: Run QA gates, commit with a conventional commit message, and push
disable-model-invocation: true
---

You are shipping code. Follow these steps in order, stopping immediately if any step fails.

## Step 1: Check for a project CLAUDE.md

Look for a CLAUDE.md (or claude.md) in the current project root. If it defines QA gates (build commands, linting, formatting, type checking, unit tests, etc.), note them. If no CLAUDE.md exists or it doesn't mention any QA commands, skip to Step 3.

## Step 2: Run QA gates

Run every QA gate identified in the project CLAUDE.md (e.g. build, lint, format check, type check, unit tests). Run them one at a time. If **any** gate fails, stop and report the failure to the user — do NOT commit or push.

## Step 3: Commit

1. Run `git status` and `git diff` (staged and unstaged) to understand all changes.
2. If nothing is staged, stage the relevant changed files by name (prefer specific files over `git add -A`).
3. If the changes span multiple unrelated concerns, suggest splitting them into separate commits before continuing.
4. Write a conventional commit message and create the commit.

```
<type>(<optional scope>): <subject>

<optional body>
```

- **Types**: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`
- **Subject**: imperative mood, lowercase, no period, max 72 characters
- **Body**: explain *why*, not what — one or two sentences, wrapped at 72 characters
- Do not amend previous commits. Do not skip pre-commit hooks (no `--no-verify`).

## Step 4: Push

Run `git push` to push the commit to the remote. If the push fails (e.g. behind remote), stop and report the issue to the user.

## Step 5: Confirm

Tell the user the commit has been pushed and show a short summary: the commit hash, message, and branch.
