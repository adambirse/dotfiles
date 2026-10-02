# Plan: plan → deliver → retro delivery mechanism

Approved: 2026-10-02
Review mode: pause per feature

## Context

You want work to go from idea to production in small, user-centric increments with as much automation as is safe:
- Claude plans the work as **features**, each made of thin **slices**.
- Claude delivers it slice by slice and pauses for your review when a feature is complete.
- You can choose to let it run fully autonomously.
- Claude asks rather than guesses about the repo, and asks rather than deploys anything dangerous or suspicious.
- Credits are spent only where reasoning is needed.
- A feedback log helps the skills improve over time.

Today the pieces don't fit together:

| Finding | Where | Why it matters |
|---|---|---|
| CLAUDE.md is written for `claude-loop` and `plan-NN-*.md` files, but `plan` writes `plans/active/<name>.md` | `CLAUDE.md` "Plan and loop completion gates" | Two contradictory sets of instructions load every session |
| "Exit non-zero" under `claude-loop` can't be done: `claude -p` exits 0 whatever the model decides | `claude-loop` `run_task` | A failed gate is still marked `complete` |
| `claude-loop` defaults to `--dangerously-skip-permissions` | `claude-loop` | Your `deny` list is ignored when it runs |
| `ship-it` skips QA gates when CLAUDE.md doesn't list them | `ship-it` Step 1 | Silently assumes "no gates" |
| `ship-it` has `disable-model-invocation: true` | `ship-it` frontmatter | `deliver` can't call it |
| `plan` Step 5 (archiving a completed plan) runs during delivery | `plan` SKILL.md | It belongs in `deliver` |
| `plan` splits work by file ("Changes"), not by user value | `plan` template | Gives nothing to slice, pause on, or review |
| `Bash(git:*)` is allowed, and that includes `git push --force` | `settings.json` | A rollback could rewrite published history without asking |

## Decisions (agreed)

- **Structure.** A plan contains **features**. A feature is a user-centric capability ("As a … I can …") with its own BDD scenarios. Each feature is made of one or more thin **slices**. A slice is a vertical, deployable increment that leaves production working.
- **Delivery and review.** `deliver` delivers slice by slice. By default it **pauses for your review when a feature is complete**.
  - When it starts, it asks once whether to keep the pauses or run **fully autonomously** for this plan, and records the choice in the plan.
  - The danger guard (below) applies in both modes.
- **Danger guard.** If a slice's diff or deploy is dangerous or suspicious, `deliver` stops and asks, even in autonomous mode. When in doubt, it asks.
- **One-time approval.** Approving the plan is the only step that always waits for you. The feature pauses and push reviews are the default, and you can turn them off.
- **Review before every commit** (added as feature 2.5). Once a slice passes its gates, you review its uncommitted diff. After you approve, it's committed and pushed. Fully autonomous mode skips that review. Separately, Claude Code asks before every `git push` in every session, whatever mode `deliver` is in.
- **Repo practice** (test, lint, build, deploy, wait, verify, rollback, branch/PR flow) is discovered while planning, confirmed with you, and recorded in the plan's **Delivery** section. `deliver` uses only what's recorded there.
- **On failure:** roll back, investigate, and try up to **2** fixes if the cause is clear and in scope. Otherwise ask.
- **`ship-it`** stays for one-off commits, and `deliver` calls it. **`claude-loop`** is retired: its references are removed from CLAUDE.md and the script is left alone.
- **The retro log** lives in `~/.claude/skill-feedback/`, never committed, because the dotfiles repo is public.

## Goals
- Plans made of user-centric features, sliced as thin as possible.
- Slice-by-slice delivery to production with verification and rollback, pausing at feature boundaries unless you choose otherwise.
- Asking rather than deploying anything dangerous or suspicious.
- Cheap work goes to cheap paths, without losing quality.
- A feedback log that turns real runs into proposed skill edits.

## Non-goals
- Running headless or unattended (`claude-loop`).
- Default commands for any language or platform.
- `retro` editing skills on its own.

## Slicing guidance (goes into `plan`)

- **Vertical, not horizontal.** Every slice cuts through every layer it needs and produces something observable. "Add the DB table" alone is not a slice.
- **Walking skeleton first.** A feature's first slice is the thinnest end-to-end path, even if it's hard-coded or only covers the happy path.
- **Split until small.** Use the SPIDR techniques: Spike, Paths (happy path first, then edge cases), Interfaces, Data (one data type first), Rules (simplest rule first). Split again if a slice:
  - needs more than ~3 scenarios,
  - touches several unrelated areas,
  - or can't be reviewed in a few minutes.
- **Each slice is independently deployable.** Production keeps working after every slice. Use feature flags or dark launches only if the repo already uses them; otherwise ask.
- **Order by value and risk.** Ship the slice that delivers the most value or removes the biggest unknown first.
- **Review the slicing with you.** Before the plan is approved, present the feature and slice list on its own and invite you to merge, split or reorder.

## Danger guard (goes into `deliver`)

`deliver` stops and asks, whatever the autonomy mode, when a slice involves any of the following:
- **Destructive data changes:** dropping or rewriting data, schema changes that can't be reversed, bulk deletes.
- **Security-sensitive changes:** auth, permissions, IAM/RBAC, network rules, CORS, crypto.
- **Secrets:** a secret or credential-looking string appears in the diff or logs.
- **Unplanned dependency changes:** dependencies added or upgraded beyond what the plan said.
- **Weakened safety nets:** tests, lint rules, CI steps or hooks removed or weakened.
- **Scope drift:** changes outside the files or areas the slice planned.
- **Unfamiliar commands:** any command not in the Delivery table, or anything targeting `prod`/`production` beyond the recorded deploy.
- **A rollback that can't be undone,** or a rollback that would rewrite history (force push).
- **Anything else** about the diff, its behaviour, or a dependency that looks off.

## Cost routing

| Work | Runs on | Why |
|---|---|---|
| Waiting for CI, deploys and PR checks | Blocking shell commands run in the background (`gh run watch --exit-status`, `gh pr checks --watch`, or the repo's own command) | No tokens while waiting; the session wakes once |
| Running gates and reading large output (`gh run view --log-failed`, deploy logs) | Main model, with output filtered in the shell (`tail`, `grep`, `--log-failed`) | The Haiku `test-runner` was removed in slice 1.2 because it wouldn't reliably avoid choosing its own commands; to be revisited later |
| Diagnosis, rollback decisions, the danger guard, code, slicing | Main model | Quality-critical |
| Retro capture | Inline final step, written from a fixed template | Main model already has the context |
| Retro analysis | Main model, when you ask | Rare and worth the reasoning |

**Rough cost per slice:**
- **Waiting for CI:** polling with a model costs about 5–20k tokens per poll, while a background watch costs one wake-up of about 2–5k tokens.
- **Reading a CI log:** the main model reading it all costs about 30–80k tokens. Filtering it first in the shell (`--log-failed`, `tail`, `grep`) brings that down to about 2–10k.

There's no separate `ci-watcher` agent.

## Features

### Feature 1: I get one consistent set of delivery instructions

```gherkin
Feature: Consistent instructions
  Scenario: No stale loop instructions
    Given my global CLAUDE.md
    When any session loads it
    Then it describes delivery through /deliver and plans/active/
    And it does not mention claude-loop or plan-NN files

  Scenario: No subagent chooses verification commands
    Given the agents in ~/.claude/agents
    When I list them
    Then test-runner is not among them
    And CLAUDE.md routes tests and builds to the main session

  Scenario: Force pushes need my approval
    When Claude runs git push --force
    Then I am asked first
```

| Slice | Change |
|---|---|
| 1.1 | **`CLAUDE.md`:** replace "Plan and loop completion gates" with a short delivery section (the completion gate, the hard stop, and "the Delivery section overrides guesses"). Remove the `claude-loop`, `plan-NN` and exit-code wording. |
| 1.2 | **Remove `agents/test-runner.md`.** Route tests, builds and log reading to the main session in CLAUDE.md, and add a rule to filter long logs in the shell. (Three attempts to stop Haiku choosing its own commands failed; you'll revisit this later.) |
| 1.3 | **`settings.json`:** add `git push --force`, `-f` and `--force-with-lease` to `ask`. |

### Feature 2: I can plan work as user-centric features made of thin slices

```gherkin
Feature: Planning
  Scenario: Repo practice is discovered, not assumed
    Given a repo whose CLAUDE.md names no deploy command
    When I run /plan
    Then I am asked how the repo deploys, verifies and rolls back
    And the Delivery section records my answers with their source

  Scenario: Work is organised as features of thin slices
    Given agreed requirements
    When the plan is written
    Then each feature is phrased from the user's point of view with its own scenarios
    And each slice is vertical, independently deployable, and maps to specific scenarios

  Scenario: Slicing is reviewed before approval
    Given a drafted plan
    When the features and slices are presented
    Then I am invited to split, merge or reorder them before approving

  Scenario: Approval is recorded
    When I approve the plan
    Then its Approved line is filled in with the date
```

| Slice | Change |
|---|---|
| 2.1 | **Delivery section.** Step 1 reads CI config, build files and deploy docs, and lists unknowns as questions. The template gets a Delivery table (gate, command, source). |
| 2.2 | **Features and slices.** Replace "Changes" with Features → Slices in the template. Each slice has a status. Add the slicing guidance above. |
| 2.3 | **Slicing review and approval.** Step 4 shows the slice list for review and records `Approved:`. Move Step 5 (archiving) out to `deliver`. |

### Feature 2.5: I review every change before it's committed and pushed

```gherkin
Feature: Review before commit and push
  Scenario: Changes are reviewed before they are committed
    Given a slice has passed its gates
    When it is ready to commit
    Then I am shown the uncommitted diff
    And nothing is committed until I approve

  Scenario: Claude Code asks before any push
    When Claude runs git push in any session
    Then I am asked to approve it first

  Scenario: Force pushes still ask
    When Claude runs git push --force
    Then I am asked to approve it first
```

| Slice | Change | Status |
|---|---|---|
| 2.5.1 | **`settings.json`:** add `Bash(git push:*)` to `ask`. Starting with this slice, delivery in this repo is: show you the uncommitted diff, and commit and push only once you approve. | done |

The `deliver` side (pausing before each slice's commit unless autonomous) is part of slice 3.2.

**Interaction to know about:** a settings `ask` rule can't be skipped by a skill. So even in `deliver`'s autonomous mode, Claude Code shows a permission prompt for each push, unless you approve pushes for the session from that prompt. That prompt is the only thing you have to do; there's no separate review pause.

### Feature 3: I can deliver an approved plan safely, slice by slice

```gherkin
Feature: Delivery
  Scenario: Unapproved plans are refused
    Given a plan with no Approved date
    When I run /deliver <plan>
    Then nothing is changed and I am told why

  Scenario: I choose the review mode up front
    Given an approved plan
    When /deliver starts
    Then I am asked whether to pause at each completed feature or run fully autonomously
    And my choice is recorded in the plan

  Scenario: A slice ships and is verified
    Given the next pending slice
    When deliver runs it
    Then it is built test-first, passes the plan's gates, and is committed, deployed and verified with the plan's commands
    And the slice is marked done with its commit SHA

  Scenario: Review before each commit
    Given review mode is not autonomous
    When a slice has passed its gates
    Then deliver shows me the uncommitted diff and waits for my approval
    And it commits and pushes only after I approve

  Scenario: Pause when a feature is complete
    Given review mode is "pause per feature"
    When the last slice of a feature is verified in production
    Then deliver summarises what shipped and waits for my go-ahead

  Scenario: Dangerous changes are never deployed unasked
    Given autonomous mode
    When a slice's diff adds a database column drop
    Then deliver stops before committing and asks me

  Scenario: Verification fails after deploy
    Given a slice deployed to production
    When post-deploy verification fails
    Then deliver rolls back with the recorded method, confirms the rollback is live, and investigates
    And it makes at most 2 fix attempts before asking me

  Scenario: Resuming
    Given slices 1.1 and 1.2 are done
    When I run /deliver <plan> in a new session
    Then it starts at slice 1.3 with the recorded review mode
```

| Slice | Change |
|---|---|
| 3.1 | **`ship-it`.** Remove `disable-model-invocation`. Gates come from the caller first, then CLAUDE.md, otherwise it asks. Push to the target and branch flow it's given. |
| 3.2 | **`deliver` happy path.** Approval check → ask for the review mode → pick the next pending slice → TDD → gates run on the main model → show the uncommitted diff and wait for approval (unless autonomous) → commit and push through `ship-it` → deploy → background wait → verify → update the plan (status, SHA, notes) → pause at the end of each feature (unless autonomous) → archive when all are done. |
| 3.3 | **Danger guard.** Check the diff and planned commands before committing and before deploying. Ask on any trigger. |
| 3.4 | **Failure path.** Before push: keep the working tree and make up to 2 fix attempts. After push: roll back with the recorded method, confirm, diagnose (logs filtered in the shell), make up to 2 fix attempts through the full pipeline, then ask. |

`deliver` isn't safe to use against other repos until 3.3 and 3.4 have shipped. Feature 3's review pause covers that.

### Feature 4: I get feedback that helps me improve my skills

```gherkin
Feature: Retro
  Scenario: Every run leaves a record
    When plan, a deliver slice or ship-it finishes
    Then one entry is appended to ~/.claude/skill-feedback/<skill>.md with facts only

  Scenario: Analysis proposes edits, never applies them
    Given a log with several entries
    When I run /retro <skill>
    Then I get recurring problems with evidence counts and proposed diffs
    And no file is changed without my approval
```

| Slice | Change |
|---|---|
| 4.1 | **Capture step.** Add a final step to `plan`, `deliver` (per slice and per feature review) and `ship-it`. It appends about 10 lines: date, repo and slice; my corrections (quoted); questions asked; assumptions proven wrong; failed gates; retries and rollbacks; danger-guard stops; skipped steps; a rough token count. No self-scoring. |
| 4.2 | **`skills/retro/SKILL.md`** (user-invoked): group recurring problems with counts, propose diffs, and mark the entries reviewed. It never applies anything itself. |

**Why a skill step and not a hook:** Claude Code has no "skill finished" hook. `Stop` fires on every turn, and `SubagentStop` doesn't cover skills.

**Overlap with memory:** memory stores your guidance for future sessions, while retro stores evidence of how skills performed. They don't overlap.

## Delivery (this repo)

| Gate | Command | Source |
|---|---|---|
| Test / lint / build | None exist; review the diff, and load the changed skill in a fresh session to confirm its frontmatter parses | Repo has no test tooling |
| Branch / PR flow | Show the uncommitted diff for review; after approval, commit to main and push | Confirmed by user (feature 2.5) |
| Deploy | `git push` (origin/main), then `./install.sh claude` to stow new skill dirs | `install.sh`, CLAUDE.md |
| Verify | `ls -l ~/.claude/skills/<name>` resolves into dotfiles; the skill is listed in a fresh session | Stow layout |
| Rollback | Not required | Confirmed by user |
| Review mode | Pause per feature | Default |

## Risks and open questions
- **Long plans fill the context window.** The plan file is the record of progress. `deliver` updates it as each slice finishes (status, SHA, notes, review mode, and any Delivery rows you confirmed mid-run), so a compacted or fresh session picks up from the plan alone. This rule goes into slice 3.2.
- **The danger guard is the model's judgement**, backed by the explicit triggers above. It isn't a guarantee, so autonomous mode is best used on repos with a reliable rollback.
- **When a repo needs no rollback** (like this one), the Delivery row says so explicitly. If verification fails, `deliver` skips the rollback step and goes straight to diagnosis and the fix attempts. A blank rollback row still stops it from starting.

## Progress

| Slice | Status | Commit | Notes |
|---|---|---|---|
| 1.1 | done | 6e135e2 | |
| 1.2 | done | 30c234d | test-runner removed instead of fixed: 3 attempts failed (it explored and chose its own commands, or refused real ones). You'll revisit it later. |
| 1.3 | done | 0d230a3 | Edited out of order while 1.2 was being verified. Checked headless: `git push --force --dry-run` stopped for approval; plain `git push --dry-run` allowed. Ceiling: rules match on the command prefix, so `git push origin main --force` (flag last) is not caught |
| 2.1 | done | b287886 | Checked headless on a scratch repo with no CI: /plan asked about lint, build, branch flow, deploy, verify and rollback, then recorded every answer with its source |
| 2.2 | done | b78210e | Checked headless on a scratch todo CLI: 3 user-centric features in 7 slices, each starting with a walking skeleton, at most 3 scenarios per slice, each mapped to scenarios |
| 2.3 | done | 8400d76 | Checked headless: the slice list was shown with an invitation to split, merge or reorder; `Approved:` stayed unset until "approved", then got the date; no code was written |

| 2.5.1 | done | 872ad7f | Checked headless: `git push --dry-run`, which ran without a prompt in the 1.3 check, is now stopped for approval, and so is `git push --force --dry-run`. From here on, changes in this repo are shown for review before they're committed. The first version committed before review; it was undone (not yet pushed) when you moved the review point to before the commit. |
| 3.1 | done | 88a4a41 | Checked headless on a scratch repo with no CLAUDE.md: the model invoked ship-it itself, asked which gates to run instead of skipping them, flagged that there was no remote, and committed nothing. ship-it also gained a review step (Step 3) so a direct /ship-it still shows the diff before committing. |
| 3.2 | done | 4de62f1 | Checked headless on scratch repos (local bare remote). Unapproved plan: refused, nothing changed. Review mode: asked before anything else (first version asked only after implementing; fixed) and recorded. Slice: test-first, diff shown, committed and pushed only after approval, marked done with its SHA. Feature summary shown, then paused. Archive: moved to `completed/` and the README updated, through review. Resume: a fresh session skipped the slice marked done, and also caught that its SHA and files were missing. Not exercised: deploy, wait and verify commands (all scratch plans say "Not required"). The archive steps from 2.3 are now in `deliver` Step 5. |
| 3.3 | done | (this commit) | Checked headless: an autonomous run of a slice that needed `ALTER TABLE users DROP COLUMN nickname` stopped before committing. It showed the trigger, noted that the plan's rollback is "Not required" so the data couldn't be recovered, offered options, and recorded the stop in the plan. Nothing was committed or pushed. Not checked against a run without the guard, so this doesn't show how much of the caution came from the guard itself. |
