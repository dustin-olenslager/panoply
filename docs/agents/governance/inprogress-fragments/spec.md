# Spec: queue fragments — one file per task

- **Status:** Accepted 2026-11-20  ·  **Requester:** Dustin (operator), from dev-kit evidence on 2026-11-20
- **Domain & outside experts:** software delivery with many concurrent automated contributors (40
  headless DevKit jobs a day, each opening PRs). Practice consulted: the changeset / towncrier
  "fragment per change" pattern the kit already uses for the worklog (`worklog.d/`), and Panoply's own
  ADR-0006 (2026-08-30), which chose per-task queue files for the same reason. No outside interview;
  the evidence is the merge queue itself.

## What a user can do after this ships

A contributor (person or agent) changes the queue in a PR by adding, editing or deleting only their own
task's file, and that PR never conflicts with another PR's queue change. A reader still sees one ordered
queue table.

Wireframe: n/a — no screen; the surface is a file layout and a CLI (`sh scripts/queue.sh render`), and
its rendered output is the existing queue table, unchanged.

## User interviews (simulated, 4 personas)

These are SIMULATED role-plays by the planning agent, not real interviews; they surface requirements to
check, never quotes.

| # | Persona | What they were asked | What they said (SIMULATED) | Decision it changed |
|---|---|---|---|---|
| 1 | Operator who reads the queue each morning | What must not change for you? | The same ordered table, top = next; I do not want to open 70 files. | `render` reproduces the old table; no committed render (it would conflict). |
| 2 | Headless agent lane opening a PR | How do you add your task? | One new file I own, a shape I can write without a library, and a clear refusal if I get it wrong. | Flat `key: value` front matter; `check` names the file and the fix. |
| 3 | Reviewer of a PR | What do you need in the diff? | The queue change next to the code, small. | One fragment per task in the same PR. |
| 4 | Maintainer of an unmigrated repo | What breaks for you? | Nothing until I choose to migrate. | Unmigrated passes; `apply` never creates the folder beside an existing table. |

## User stories

1. **P1 — two PRs, no conflict.** Two PRs each add or update a different queue item; both merge, in
   either order, with no conflict. *Test:* `scripts/queue.test.sh` case 6 merges two branches both ways.
   - Given main has items A and B, When PR1 edits A and adds C and PR2 edits B and adds D, Then merging
     PR1 then PR2, or PR2 then PR1, succeeds with no conflict and renders the same queue.
2. **P1 — same queue for readers.** *Test:* render of a migrated repo gives the same rows as the old
   table (kit: byte-identical; dev-kit: every row identical).
   - Given a legacy `in-progress.md`, When it is split into fragments, Then `queue.sh render` prints
     the same rows in the same order.
3. **P2 — CI keeps the shape.** *Test:* `queue.test.sh` cases 3–5.
   - Given a migrated repo, When a PR edits `in-progress.md`, Then `queue.sh check --since` fails and
     says where the row belongs. When a fragment has a bad front matter, Then check fails naming it.

## Requirements

- **FR-001** The queue MUST be `docs/agents/in-progress.d/<slug>.md`, one file per task, with
  `key: value` front matter and the Notes as body; `order` (integer) MUST sort it, ties by file name.
- **FR-002** A rendered table MUST NOT be committed; `scripts/queue.sh render` MUST build it on read.
- **FR-003** `scripts/queue.sh check --since <base>` MUST refuse a bad fragment and, once the folder
  exists at the base, any edit to `docs/agents/in-progress.md`.
- **FR-004** An unmigrated repo (no folder) MUST keep working unchanged: render prints the old file,
  check passes, `apply` never creates the folder beside an existing table.
- **FR-005** Every kit reader of the queue (`factory-detect.sh`, `check-plan-home.sh`, `panoply.sh`)
  MUST read the folder when it exists.

## Success criteria

- Zero PRs blocked by a queue-file conflict in a migrated repo (dev-kit measures it from the merge
  train after adoption).
