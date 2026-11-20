# Plan: queue fragments — one file per task

- **Area:** governance  ·  **Started:** 2026-11-20  ·  **Status:** In review
- **Owner:** dev-kit lane "inprogress-fragments" (DevKit card `inprogress-fragments` V1)
- **Next step:** merge this PR; then dev-kit copies `scripts/queue.sh`, the doctrine and the CI step
  and migrates its queue (dev-kit PR). Backlot and frameforge adopt in V2.
- **Roadmap initiative:** Queue fragments
- **Spec:** `spec.md` in this folder.

## Goal

A PR's queue change lives in its own file, so two PRs that each add or update a queue item merge in
either order with no conflict, and every reader still sees the same ordered queue.

## Context

dev-kit, 2026-11-20 17:50 UTC: all 8 open PRs blocked; 5 only by `docs/agents/in-progress.md`, which
every PR edits. Watchers waiting for MERGED stalled until someone rebased. The worklog had the same
problem and moved to `worklog.d/` on 2026-11-12; the queue is the remaining shared file.

## Architecture

- **Layers touched:** none of an application's; this is kit tooling (POSIX sh) and doctrine.
- **New ports:** none. `scripts/queue.sh` is the one reader other tools call (`render`, `list`).
- **Dependency direction:** tools depend on `queue.sh` output, not on the fragment layout.

## Decisions

1. **Fragment shape.** `key: value` lines between `---` fences (no YAML library needed: POSIX sh/awk
   and stdlib Python parse it); body = Notes. Keys: `order` (required int), `item`, `status`, `area`,
   `initiative`, `plan`, `id` (the old `#` label), `section` (active | blocked | parked) with
   `blocked-on`/`since` or `why`/`revisit`; `req`/`risk` kept from ADR-0006 for loop drivers. Cell text
   is stored verbatim so a render reproduces the old rows exactly.
2. **Order key.** An integer with gaps (10, 20, …), not the file name: inserting between two items edits
   only the new file. Ties break by slug, so equal orders never conflict either.
3. **No committed render.** A bot-committed `in-progress.md` would be the shared file again (and a push
   to protected main per merge). Readers render on read: `sh scripts/queue.sh render`.
4. **The old file stays as a frozen pointer.** Agents and prompts that open `in-progress.md` find where
   the queue went; CI refuses edits to it once the folder exists at the base.
5. **Page around the tables = `in-progress.d/README.md`** with `<!-- queue:… -->` markers; header facts
   (e.g. a repo's "Current outcome" line) live there and change rarely.
6. **`id` uniqueness is not enforced.** dev-kit's table already reuses four `#` labels; the file name is
   the unique key.
7. **Why again:** an earlier fragment rule (1.x) was withdrawn because the kit repo did not use it. This
   one ships with the kit's own queue migrated, a render script and a CI check, so doctrine and dogfood
   agree.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — Dustin, 2026-11-20: "no PR ever conflicts on the work queue again".
- **Delete** — the shared table (deleted as a write target); a committed render (never built); the
  `id` uniqueness rule (dropped: real data violates it and nothing needs it).
- **Simplify** — flat `key: value` front matter instead of YAML; one script with three verbs.
- **Accelerate** — removes the rebase + CI rerun each merge forced on every open queue-touching PR.
- **Automate** — the CI check is the last step, after the format and migration were done by hand.

### Deletion candidates

- The frozen `in-progress.md` pointer itself, once no tool or prompt names the old path (revisit 2027).

## Spec coverage

| Requirement | Milestone |
|---|---|
| FR-001 | M1, M4 |
| FR-002 | M1, M2 |
| FR-003 | M1, M3 |
| FR-004 | M1, M3 |
| FR-005 | M3 |

## Milestones

- [x] M1 the queue tool and its canary — `scripts/queue.sh`, `scripts/queue.test.sh`
- [x] M2 doctrine — `.agents/rules/documentation.md`, `.agents/rules/workflow.md`, `AGENTS.md`, `docs/agents/README.md`
- [x] M3 kit readers + CI step — `scripts/factory-detect.sh`, `scripts/check-plan-home.sh`, `scripts/panoply.sh`, `scripts/templates/ci-verify.yml`
- [x] M4 the kit's own queue migrated — `docs/agents/in-progress.d/README.md`
- [ ] M5 dev-kit adopts (dev-kit PR); backlot + frameforge in V2

## Open questions

None.

## On ship

Delete `in-progress.d/inprogress-fragments.md`, move this folder to `governance/completed/`, add the
`completed-features.md` entry, move the roadmap row to Shipped.
