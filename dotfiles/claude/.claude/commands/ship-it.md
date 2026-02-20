---
description: Run QA gates, commit with a conventional commit message, and push
---

You are shipping code. Follow these steps in order, stopping immediately if any step fails.

## Step 1: Check for a project CLAUDE.md

Look for a CLAUDE.md (or claude.md) in the current project root. If it defines QA gates (build commands, linting, formatting, type checking, unit tests, etc.), note them. If no CLAUDE.md exists or it doesn't mention any QA commands, skip to Step 2.

## Step 2: Run QA gates

Run every QA gate identified in the project CLAUDE.md (e.g. build, lint, format check, type check, unit tests). Run them one at a time. If **any** gate fails, stop and report the failure to the user — do NOT commit or push.

## Step 3: Commit

Delegate to the **commit-message** agent to analyse changes and create a conventional commit. Do not amend previous commits. Do not skip pre-commit hooks.

## Step 4: Push

Run `git push` to push the commit to the remote. If the push fails (e.g. behind remote), stop and report the issue to the user.

## Step 5: Confirm

Tell the user the commit has been pushed and show a short summary: the commit hash, message, and branch.
