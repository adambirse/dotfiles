# Skill feedback capture

Append one entry to `~/.local/share/skill-feedback/<skill>.md` using the Read and Write/Edit tools, not the shell (Write creates the directory if needed). This log lives outside the dotfiles repo on purpose and must never be committed, because it describes work in other, possibly private, repos. It isn't under `~/.claude`, because Claude Code asks before every write there.

Record facts only, about 10 lines. No self-assessment or scores. Write "none" for anything that didn't happen.

```markdown
## <YYYY-MM-DD> <repo name> <plan / slice, or a short description>
- Outcome: <done | stopped: reason | failed: reason>
- User corrections: <quote the user's words>
- Questions asked: <count>, about <topics>; any that the repo or plan already answered
- Assumptions proven wrong: <what was assumed, and what turned out to be true>
- Gates failed: <gate, and why>
- Retries / rollbacks: <count, and why>
- Danger-guard stops: <trigger, and the user's decision>
- Steps skipped or out of order: <which, and why>
- Effort: <rough number of turns and tool calls>
- Reviewed: no
```
