# Spec: the launch gate and the honest phase table

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** Draft
- **Owner:** Hermes (SME-drafted), the owner (approving)
- **Plan:** `plan.md` in this folder.

## Goal

An adopter of the Panoply kit can now prove that a change reaching the **Ship** phase recorded both a
launch and a way back, instead of "done" being a claim nothing checks — and the kit's own CI template no
longer ships a secret scan it had commented out while implying it existed. A person running the kit gets
two former `-` cells in the phase table replaced by a real gate, and one false capability (the disabled
scan) made true.

## User stories

### US-1 — the operator cannot ship without a way back (P1)

The operator finishes a feature and goes to mark it shipped. The kit's ship rung asks for the launch
record — that the change was deployed, and the rollback line. If neither is present, the gate refuses and
the operator writes the two lines before merging. The value is that "shipped" stops being an unchecked
assertion and that a way back exists before it is needed.

- **Why this priority:** it closes a cell the kit's own data file admits is empty, and it is the one
  Tier-1 gap checkable from a diff without knowing the stack. Everything else in the enterprise list is
  either already covered or needs a runtime the kit does not have.
- **Independent test:** run `check-launch.sh --since <base>` in a fixture whose ship milestone is ticked
  with no launch record → red; add the record → green. Nothing else built.
- **Acceptance scenarios:**
  1. **Given** a plan in which a ship milestone is marked complete, **when** no launch/rollback record
     exists in the plan folder, **then** `check-launch.sh` exits non-zero and names the missing record.
  2. **Given** the same plan **when** the plan folder carries a launch record naming the rollback line,
     **then** the gate exits 0.
  3. **Given** a change that is not at the ship phase (no completed ship milestone), **when** the gate
     runs, **then** it passes without demanding a record — the rung does not apply yet.

### US-2 — the kit stops shipping a capability it disabled (P2)

The operator reads the kit's CI template to learn what protection it provides. Today it lists a secret
scan that is commented out. After this, the scan is enabled (pinned, checksum-verified), so the template
does what its own header list implies.

- **Why this priority:** it is a defect in the kit's own artifact — a stated guarantee the code does not
  give — which is the exact defect class the kit exists to remove. Lower than US-1 only because it is a
  one-line enable, not a new mechanism.
- **Independent test:** grep the two CI files for an *enabled* secret-scan step; the commented-out line
  is gone.
- **Acceptance scenarios:**
  1. **Given** `scripts/templates/ci-verify.yml`, **when** the file is read, **then** a secret-scan step
     is present and enabled, not commented.
  2. **Given** the repo's own `.github/workflows/verify.yml`, **when** read, **then** the same.

## Edge cases

- What happens when a repo has no ship milestone at all (a fresh repo, or a docs-only change)? The gate
  must pass — it gates the ship rung, and a change not at that rung has nothing to prove here.
- What happens when the deploy is to a mechanism the kit never sees (Vercel, a bare box)? The gate checks
  the *record*, not the mechanism — it never guesses the deploy path.
- What happens when the `--since` base does not resolve (shallow CI clone)? The gate refuses loudly with
  exit 2, matching every other gate, rather than reporting a pass on an empty diff.

## Requirements

- **FR-001**: `scripts/check-launch.sh` MUST refuse a change whose completed ship milestone carries no
  launch/rollback record, and pass one that does, in git / `--since` / `--staged` modes.
- **FR-002**: `scripts/check-launch.test.sh` MUST mutation-test the gate — proving it goes red when it
  should detect, not merely that it runs.
- **FR-003**: The kit's CI template and this repo's CI workflow MUST carry an enabled secret-scan step.
- **FR-004**: `scripts/factory-phases.tsv` MUST name `scripts/check-launch.sh` as the gate for phase 6,
  and the phase doctrine MUST state which phases remain ungated.

## Wireframe

Wireframe: n/a — no user-facing surface. This is a shell toolchain consumed by the operator and by
agents; there is no screen to design.

## Domain & outside experts

**Industry/domain:** internal developer tooling / software governance.

**Outside experts consulted:** none applicable — the kit governs software development, and its domain
input is software-practitioner input, recorded here rather than in a non-software persona file. The
practitioner input that shaped these requirements is the 2026-10-03 SME gap analysis
(the gap-analysis doc), which itself cites DORA/Accelerate, Google SRE, Amazon ORR, and
Microsoft SDL. No fabricated expert is named; the requirements trace to the analysis and to the kit's
own stated gaps.
