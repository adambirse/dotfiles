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
- Asking clarifying questions if the requirements are ambiguous

## Step 2: Define requirements

Before writing the plan, use the **requirements** skill to capture the requirements as BDD scenarios in Gherkin format. Work through them with the user in this conversation to produce `Given-When-Then` scenarios that define the expected behaviour.

These scenarios will be included directly in the plan document (Step 3) and serve as the acceptance criteria for the implementation.

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

## Context
Brief description of the problem or feature and why it's needed.

## Goals
- What this plan aims to achieve (bulleted list)

## Non-goals
- What is explicitly out of scope

## Requirements

BDD scenarios that define the expected behaviour of this feature. These serve as the acceptance criteria and will drive testing.

### Feature: <feature name>

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

(Include all agreed scenarios)

## Approach
Detailed description of the implementation approach. Include:
- Key design decisions and their rationale
- Which patterns or architectures apply
- How this fits with the existing codebase

## Changes

### <file or component>
- What changes and why

### <file or component>
- What changes and why

(Repeat for each file or component that will be touched)

## Testing Strategy
How the changes will be verified. Tests should map directly to the BDD scenarios in the Requirements section above:
- Which scenarios will be covered by unit tests
- Which scenarios need integration tests
- Any scenarios that require manual verification

## Risks and Open Questions
- Any uncertainties, trade-offs, or decisions that need input
```

Adapt the structure to the task — skip sections that aren't relevant, add sections if needed. The goal is clarity, not ceremony.

## Step 4: Pause for review

After writing the plan file, tell the user:
1. The path to the plan file
2. A brief summary of the approach (2-3 sentences)
3. Ask them to review the plan and confirm before you proceed with implementation

**STOP HERE.** Do not write any code until the user gives explicit approval. If the user requests changes to the plan, update the plan file and pause again for review.

## Step 5: When the plan is complete

This happens later, once implementation is finished, not when the plan is written.

When every item in the plan meets the completion gate in the global CLAUDE.md (scenarios verified, tests green, type-check and lint clean, no TODOs or placeholders):
1. `git mv` the plan and its `.feature` files from `plans/active/` to `plans/completed/`.
2. In `plans/README.md`, move its row from **Active** to **Completed**, recording the commit it shipped in and any follow-ups.
3. Update any links to the plan's old path in other plans.
