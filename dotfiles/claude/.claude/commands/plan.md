---
description: Create an implementation plan in a markdown file and pause for review before executing
allowed-tools: Read, Grep, Glob, Bash, Write, Edit, WebSearch, WebFetch
user-input: plan name and requirements (e.g. "refactor-db Move raw SQL queries into repository pattern")
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
- Asking clarifying questions if the requirements are ambiguous

## Step 2: Define requirements

Before writing the plan, delegate to the **requirements** agent to capture the requirements as BDD scenarios in Gherkin format. The requirements agent will work with you to produce `Given-When-Then` scenarios that define the expected behaviour.

These scenarios will be included directly in the plan document (Step 3) and serve as the acceptance criteria for the implementation.

## Step 3: Write the plan

Extract the plan name (first word of `$ARGUMENTS`) and create a markdown file at `plans/<plan-name>.md` in the project root (create the `plans/` directory if it doesn't exist).

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

(Include all scenarios produced by the requirements agent)

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

## Step 3: Pause for review

After writing the plan file, tell the user:
1. The path to the plan file
2. A brief summary of the approach (2-3 sentences)
3. Ask them to review the plan and confirm before you proceed with implementation

**STOP HERE.** Do not write any code until the user gives explicit approval. If the user requests changes to the plan, update the plan file and pause again for review.
