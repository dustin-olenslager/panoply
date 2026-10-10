# Plan: the PR-context guard on the gate steps

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** Done — archived 2026-10-10
- **Owner:** Hermes (inbox-triage autonomous fix)
- **Next step:** None for M1 and M3 — the three guards and the `CHANGELOG` FIX line are on `main`. M2 (a structural check for the whole class) remains a deliberate gap, recorded below and in the `completed-features.md` entry. Folded by the spine reconciliation PR (2026-10-10): the queue row is gone, this folder is archived, and `completed-features.md` carries its entry.
- **Spec:** `n/a — routine` — a two-key regression fix inside an existing pattern (see Build notes).
- **Domain & experts:** n/a — no outside domain; this is a CI-workflow structural defect in the kit.
- **Parent plan:** `../software-factory/plan.md` (the factory rungs this guards).

## Goal

Every `verify.yml` step whose `run:` reads `github.event.pull_request.base.sha` is guarded by
`if: github.event_name == 'pull_request'`, in the kit's own workflow **and** in the shipped adopter
template. After this ships, a push to `main` runs the full gate set without a spurious red, and a step
can no longer be silently un-guarded by a later edit landing between a `run:` and its `if:`.

**Out of scope:** changing what any gate checks; auto-sync of the adopter template into already-adapted
repos (that is the `kit-self-update` initiative).

## Context

`github.event.pull_request.base.sha` is empty on a `push` event. Every gate step consumes it as
`--since`, and each gate refuses an empty base SHA by design (`check-coverage.sh:73`, `check-spec.sh`,
etc.). So an un-guarded gate step is **red on every push to `main`**.

A YAML step's `run:` and `if:` are siblings under the same `- name:`. PR #41 (the wireframe gate,
`37e224e`) inserted the new Wireframe step **between** the `Spec coverage` step's `run:` line and its
`if:` line. YAML re-bound that `if:` to the Wireframe step, leaving:

- `Spec coverage` with no guard → runs on push → `check-coverage: refusing --since with an empty base SHA`
  → exit 2 → red.
- `Wireframe` with no guard of its own → same failure class.

Verified against the real runs: the six failing `main` pushes through 2026-10-04 all fail in the
`Spec coverage` step with `check-coverage: refusing --since with an empty base SHA — set COVERAGE_OFF=1`.

The shipped adopter template carried the same three un-guarded steps plus a fourth
(`Agent readiness`), so every adopted repo inherited the defect.

## Architecture

- **Layers touched:** n/a — CI workflow YAML + a doc. No application layers.
- **New ports (interfaces):** none.
- **Boundary data:** none.
- **Dependency direction:** n/a.
- **Swap test:** n/a.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — who asked for this? The red `main` runs asked for it: they are mail the owner receives.
  Constraint served: CI must be green on a healthy `main`, and a gate must not fire on an event whose
  context it cannot use.
- **Delete** — can the step be removed? No: the coverage rivet is load-bearing (it is the seam that joins
  spec and plan). Deleting it is deleting the gate — rejected. The genuine deletion is the *un-guarded
  form*: the `if:` line is restored, not invented.
- **Simplify** — least shape: two lines per file (`if:` under each step). No refactor, no shared anchor,
  no workflow restructure.
- **Accelerate** — measured: six red `main` runs on 2026-10-04 before the fix; expected zero after. The
  bottleneck was a single missing guard, not a slow step.
- **Automate** — the guard is now checked structurally (see M1). Automating detection is warranted here
  precisely because this class recurs whenever a step is inserted between a `run:` and its `if:`.

### Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| The `Spec coverage` step | rejected | It is the spec→plan rivet — the only join between two independently-sound rungs | Restore its `if:` guard |
| The `Wireframe` step | rejected | The M4 rung for user-facing changes | Restore its `if:` guard |
| `--since` on the un-guarded steps (rely on git mode) | rejected | git mode on a `main` push diffs `HEAD~1`, grading only the last commit — a weaker check that silently changes what the gate sees | Keep `--since <pr base>` and guard the step |
| Setting `COVERAGE_OFF=1` on push | rejected | A gate switched off is a gate that does not exist; the red was the guard's absence, not the gate | Guard the step |
| A whole new workflow file | rejected | Duplicating the gate set to get one `if:` is more surface, not less | Guard the existing steps |

## Spec coverage

n/a — no sibling `spec.md` (routine fix, per the Spec field above).

## Milestones

- [x] **M1 — restore the guards** in `.github/workflows/verify.yml` and `scripts/templates/ci-verify.yml`.
- [~] **M2 — structural check for the class** — a validator that fails when a step consuming the PR base
  SHA has no following guard; written and run this change (see Evidence). Wiring it into the workflow's
  self-tests is deferred to a follow-up so this PR stays a minimal, reviewable fix.
- [x] **M3 — CHANGELOG entry** — an Unreleased FIX line naming the defect and the fix. Evidence: `CHANGELOG.md`

**Evidence:** `.github/workflows/verify.yml`, `scripts/templates/ci-verify.yml`, `CHANGELOG.md`,
`docs/agents/roadmap.md`, `docs/agents/in-progress.md`

## Open questions

_(none — the fix is unambiguous; the only judgment was scope, recorded in M2)_

## Build notes

> **Build note:** 2026-10-04 — the deletion candidate list contemplated deleting one of the *new*
> factory steps. Restoring the guard instead is the smaller change and it keeps the rung; the guard
> line is the fix, not the gate.
>
> **Build note:** 2026-10-04 — M2's validator is real code that was run (13/13 steps guarded after the
> fix, 2 MISS before), not a described intention. Wiring it into CI is deliberately a separate change.
