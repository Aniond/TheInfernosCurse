---
name: session-wrap
description: End-of-session wrap for The Inferno's Curse — audit changed files, update the MEMORY.md cheat sheet with current state and a numbered pick-up list, sync Notion, final commit + push, and leave tomorrow's brief. Use when David says wrap up, end of session, or done for today.
---

# Session Wrap

## Run at End of Every Session

### Step 1 — Audit Changed Files
Re-read every file changed this session.
Verify output matches what was claimed.
Identify any gaps or missed edge cases.

### Step 2 — Update MEMORY.md Cheat Sheet
Rewrite the session cheat sheet entry:
project_florence_v2.md or relevant doc.
Include:
- Full current state
- What was built today
- Known issues flagged
- Tomorrow's pick-up list numbered

Format pick-up list as:
1. [Pending decision: description]
2. [Next build task: description]
3. [Polish item: description]

### Step 3 — Notion Sync
Mark all completed tasks Done.
Add newly discovered work as Todo entries.
Include commit hash in context body.

### Step 4 — Final Commit
Commit message format:
"Session wrap [date] — [summary of day]"
Push to current branch.

### Step 5 — Tomorrow's Brief
End every session wrap with:
"Tomorrow starts here:
1. [First task]
2. [Second task]
3. [Third task]
Even if this window closes Fable 5
reads MEMORY.md and picks up exactly here."
