# In Progress — moved

The queue is one file per task now: **`docs/agents/in-progress.d/<slug>.md`**. Read it as one ordered
table with `sh scripts/queue.sh render`. Add, edit or delete only your own task's file there.

This file is frozen: `sh scripts/queue.sh check --since <base>` (required CI) refuses any PR that edits
it, because one shared table made every merge conflict every other open PR (Dustin, 2026-11-20).
Doctrine: `.agents/rules/documentation.md` → "Queue fragments".
