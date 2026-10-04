# Plan: The Panoply Software Factory

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** In progress
- **Spec:** `spec.md` in this folder
- **Domain & experts:** `n/a — internal developer tooling` (see spec → Domain & outside experts for the
  three practitioner debates that shaped these requirements)

## Context

This plan builds the factory **using the factory's own phases** (spec → expert input → persona
interviews → wireframe → plan → build → verify → ship). The owner's instruction was explicit: build it
with the methodology being built. So this plan is both the design and the first proof — each rung is
exercised on this work before it is asked of any other repo.

The order below follows the owner's mandated sequence:
**expert debate → persona/user interviews → wireframes → simulations/interviews against the
wireframes → backend.**

## Deletion candidates

| Candidate | Disposition | Why |
|---|---|---|
| **The two-repo split itself** (`panoply` + `a pilot repo`) | **removed** | It is the defect. A rule change lands twice or lands in one, and the two drift — observed twice in one day on the same day this was planned. Keeping both guarantees the drift continues. |
| **Porting `core/domain/phase-machine.js` into the kit as code** | **removed** | Panoply is zero-dependency POSIX shell and runs anywhere. Carrying a Node runtime to enumerate a list of phases re-creates the duplication the merge exists to kill. The phase *model* is kept as data + doctrine (`phases.tsv` + rules); the JS is a source of *behaviour*, not of code. |
| **`adapters/` (memory/obsidian, models/router-policy, state/fs) as kit components** | **removed** | Hermes already provides memory (gbrain), model routing (LiteLLM), and state. Vendoring a second implementation of each into the kit duplicates working infrastructure — and the kit has no business owning them. Their *lessons* (e.g. router-policy's tiering) are recorded, the code is not carried. |
| **`kapsel` (archived orchestrator)** | **removed** | Already archived. Its idea — a queue driving per-repo work — is superseded by the phase model + the existing `in-progress.md` queue. Carrying it would add an orchestrator layer above an orchestrator. |
| **A second artifact tree for wireframes** (top-level `wireframes/`) | **removed** | The kit's own precedent is that spec and plan are SIBLINGS in the feature folder, and that a second tree for the same feature is how the two drift. The wireframe is a sibling at the same path contract. |
| **A hosted design tool (Figma / a preview URL) as the wireframe target** | **removed** | Breaks three properties the kit depends on: no third-party dependency, reviewable as a git diff, and headlessly drivable by an agent. Kept only as a documented manual alternative. |
| **A separate `tasks.md` (as spec-kit ships)** | **removed** | The plan already carries milestones; a third artifact between spec and code is the seam problem this plan exists to fix, not a fix for it. |
| **A new persona file for the "refuter" role in interviews** | **removed** | The kit's own rule: a persona file nothing invokes does not survive. The refuter is a ROLE in the interview protocol, not a file — it needs no artifact. |
| **Citing requirement IDs inside prose acceptance criteria** | **removed** | Only milestones and findings cite `FR-NNN`. Requiring it everywhere would make every sentence a citation and teach readers to skim the IDs, which is how a coverage check stops meaning anything. |
| **All 13 original persona files** | **already removed** (PR #34) | 10 were deleted and 2 wired at planning time; this plan does not reinstate any. |
| **A gate for "is the expert a real expert"** | **not built** | Unjudgeable by any file-presence check, and a fabricated expert would pass it. The kit's precedent (the expert-review gate that verified only a file's existence) is exactly this failure. Recorded as a gap, not automated. |
| **A gate that verifies a plan was CARRIED OUT** (plan → code) | **not built — deliberately sequenced later** | Real and worth having, but it is the second river to bridge. The Algorithm's ordering rule applies: fix the earliest seam first (spec → plan), then reconcile plan → code. Building both at once would make a red result ambiguous between the two. |

## Milestones

Each milestone ships something usable and testable. Milestone 1 proves the loop end to end before any
breadth, per the owner's "thin slice first, then expand".

### M1 — The spec→plan rivet (the seam the audit proved is missing)

**Ships:** requirement-level coverage. Plan milestones must cite the spec's `FR-NNN`; a new check
refuses a plan with an uncovered requirement; a canary proves both directions under mutation.

**Why first:** the planning audit found nothing connects spec to plan, and produced real evidence of
the damage in this repo (`spec-before-plan/spec.md:98` promises *12 passed*, the canary reports *21*;
5 plans with no spec; a spec pointing at a plan that does not exist). This is the earliest broken
seam, so by the Algorithm's ordering it is fixed first.

**Proven by:** `check-coverage.sh` + canary (pass a covered plan, refuse an uncovered one, go red under
mutation). Applied to this very spec/plan pair as the first fixture.

**Deliberately not yet:** plan → code reconciliation (M5).

### M2 — The phase model and the detection rule

**Ships:** `phases.tsv` (the phase table as data) + the doctrine rule + `panoply-detect.sh`, which
reads the twelve observations from disk and prints the phase, the evidence, and the next step.

**Why second:** every later rung needs to know which phase it is being asked about.

**Proven by:** detection against three fixture repos in genuinely different states (greenfield,
mid-build, shipped) and a fourth monorepo fixture; each result asserted against its expected phase AND
its evidence lines.

**Deliberately not yet:** acting on the phase — M2 only reports it.

### M3 — The wireframe rung

**Ships:** the wireframe path contract, the production procedure, and the interview protocol —
generator/judge separation with the fixed refuter role.

**Proven by:** a wireframe produced for a real spec's user stories, and at least one interview finding
recorded with the decision it changed.

**Deliberately not yet:** the presence gate (`check-wireframe.sh`) — get the artifact right before
gating it.

### M4 — The wireframe interview loop, gated

**Ships:** `check-wireframe.sh` (presence-only, own-remedy-exempt, `WIREFRAME_OFF=1` hatch) + canary,
and the findings flow into the spec's existing interview table.

**Proven by:** the gate refuses a UI-bearing change with no wireframe and passes one with it; the
findings table is populated from a real run.

### M5 — Plan → code reconciliation

**Ships:** a check that a plan's completed milestones correspond to a verified change, closing the
second seam the audit named.

**Proven by:** a fixture where a plan claims a milestone no change delivered, refused.

### M6 — Consolidation mechanics and archive

**Ships:** the archived harness's capability accounting table (every row folded in / dropped with a
reason / not built), the archive with a pointer README, and the factory's own build replayed through
the new phases as the end-to-end proof.

**Proven by:** the accounting table has no unaccounted row; the factory's own artifacts pass the
factory's own gates.

## Wireframe

`n/a — no user-facing surface.` This is a shell toolchain consumed by the operator and by agents:
there is no screen to design. Recorded here rather than skipped silently, per FR-010.

## Spec coverage

| Requirement | Milestone |
|---|---|
| FR-001 | M6 |
| FR-002 | M2 |
| FR-003 | M2 |
| FR-004 | M1 |
| FR-005 | M1 |
| FR-006 | M3 |
| FR-007 | M3 |
| FR-008 | M3 |
| FR-009 | M3 |
| FR-010 | M3 |
| FR-011 | M2 |
| FR-012 | M2 |
| FR-013 | M1, M4, M5 |
| FR-014 | M1 |
| FR-015 | M6 |
| FR-016 | M2, M3 |
| FR-017 | M2, M3 |

## Open questions

- None blocking. The rollout question (which adopters migrate when) is recorded in the spec and does
  not block M1–M5.

## Owner decisions (locked 2026-10-04)

| Question | Decision | Note |
|---|---|---|
| May simulated interviews run unattended? | **Full auto, no draft** | Interviews feed straight into the plan. The SME proposed a draft-for-review step; the owner removed it. |
| May green PRs be auto-merged here? | **Yes — auto-merge all green PRs** | Overrides the SME and the orchestrator, both of whom recommended no auto-merge for this build. Guardrail below. |
| Wireframe format and location? | **In-tree HTML**, sibling to spec/plan | Framework-free, git-diffable, agent-drivable. Matches the SME. |
| Start building on spec approval? | **Merge #37, then M1** | M1 proven on this spec/plan pair. |

**The auto-merge guardrail (protects the owner, not the schedule).** Auto-merge is on. Two conditions
still stop it, because they are the cases where a merge destroys the ability to review: (1) a PR that
changes a gate or a rule module and whose canary does not prove the change both ways; (2) a PR whose CI
is not green on the head being merged. In both, the PR waits and the reason is reported. Everything
else auto-merges and the merges are reported in the running log.

## Next step

**M1** — build `scripts/check-coverage.sh` + its canary, and run it against this spec/plan pair as the
first fixture.

## Steps

- [ ] M1 — `check-coverage.sh` + canary; applied to this spec/plan pair
- [ ] M2 — `phases.tsv` + detection doctrine + `panoply-detect.sh` + 4 fixture repos
- [ ] M3 — wireframe path, production procedure, interview protocol with the refuter role
- [ ] M4 — `check-wireframe.sh` + canary + findings flow
- [ ] M5 — plan → code reconciliation check + fixture
- [ ] M6 — capability accounting, archive, factory build replayed through its own phases
