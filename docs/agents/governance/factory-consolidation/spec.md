# Spec: consolidation mechanics and archive (M6)

- **Area:** `governance`  ·  **Status:** backfilled from the plan and the shipped artifacts
- **Spec of:** `docs/agents/governance/software-factory/spec.md` — this is a milestone-level spec, and
  the parent spec's FR-001, FR-014 and FR-015 are the requirements it discharges.
- **Domain & experts:** `n/a — internal governance record`
- **Wireframe:** `n/a — no user-facing surface` (a shell toolchain consumed by the operator and by agents)

## What a user can do

`n/a — no user-facing surface.` The reader is a maintainer or an agent. Recorded rather than skipped
silently, per the parent spec's `n/a` rule (`docs/agents/governance/software-factory/spec.md`).

## Why this exists

M6 closes the factory build by doing the thing the whole project was for: **consolidating
`a pilot repo` into panoply** without losing a capability. A merge that silently drops functionality is
indistinguishable from one that never had it, so the milestone's job is to make the loss visible — or
prove there was none.

## Requirements

- **FR-601**: Every capability of the archived harness is accounted for — folded in, dropped with a
  reason, or named as deliberately not built. **Acceptance:** the accounting table has no unaccounted row
  against the real file tree (183 files, 33 top-level entries).
- **FR-602**: Where a capability was "folded", a **live artifact exists** carrying it. Intent is not
  folding. **Acceptance:** each folded row names a path that exists in the repo today.
- **FR-603**: The archived repo's story survives — its decision log is copied, and its README becomes a
  pointer rather than being deleted. **Acceptance:** all 6 ADRs present under `adr/`; the archive is
  read-only with a pointer.
- **FR-604**: The factory's own build is **replayed through the factory's own phases** as end-to-end
  proof. **Acceptance:** `scripts/factory-detect.sh --path .` resolves the work in progress and names the
  correct phase — a re-runnable command, not a claim in a document.
- **FR-605**: A capability that is dropped must be recorded as an **open gap**, not left as prose
  intent. **Acceptance:** the accounting's open-gaps table names each one with a revisit condition.

## Acceptance scenarios

**Scenario 1 — the accounting accounts for everything.**
Given the archived repo's real file tree, when the accounting table is compared against it, then every
top-level entry appears exactly once, and no row says "considered" without naming a live artifact or a
stated reason. *(FR-601, FR-602)*

**Scenario 2 — a claimed fold-in is verified, not assumed.**
Given a row claiming a capability was folded, when the named path is checked, then it exists. *(FR-602)*
This found three real gaps: ADRs never copied, four skills that existed only as intent, and a leak guard
kept only in prose.

**Scenario 3 — the end-to-end replay finds the work.**
Given the factory's own repo on a working branch, when `factory-detect.sh --path .` runs, then it names
the feature being worked on and the phase it is in. *(FR-604)* This found two defects invisible to all
twelve canaries and every gate — a `completed/` directory leaking into the feature list, and the queue
being consulted before the branch.

**Scenario 4 — the archive preserves the why.**
Given the retired harness, when a reader wants to know why a part was dropped, then the ADR that argued
it is in the repo. *(FR-603)*

## Out of scope

- Rebuilding the supervisor daemon (recorded as deferred, with a revisit condition).
- A deny-list pre-push leak guard (recorded as an open gap — the kit genuinely lacks it).
- Adding queue rows for the factory's own feature folders (real work, recorded as a limitation).

## Open questions

None. The one design question this milestone raised — should the active feature be resolved by the queue
or the branch — was answered by observation: the branch, because it changes when the work changes, while
a queue row is something somebody has to remember to update.
