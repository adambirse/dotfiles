---
name: plan
description: Create an implementation plan in plans/active/ and pause for review before executing
argument-hint: <plan-name> <requirements, e.g. "refactor-db Move raw SQL queries into repository pattern">
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, WebSearch, WebFetch
disable-model-invocation: true
---

You are creating an implementation plan. Follow these steps in order. **Do NOT write any production code until the user explicitly approves the plan.**

The user's input (`$ARGUMENTS`) contains a short plan name followed by optional requirements context. Parse it as follows:
- The **first word** (hyphen-separated, no spaces) is the plan name used for the filename — e.g. `refactor-db`, `feature-auth`, `fix-login-bug`
- Everything **after the first word** is additional context describing what the user wants — use this as the primary input for understanding requirements

If the user provides only a plan name with no extra context, ask clarifying questions about what they want before proceeding.

## Step 1: Gather context

Understand the task at hand. Use a combination of:
- Reading the user's requirements from their input (everything after the plan name in `$ARGUMENTS`)
- Exploring the codebase (file structure, existing patterns, relevant code)
- Reading the project CLAUDE.md for conventions and architecture guidance
- Reading `plans/README.md` (if it exists) to see active and completed plans that may overlap
- Discovering how the repo is delivered: CI config (e.g. `.github/workflows/`), build files (`Makefile`, `package.json` scripts, etc.), deploy docs and scripts, and the README. Find the commands for test, lint/type-check, build, deploy, waiting for deploy, verifying in production, and rollback, plus the branch/PR flow.
- Asking clarifying questions if the requirements are ambiguous

Never assume repo practice. Every delivery command you couldn't find in the repo is a question for the user, and the plan can't be approved while any are unanswered. If the user says a step doesn't apply (e.g. no rollback), record that explicitly.

## Step 2: Define requirements

Before writing the plan, use the **requirements** skill to capture the requirements as BDD scenarios in Gherkin format. Work through them with the user in this conversation to produce `Given-When-Then` scenarios that define the expected behaviour.

Group the scenarios into **features**, each a capability described from the user's point of view ("As a … I can …"). They go into the plan document (Step 3) as the acceptance criteria, and each slice names the scenarios it delivers.

## Step 3: Write the plan

Extract the plan name (first word of `$ARGUMENTS`) and create a markdown file at `plans/active/<plan-name>.md` in the project root (create `plans/active/` and `plans/completed/` if they don't exist). If the scenarios are also written as a separate `.feature` file, save it next to the plan in `plans/active/`.

If `plans/README.md` exists, add a row for the new plan to its **Active** table (plan link and a one-line summary). If it doesn't exist, create it with this skeleton:

```markdown
# Plans

| Location | Contains |
|---|---|
| `active/` | Plans not yet started or in progress |
| `completed/` | Plans whose work has shipped, kept for reference with their `.feature` files |

## Active

| Plan | Summary |
|---|---|

## Completed

| Plan | Shipped in | Notes |
|---|---|---|
```

The plan should follow this structure:

```markdown
# Plan: <title>

Approved: _(not yet)_
Review mode: _(set by /deliver)_

## Context
Brief description of the problem or feature and why it's needed.

## Goals
- What this plan aims to achieve (bulleted list)

## Non-goals
- What is explicitly out of scope

## Approach
Key design decisions and their rationale, which patterns apply, and how this fits the existing codebase.

## Features

Each feature is a capability described from the user's point of view. Its scenarios are the acceptance criteria. Features are split into thin slices, delivered in order.

### Feature 1: <As a … I can …>

\`\`\`gherkin
Feature: <feature name>
  <description>

  Scenario: <happy path>
    Given ...
    When ...
    Then ...

  Scenario: <edge case or error>
    Given ...
    When ...
    Then ...
\`\`\`

| Slice | Delivers | Scenarios | Changes | Tests | Status |
|---|---|---|---|---|---|
| 1.1 | <the thinnest end-to-end path> | <scenario names> | <files or components> | unit / integration / manual | pending |
| 1.2 | ... | ... | ... | ... | pending |

(Repeat for each feature, ordered by value and risk)

## Delivery

How this repo is tested, shipped and checked. `/deliver` uses only these commands.

| Step | Command | Source |
|---|---|---|
| Test | ... | file:line, or "confirmed by user" |
| Lint / type-check | ... | |
| Build | ... | |
| Branch / PR flow | ... | |
| Deploy | ... | |
| Wait for deploy | ... | |
| Verify in production | ... | |
| Rollback | ... or "Not required" | |

## Risks and Open Questions
- Any uncertainties, trade-offs, or decisions that need input
```

Every Delivery row needs a command or an explicit "Not required" with its source. Never leave a row blank or fill one in with a guess.

Adapt the structure to the task. Skip sections that aren't relevant, or add ones that are, except Features and Delivery, which every plan needs. The goal is clarity, not ceremony.

### Slicing

Work hard to make slices thin. Each one delivers a small increment of value that can be deployed and reviewed on its own.

- **Vertical, not horizontal.** A slice cuts through every layer it needs and produces something observable. "Add the DB table" alone is not a slice.
- **Walking skeleton first.** A feature's first slice is the thinnest end-to-end path, even if it's hard-coded or only covers the happy path.
- **Split until small (SPIDR).** Split by Spike, Paths (happy path first, then edge cases), Interfaces, Data (one data type first), or Rules (simplest rule first). Split again if a slice needs more than ~3 scenarios, touches several unrelated areas, or can't be reviewed in a few minutes.
- **Independently deployable.** Production keeps working after every slice. Use feature flags or dark launches only if the repo already uses them; otherwise ask.
- **Ordered by value and risk.** Ship what delivers the most value, or removes the biggest unknown, first.

## Step 4: Review the slicing, then approve

After writing the plan file, show the user:
1. The path to the plan file
2. A brief summary of the approach (2-3 sentences)
3. The features and slices as a short numbered list (slice number, what it delivers). Invite them to split, merge or reorder before approving.
4. Any Delivery rows or open questions still waiting on them

**STOP HERE.** Do not write any code. If the user asks for changes, update the plan file and pause again.

When the user explicitly approves, set the plan's `Approved:` line to today's date. `/deliver` refuses any plan without it. Never set it yourself without that approval.

## Step 5: Record feedback

Once the plan is approved, or the user abandons it, append a feedback entry for `plan` as described in `~/.claude/skills/retro/capture.md`.
