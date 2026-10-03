# Spec: Spec artifacts — a spec you must actually write before a plan

- **Area:** `governance`  ·  **Started:** 2026-10-03  ·  **Status:** Resolved
- **Owner:** the owner (asked for it; chose kit-native gates) / Hermes (drafting)
- **Plan:** `plan.md` in this folder.

## Goal

A person working in any repo that carries the kit writes down **what a user can do after this ships**
and **how we will know it worked**, as a small checked artifact, before any code exists — instead of
discovering the requirement mid-implementation, or never stating it at all.

## User stories

### US-1 — an agent cannot start structural work without stating the requirement (P1)

An agent (or contributor) picks up a structural change in a kit repo. Before a plan is written, the
requirement is written down: who it is for, what they can do, and how anyone will know it works.

- **Why this priority:** This is the entire point of the rung. Everything else is downstream of the
  requirement existing as an artifact rather than as prose in a plan's Goal paragraph.
- **Independent test:** make a structural change to a kit repo with no spec and run
  `sh scripts/check-spec.sh --since <base>` — it refuses and names the remedy. Add the spec, re-run — it
  passes. Nothing else needs to exist.
- **Acceptance scenarios:**
  1. **Given** a kit repo and a structural change with no spec, **when** the spec gate runs, **then** it
     exits non-zero naming the file to create.
  2. **Given** the same change with a compliant spec added in the same change, **when** the gate runs,
     **then** it exits zero.
  3. **Given** a docs-only or behavior-preserving change, **when** the gate runs, **then** it exits zero
     without demanding a spec.

### US-2 — an ambiguity cannot be carried silently into a plan (P2)

A requirement nobody has decided yet is written as a marker, and that marker cannot survive toward
implementation.

- **Why this priority:** An unresolved unknown that reaches the plan has already become an unreviewed
  guess — the specific failure the kit forbids everywhere else. P2 because the rung can be adopted
  before the marker rule bites, but the marker is what makes the rung more than paperwork.
- **Independent test:** put `[NEEDS CLARIFICATION: …]` in a spec behind a structural change, run the
  gate — it refuses and names both legal settlements. Resolve the marker, re-run — it passes.
- **Acceptance scenarios:**
  1. **Given** a spec carrying `[NEEDS CLARIFICATION: …]`, **when** the gate runs on a structural
     change, **then** it exits non-zero and prints the offending line.
  2. **Given** the marker answered in the spec, **when** the gate runs, **then** it exits zero.

### US-3 — the rung is usable in the one workflow an agent actually uses (P3)

A spec written and staged alongside the code satisfies the gate in the same change, without a commit
cycle or a second pass.

- **Why this priority:** A gate that cannot be satisfied in the normal workflow gets bypassed with
  `SPEC_OFF=1` and then ignored — which is worse than no gate. P3 because it is a usability property of
  an already-working rule.
- **Independent test:** stage `src/x.ts` plus `docs/agents/<area>/<slug>/spec.md` and run
  `sh scripts/check-spec.sh --staged` — it exits zero.
- **Acceptance scenarios:**
  1. **Given** a spec staged but not yet committed beside a structural change, **when** the gate runs in
     `--staged` mode, **then** it exits zero.
  2. **Given** only the structural change staged, **when** the gate runs in `--staged` mode, **then** it
     refuses.

## Edge cases

- **The spec gate is itself the thing being changed.** A repo adopting the rung wholesale has a backlog
  with no specs; `SPEC_OFF=1` must be a stated, reviewable exception rather than a silent bypass.
- **A shallow CI checkout** where the diff base does not resolve: the honest answer is a broken check,
  never a silent pass — the same trap `check-algorithm.sh` documents.
- **A spec that exists but is empty or meaningless.** The gate cannot detect this and says so in its own
  limits; the mitigation is review, not a bigger regex.
- **A repo with no `docs/agents/` spine at all** (a small project on one `docs/PLAN.md`): the gate
  reports a missing spec rather than silently passing.

## Requirements

- **FR-001**: A repo carrying the kit MUST expose `scripts/check-spec.sh`, runnable with no arguments,
  `--staged`, and `--since <SHA>`.
- **FR-002**: The gate MUST refuse a structural change with no spec under `docs/agents/*/*/spec.md`, and
  the refusal MUST name the remedy.
- **FR-003**: The gate MUST refuse a spec containing `[NEEDS CLARIFICATION: …]`, case-insensitively, and
  MUST print the offending line.
- **FR-004**: The gate MUST exempt doc-only changes, judged the same way as `check-algorithm.sh`, so it
  can never block a write to `docs/**` — the write that is its own remedy.
- **FR-005**: The gate MUST fail loudly (non-zero) when its diff base does not resolve, rather than
  reporting a clean result about a comparison that did not happen.
- **FR-006**: The gate MUST NOT mutate the repository it judges.
- **FR-007**: `SPEC_OFF=1` MUST disable the gate and MUST be documented as a deliberate exception.
- **FR-008**: `docs/agents/_templates/spec.md` MUST provide the artifact shape, and
  `docs/agents/_templates/plan.md` MUST carry a `Spec:` link row.
- **FR-009**: `.agents/rules/spec.md` MUST state the rule, the marker rule, the routine-work exemption,
  and the gate's honest limits; `sync-agents.sh` MUST inline it into every tool mirror.
- **FR-010**: A canary MUST assert both directions plus the refuse→remedy→allow round trip, and MUST be
  proven to go red when the gate's detection is removed.

## Success criteria

- **SC-001**: `sh scripts/check-spec.test.sh` reports 12 passed / 0 failed on the kit, and at least 5
  distinct cases fail when either detection path is removed (proven 2026-10-03: 6 and 7 failures
  respectively).
- **SC-002**: A structural change with no spec is refused in under 2 seconds on the kit tree — the same
  order as the Algorithm gate on the same glob, so the gate is not on the slow path.
- **SC-003**: Adopting the rung requires no change to `check-plan-home.sh` or `check-algorithm.sh` —
  zero new allowances in existing gates.

## Assumptions

- The kit's binding plane remains required CI; a client-side hook is convenience only, as stated in
  `AGENTS.md` → "Enforcement — the honest version".
- A feature's spec and plan live in one folder, so the existing `docs/agents/*/*/` globs cover both.
- Reviewers will judge spec *quality*; the gate deliberately judges only presence and resolution.

## On resolve

Spec is resolved; `plan.md` in this folder is the plan of record, linked from the `roadmap.md` row under
Now.
