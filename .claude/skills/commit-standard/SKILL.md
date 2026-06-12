---
name: commit-standard
description: The commit checklist for The Inferno's Curse — Task sync, MEMORY.md update, layout version bump, clean build, meaningful message format, and always push. Use on every commit to this project.
---

# Commit Standard

## Every Commit Must Include

### 1. Task Sync
Before committing check PROJECT_TASKS.md.
Move any completed tasks to the [DONE] section.
Add any newly discovered issues to the [TODO] section
with context body and commit hash.

### 2. MEMORY.md Update
If anything new was learned this session:
- New rule established
- New failure mode discovered
- New workflow proven
- New sprite generation trick found
Add to relevant MEMORY.md entry or
create new entry.

### 3. Layout Version Bump
If any layout changed:
Bump that room's *_LAYOUT_VERSION macro.
Never skip this — stale layouts cause
silent failures.

### 4. Clean Build
Always run clean_build.ps1 after commit.
GameMaker must be closed first.
Never skip — cache causes ghost assets.

### 5. Meaningful Commit Message
Format:
"[Location] [what changed] — [key details]"

Examples:
"Room_ponte_vecchio — floor tile fixed,
water zones added, shops rescaled"

"Florence v2 gap pass — density, ground
treatment, wall towers, countryside"

### 6. Push
Always push to current branch.
Never leave commits local only.
