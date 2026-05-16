# User instructions

Cross-project practices that apply to every session, including headless runs (`claude-loop`).

## Engineering practices

### Test Driven Development (TDD)

- Write a failing test before any production code. Red → green → refactor.
- Smallest possible test that captures the next piece of behaviour; minimum production code to make it pass.
- Do not write production code "in anticipation" of tests that don't exist yet.
- Refactor only when all tests are green.
- For non-trivial test-first work, delegate to the `tdd` agent.

### Domain Driven Design (DDD)

- Keep the domain model at the centre. Domain code has no dependencies on frameworks, I/O, or delivery mechanisms.
- Use the ubiquitous language of the domain in code, names, and conversation.
- Respect bounded contexts. Don't leak concepts across them without an explicit translation.
- Prefer hexagonal layering: domain → application → infrastructure/delivery, dependencies pointing inward.
- For design decisions about aggregates, bounded contexts, ports, or adapters, delegate to the `software-architect` agent.

### Scope discipline

- Don't add features, refactor, or introduce abstractions beyond what the task requires.
- If you discover something out of scope that genuinely blocks progress, stop and report it — don't improvise.

## Plan and loop completion gates

These rules apply whenever work is being executed against a plan, especially under `claude-loop` where tasks run headlessly and sequentially.

### Before marking a task complete

A task is **not** complete until all of the following are true:

1. Every acceptance criterion / BDD scenario referenced by the task is verified.
2. All tests relevant to the task are green (the ones it added, and the existing suite for files it touched).
3. The change compiles / type-checks / lints cleanly for the project.
4. No `TODO`, placeholder, or commented-out production code introduced by this task remains.

### Hard stop on failure

If any of the above is not satisfied:

- **Do not advance to the next task.**
- **Do not** mark the current task complete.
- Stop, report what failed, and what was tried. Wait for human input.

This rule overrides any instruction (in a task file or otherwise) that says "continue on failure" or "skip and move on". When running under `claude-loop`, exit non-zero rather than proceeding to the next plan file with a broken state.

### Plan-to-plan ordering

When working through a numbered plan directory (`plan-01-*.md`, `plan-02-*.md`, ...):

- Complete plan N fully — including the gate above — before reading plan N+1.
- If plan N's output is required by plan N+1 and is missing or broken, stop. Don't fabricate it.

## Agent delegation

Default to the specialised agents already configured in `~/.claude/agents/` when the work matches their description:

- `tdd` — anything test-first
- `software-architect` — DDD / hexagonal design decisions
- `requirements` — turning informal requirements into BDD scenarios
- `qa` — test strategy and validation
- `code-refactor` — behaviour-preserving cleanup
- `security` — threat modelling and vulnerability review

Don't duplicate work an agent is doing in parallel.
