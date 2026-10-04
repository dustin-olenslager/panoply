# Plan: consolidation mechanics and archive (M6)

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** complete
- **Spec:** `docs/agents/governance/software-factory/spec.md` (FR-001, FR-014, FR-015)
- **Domain & experts:** `n/a — internal governance record`
- **Wireframe:** `n/a — no user-facing surface` (a shell toolchain consumed by the operator and by agents)

## Context

M6, the last milestone of the factory build. Three deliverables, per the plan: the archived harness's
**capability accounting table** (no unaccounted row), the **archive with a pointer README**, and the
factory's **own build replayed through the new phases** as end-to-end proof.

## Algorithm pass

- **Question** — FR-001 (one repo, not two), FR-014 and FR-015 name the accounting and the archive. The
  requester is the owner, and the constraint is that a capability must not vanish unnoticed.
- **Delete** — see Deletion candidates. M6 *is* the delete step for the whole project.
- **Simplify** — the accounting is one table with a stated acceptance test (no unaccounted row), and the
  archive is a pointer README. No new machinery.
- **Accelerate** — the bottleneck is the same one the whole build targets: two repos cost duplicated
  design on every change. Measured below rather than asserted.
- **Automate** — the end-to-end proof is a **command anyone can re-run** (`factory-detect.sh --path .`),
  not a claim in a document. That is what makes the replay evidence instead of narrative.

## Deletion candidates

M6 is the project's delete step, so the candidates are the archived harness's own parts. Full accounting in
`CAPABILITY-ACCOUNTING.md`; here is what was *removed* rather than folded:

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| The two-repo split itself | removed | Two phase models, two state schemas, two installers, two places a phase advances — duplicated design cost paid on every change | One repo, panoply |
| The JS core (`core/**`, `adapters/**`, 20 files) | removed | A JS runtime to read a state file, inside a POSIX-sh kit, is a category error; the kit's spine already IS the state+memory layer | The phase **model** as `scripts/factory-phases.tsv`, read by a sh detector |
| The Claude-Code harness wiring (`.claude/`, `.cursor/`, `.clinerules`, `.windsurf/`, `GEMINI.md`, 35 files) | removed | Hand-maintained vendor mirrors are what `sync-agents.sh` deleted on purpose — importing them re-creates the drift | Generated mirrors from one canonical source, with CI failing on a committed mirror |
| The supervisor daemon (`run-work.sh`, `supervisord.sh`, `work-*.js`) | removed (deferred) | `claude -p`-process-specific; recreating it for Hermes is a different build with a different execution model | The rule survives — the plan's `Next step` field is the checkpoint |
| A second backlog (`TASKS.template.md`) | removed | phalanx's own ADR-0006 flags two backlogs as the problem | One queue: `docs/agents/in-progress.md` |
| Pure-duplicate skills (`caveman*`, `clean-architecture`, `brief`, `execute-phase`, `recall-memory`) | removed | Already live in Hermes or already a kit rule — a vendored copy is a second source that drifts | The live originals |
| Deleting `a pilot repo` outright | rejected | An archive keeps the decision log and the pointer; a delete destroys the *why* | Archived read-only with a pointer README |

## Steps

- [x] Capability accounting from the **real 183-file tree**, not the architect's summary — see `docs/agents/governance/factory-consolidation/CAPABILITY-ACCOUNTING.md`
- [x] Found and closed three gaps the summary had papered over — ADRs never copied, four skills marked "folded" but landed nowhere, the leak guard kept only in prose — recorded in `docs/agents/governance/factory-consolidation/CAPABILITY-ACCOUNTING.md` (docs/agents/governance/factory-consolidation/plan.md)
- [x] All 6 ADRs copied to `docs/agents/governance/factory-consolidation/adr/` as the decision log for the thing being folded in
- [x] The four non-duplicate skills landed: `edge-hunter`, `maintain-mode`, `optimize-loop` were already live as Hermes skills (verified, not assumed); `token-discipline` was genuinely missing and now lives in Hermes — recorded in `docs/agents/governance/factory-consolidation/CAPABILITY-ACCOUNTING.md`
- [x] **End-to-end proof**: `scripts/factory-detect.sh` re-run against the factory's own repo — which found two more real defects, below (`scripts/factory-detect.test.sh`)

## Review / expert sign-off

- **Security:** `n/a — reads a file tree and git state; no network, no credentials. The copied ADRs were checked for secret material before landing.`
- **Performance:** `n/a — the accounting is a document; the detector is sub-second`
- **Maintainability:** reviewed by the parent. The accounting table has a stated acceptance test (no unaccounted row) and is regenerable from the file tree rather than from memory.
- **UX:** `n/a — no user-facing surface`

## Outcome

The end-to-end proof — running the factory's detector on the factory's own repo — is where M6 earned its
keep. It reported the **wrong active feature**, and tracing that found two more defects:

1. **`completed/` leaked into the feature list.** The exclusion was `*/completed/*`, which matches a
   directory's *children* but not the directory itself (`.../completed/`). The completed archive was
   therefore an eligible feature — and eligible to be named the active one. Fixed by matching both.
2. **The queue was consulted before the branch.** The detector resolved the active feature by grepping
   slug names against `in-progress.md`, which on this repo picked a **stale plan-only folder**
   (`dev-workflow-locked-policy`) while the branch plainly named the work in progress. A branch name is
   the most current statement of what is being worked on — it changes when the work changes, whereas a
   queue row is something somebody has to remember to update. The branch is now checked first, with a
   two-token minimum so a one-word folder cannot match half the fleet.

Both defects were invisible to every gate and to all twelve canaries. They surfaced only because the
proof was a **command** run against real work, which is the argument for making the proof re-runnable
rather than a paragraph claiming the phases fit.

A third observation is a limitation, not a defect: the factory's own feature folders
(`software-factory`, `factory-consolidation`, …) had **no queue rows**, so the branch path is what
resolves them. Recording it here because it is the kind of gap an accounting exists to expose — and
because the fix (adding the rows) is real work, not a doc edit.

## Spec coverage

| Requirement | Milestone |
|---|---|
| FR-601 | M6 |
| FR-602 | M6 |
| FR-603 | M6 |
| FR-604 | M6 |
| FR-605 | M6 |
