---
name: retro
description: Review the skill feedback log, find recurring problems, and propose specific edits to skills or CLAUDE.md for the user to approve
argument-hint: "[skill name, e.g. deliver; omit for all skills]"
disable-model-invocation: true
---

You are reviewing how skills have performed in real runs, so the user can improve them. Work only from evidence in the log. **Never edit any file until the user approves the specific change.**

## Step 1: Read the evidence

- Read `~/.local/share/skill-feedback/<skill>.md` for the skill in `$ARGUMENTS`, or every file there if none was given. Entries are written in the format in `capture.md` (next to this file).
- Use only entries marked `Reviewed: no`. If there are none, say so and stop.
- Read the current `SKILL.md` of each skill involved, and the global CLAUDE.md (`~/.claude/CLAUDE.md`), so proposals fit what's there now.
- If the current repo has `plans/`, compare its slices marked done against the `deliver` entries, and list any runs that left no entry.

## Step 2: Find patterns

Group the entries into problems: the same correction, wrong assumption, failed gate, skipped step, unnecessary question, or danger-guard stop showing up again.

- **Recurring:** seen in 2 or more entries. Give the count and quote the evidence, with dates.
- **Severe one-off:** seen once but serious, e.g. a wrong assumption that reached production, or a danger-guard trigger that was missed.
- **Noise:** everything else. List it in one line and propose nothing.

Don't judge runs beyond what the entries record. A model reviewing its own skills is biased, so the evidence decides.

## Step 3: Propose changes

For each recurring or severe problem, propose the smallest specific change that would have prevented it:

- the file (`SKILL.md`, CLAUDE.md, or `capture.md` if the log is missing something useful),
- the exact diff,
- the entries it addresses.

Prefer tightening or deleting an instruction over adding a new one. If no edit would help (e.g. the user changed their mind), say so.

## Step 4: Apply only what's approved

Show the proposals and wait. Apply only the ones the user approves, exactly as approved. Leave committing to the user's normal flow (e.g. `/ship-it`).

Then, in the log, change each entry you analysed from `Reviewed: no` to `Reviewed: <today's date>`, whatever was decided about it.
