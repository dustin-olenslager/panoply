# In Progress

**Read this first.** The ordered queue of what is next. Top of the list is what to pick up now.
Every item points at a plan doc — if an item has no plan doc, it is not ready to start.

**One file per task.** Each item is its own file in this folder, `<slug>.md`: a few `key: value`
lines between `---` fences (`order`, `item`, `status`, `plan`, …; the shape is in the header of
`scripts/queue.sh`), then the Notes. A PR adds, edits or deletes only its own task's file, so two PRs
never conflict on the queue. Read the whole queue as one table with `sh scripts/queue.sh render`;
that table is generated and never committed. `order` sorts it (lower is nearer the top; ties break by
file name), so leave gaps (10, 20, 30) and insert between them.

The **Notes** (the text under the second `---`) are the task's handoff: keep the *exact next step*
there — the file to open, the command to run, the blocker — refreshed whenever you pause, so the next
session resumes cold. A task with no next step is a task nobody can pick up. (Doctrine:
`.agents/rules/documentation.md`.)

Each task rolls up to a `roadmap.md` initiative (the strategic view) and leaves a trail in the worklog
(a `worklog.d/` fragment, or an unmigrated repo's `worklog.md` / `CHANGELOG` `[Unreleased]`). A task with no initiative is tactical work with no
strategic home — add the initiative to `roadmap.md`, or say in Notes why it is a deliberate one-off.

When an item ships: delete its file here, move its folder into `<area>/completed/`, and add an
entry to `completed-features.md`.

## Active queue

<!-- queue:active -->

**Status vocabulary:** `Not started` · `In progress — milestone N of M` · `Blocked — <on what>` ·
`In review` · `Done — archiving`.

## Blocked / waiting

Items that cannot move, and the one thing each is waiting on (`section: blocked`, with `blocked-on:`
and `since:`). Review this list before starting
anything new — an unblocked item here outranks a fresh one.

<!-- queue:blocked -->

## Parked

Ideas deliberately deferred (`section: parked`, with `why:` and `revisit:`). Keep the reason — "we said no because X" is what stops the same
proposal coming back every month.

<!-- queue:parked -->
