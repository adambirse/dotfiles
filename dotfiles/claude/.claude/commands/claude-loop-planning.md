---
description: Generate a plans directory for use with claude-loop. Creates context, requirements, and ordered task files.
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, WebSearch, WebFetch, Agent
user-input: plan name and description (e.g. "auth-refactor Extract auth logic into a shared middleware")
---

You are generating a plans directory for use with `claude-loop`, which runs Claude Code headlessly against each task file in sequence.

The user's input (`$ARGUMENTS`) contains a short plan name followed by a description. Parse it as follows:
- The **first word** (hyphen-separated, no spaces) is the plan name, used as the directory name — e.g. `auth-refactor`, `add-search`, `fix-caching`
- Everything **after the first word** is the description of what the user wants

If the user provides only a plan name with no description, ask clarifying questions before proceeding.

## Step 1: Gather context

Understand the work. Use a combination of:
- The user's description (everything after the plan name in `$ARGUMENTS`)
- Exploring the codebase (file structure, existing patterns, relevant code)
- Reading the project CLAUDE.md for conventions and architecture guidance
- Asking clarifying questions if the requirements are ambiguous

## Step 2: Define requirements

Delegate to the **requirements** agent to capture the requirements as BDD scenarios in Gherkin format. These scenarios will be included in `requirements.md` and serve as the acceptance criteria for all tasks.

## Step 3: Create the plans directory

Extract the plan name (first word of `$ARGUMENTS`) and create the following structure at `plans/<plan-name>/` in the project root (create directories as needed):

### `context.md`

Project context that applies to every task. Include:
- Brief description of the project and its tech stack
- Relevant architecture and conventions (from CLAUDE.md and codebase exploration)
- Key file paths and patterns the tasks will need to work with
- Any constraints or non-goals

Keep this focused — only include context that tasks will actually need.

### `requirements.md`

The BDD scenarios from Step 2. This file is sent as part of every task prompt, so tasks can reference the acceptance criteria.

### `plan-NN-<name>.md` (task files)

Break the work into discrete, ordered tasks. Each task file should:
- Have a clear, single objective
- Include enough detail that Claude can complete it without clarification — file paths, function names, expected behaviour
- Reference specific requirements/scenarios from `requirements.md` where relevant
- Be completable independently (though it can build on the output of earlier tasks)

Use this format for each task file:

```markdown
# Task: <clear description of what to do>

## Objective
What this task achieves in 1-2 sentences.

## Details
- Specific files to create or modify
- What the implementation should look like
- Any patterns to follow from the existing codebase

## Acceptance Criteria
- Which scenarios from requirements.md this task addresses
- Any additional criteria specific to this task

## Notes
- Dependencies on earlier tasks (if any)
- Edge cases to handle
```

Adapt the format to the task — skip sections that aren't relevant. The goal is giving Claude enough context to work autonomously.

### Naming convention

Number task files with zero-padded prefixes to control execution order:
- `plan-01-setup.md`
- `plan-02-models.md`
- `plan-03-api.md`
- `plan-04-tests.md`

### Task decomposition guidance

- Aim for 3-8 tasks. Fewer than 3 suggests the work isn't complex enough to need a loop. More than 8 suggests tasks should be consolidated.
- Put foundational work first (scaffolding, models, interfaces) and dependent work later (integration, tests, documentation).
- Each task should produce a working (if incomplete) codebase — avoid tasks that leave things in a broken state.
- Include a testing task near the end that validates the requirements.

## Step 4: Pause for review

After creating the plans directory, tell the user:
1. The path to the plans directory
2. A summary of the tasks and their order
3. How to run it: `claude-loop plans/<plan-name>`
4. Ask them to review and confirm the plan before running

**STOP HERE.** Do not run `claude-loop` or implement anything. If the user requests changes, update the relevant files and pause again for review.
