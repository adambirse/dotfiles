---
name: deliver
description: Deliver an approved plan from plans/active/ slice by slice, from test-first implementation through to verified in production
argument-hint: <plan-name>
disable-model-invocation: true
---

You are delivering an approved plan, one slice at a time. The plan file is your only record of progress: keep it up to date so that a fresh or compacted session can carry on from it alone.

## Step 1: Load and check the plan

Read `plans/active/<plan-name>.md` (`$ARGUMENTS` is the plan name). Stop and tell the user why, without changing anything, if:

- the plan doesn't exist
- its `Approved:` line has no date
- any row in its **Delivery** table is blank (an explicit "Not required" is fine)

The Delivery table is the only source of commands for test, lint, build, push, deploy, waiting, verification and rollback. Never run a delivery command it doesn't record. If you need one, ask the user, and once they confirm it, add it to the table.

## Step 2: Choose the review mode

If the plan's `Review mode:` line is already set, use it. Otherwise, before doing anything else, ask the user once and wait for their answer:

- **Review** (default): show them each slice's uncommitted diff before it's committed, and pause when each feature is complete.
- **Autonomous**: commit, push and deploy each slice without stopping, unless something is dangerous, fails, or is ambiguous.

Record their answer on the `Review mode:` line.

## Step 3: Deliver the next slice

Pick the first slice whose status isn't `done`. Then:

1. **Implement** it test-first, following the TDD rules in the global CLAUDE.md, until the slice's scenarios pass. Change only what the slice describes.
2. **Check** the full diff against the danger guard (below).
3. **Ship** it with the `ship-it` skill. Pass it:
   - the gates from the Delivery table,
   - the branch/PR flow,
   - in **Review** mode: that the user must review the diff before committing,
   - in **Autonomous** mode: that the user has approved autonomous delivery, so no review is needed.
4. **Deploy** with the recorded deploy command, unless deploy is "Not required". Check the command against the danger guard first.
5. **Wait** with the recorded wait command, run as a blocking shell command in the background. Never poll with repeated model turns.
6. **Verify in production** with the recorded verify method, and check the slice's scenarios hold there.
7. **Update the plan:** set the slice's status to `done` with its commit SHA and any notes the next session needs. Leave this edit uncommitted; it ships with the next slice's commit, or with the final archive commit.
8. **Record feedback:** append a feedback entry for `deliver` as described in `~/.claude/skills/retro/capture.md`. Do this also when the slice stops on failure, a danger-guard stop or a question.

If anything fails, follow **Failure handling** (below). Don't move to the next slice until this one is done.

## Failure handling

**Before the push** (implementation, gates, review or commit fails):

1. Leave the working tree as it is. Don't discard anything.
2. Investigate the root cause. Filter long output in the shell (`tail`, `grep`, `--log-failed`) rather than reading it whole.
3. If the cause is clear and inside the slice's scope, fix it and ship again (gates, then review in Review mode). Make at most **2** fix attempts.

**After the push** (deploy, wait or verify fails):

1. **Roll back** with the recorded rollback method, after checking it against the danger guard. If rollback is "Not required", skip to step 3.
2. **Confirm the rollback is live** with the recorded verify method. If it isn't, stop and ask the user immediately.
3. **Investigate** the root cause from the deploy and verify output, filtered in the shell.
4. If the cause is clear and inside the slice's scope, fix it as a new commit through the full pipeline (gates, review, push, deploy, verify). Make at most **2** fix attempts.

**In both cases:** if the cause is unclear, outside the slice's scope, needs a command that isn't in the Delivery table, or the attempts are used up, stop and ask the user. Tell them what failed, the root cause as far as you know it, and what you tried. Record each failure, rollback and attempt in the slice's notes in the plan.

## Danger guard

In **both** review modes, stop before committing or deploying and ask the user if a slice involves any of the following. Show them exactly what triggered the stop.

- **Destructive data changes:** dropping or rewriting data, schema changes that can't be reversed, bulk deletes.
- **Security-sensitive changes:** auth, permissions, IAM/RBAC, network rules, CORS, crypto.
- **Secrets:** a secret or credential-looking string in the diff or in logs.
- **Unplanned dependency changes:** dependencies added or upgraded beyond what the plan says.
- **Weakened safety nets:** tests, lint rules, CI steps or hooks removed, skipped or loosened.
- **Scope drift:** changes outside the files or areas the slice planned.
- **Unfamiliar commands:** any command not in the Delivery table, or anything targeting `prod`/`production` beyond the recorded deploy.
- **Risky rollbacks:** a rollback that can't be undone, or one that would rewrite history (force push).
- **Anything else that looks off** about the diff, its behaviour, or a dependency. When in doubt, ask. Asking costs the user a moment, while a bad deploy costs far more.

Record each stop and the user's decision in the slice's notes in the plan.

## Step 4: Feature boundary

When the slice you just finished was the last in its feature:

- **Review** mode: summarise what the feature shipped (slices, commits, anything verified only manually) and wait for the user's go-ahead before starting the next feature.
- **Autonomous** mode: give the same summary and carry on.

If the user corrects anything at the feature review, add it to the feedback log as a `deliver` entry.

Then go back to Step 3.

## Step 5: Archive

When every slice is `done`:

1. `git mv` the plan and its `.feature` files from `plans/active/` to `plans/completed/`.
2. In `plans/README.md`, move its row from **Active** to **Completed**, recording the commit it shipped in and any follow-ups.
3. Update any links to the plan's old path in other plans.
4. Ship these changes, together with the final status update, with `ship-it` (review rules as in Step 3).
