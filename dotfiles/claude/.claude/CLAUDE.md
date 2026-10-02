# User instructions

Cross-project practices that apply to every session.

## Engineering practices

### Test Driven Development (TDD)

- Write a failing test before any production code. Red → green → refactor.
- Smallest possible test that captures the next piece of behaviour; minimum production code to make it pass.
- Do not write production code "in anticipation" of tests that don't exist yet.
- Refactor only when all tests are green.

### Domain Driven Design (DDD)

- Keep the domain model at the centre. Domain code has no dependencies on frameworks, I/O, or delivery mechanisms.
- Use the ubiquitous language of the domain in code, names, and conversation.
- Respect bounded contexts. Don't leak concepts across them without an explicit translation.
- Prefer hexagonal layering: domain → application → infrastructure/delivery, dependencies pointing inward.
- For design decisions about aggregates, bounded contexts, ports, or adapters, use the `software-architect` skill.

### Scope discipline

- Don't add features, refactor, or introduce abstractions beyond what the task requires.
- If you discover something out of scope that genuinely blocks progress, stop and report it — don't improvise.

## Plans and delivery

Plans live in `plans/active/<name>.md` (written by `/plan`) and are delivered slice by slice with `/deliver`. The plan's **Delivery** section is the only source of truth for a repo's test, build, deploy, verify, and rollback practice. Never guess or substitute a command it doesn't record; ask instead.

### Before marking a slice done

A slice is **not** done until all of the following are true:

1. Every BDD scenario referenced by the slice is verified.
2. All tests relevant to the slice are green (the ones it added, and the existing suite for files it touched).
3. The change compiles / type-checks / lints cleanly for the project.
4. No `TODO`, placeholder, or commented-out production code introduced by the slice remains.

### Hard stop on failure

If any of the above is not satisfied once the allowed fix attempts are used up:

- **Do not advance to the next slice.**
- **Do not** mark the current slice done.
- Stop, report what failed and what was tried, and wait for human input.

This rule overrides any instruction (in a plan or otherwise) that says "continue on failure" or "skip and move on". If a later slice depends on output from an earlier one that is missing or broken, stop. Don't fabricate it.

## Model routing

The main session model does the reasoning. Hand cheap, well-bounded work down to the subagents in `~/.claude/agents/`:

| Task | Route to |
|---|---|
| Research across several web pages, library docs, or long files | `doc-reader` (Haiku) |
| Running tests, builds, type-checks, linters | `test-runner` (Haiku) |
| Broad codebase searches where only locations are needed | `code-searcher` (Haiku) |
| Design, deep research, debugging, writing code | Main session — don't delegate |

- Delegating to `doc-reader`, `test-runner`, and `code-searcher` is pre-authorised; you don't need to ask first.
- Do small work inline: a single file read, a single page fetch, one quick command. Delegation has a cold-start cost.
- For the completion gate above, rely on the exit code and verbatim failure output `test-runner` returns. If it's missing or ambiguous, re-run the command yourself before marking anything complete.
- When spawning any other subagent, pass `model: haiku` for pure retrieval and `model: sonnet` for mechanical edits.

## Skills

Use the skills in `~/.claude/skills/` when the work matches their description:

- `software-architect` — DDD / hexagonal design decisions
- `requirements` — turning informal requirements into BDD scenarios
