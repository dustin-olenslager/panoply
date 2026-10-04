# Plan: the launch gate — phase 6 (and the verify evidence phase 5 lacks)

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** In progress
- **Owner:** Hermes (SME-drafted), the owner (approving)
- **Next step:** implement `scripts/check-launch.sh` + its canary, wire it into
  `scripts/templates/ci-verify.yml` and `.agents/rules/factory-phases.md` / `docs/agents/roadmap.md`,
  flip the secret scan from commented-out to ON in both CI files, then run every gate locally before
  committing.
- **Roadmap initiative:** `Launch and verify phases are gated` (added to `docs/agents/roadmap.md` → Now).
- **Spec:** `spec.md` in this folder.
- **Domain & experts:** `n/a — internal developer tooling`. No outside (non-software) expert applies to a
  POSIX-sh governance kit; the practitioner input that shaped this is recorded in the source analysis
  (see Context) — two SME passes over the kit against a top-tier-org reference frame.
- **Parent plan:** none.

## Goal

After this ships, a change that reaches the kit's **Ship** phase can no longer be "done" on a claim:
the phase table's cells 5 and 6 stop being `-`, and a green `check-launch.sh` is what proves a ship has
a deploy/launch record and a rollback line — the two things the kit's own model admits it never checked.
We will know it worked when the gate refuses a plan that ticks its ship milestone with no launch record,
and passes one that names it — proven by a mutation-tested canary, the way every other gate here is.

**Out of scope:** anything requiring a runtime the kit does not have — SLOs, error budgets, uptime
alerting, an observability stack, dependency-audit tooling tied to a package manager. Those were
considered and rejected (see Deletion candidates); they belong in an adopter's `infrastructure.md`, not
in a stack-agnostic POSIX-sh template. Also out of scope: touching `frame-forge` (the adopter — a live
app; out of scope for this change).

## Context

The list this work comes from is a ranked enterprise-readiness gap analysis produced by two SME
subagents on 2026-10-03, written to `<scratch>/gap-analysis.md` (22.5 KB) and captured in that
session's delegation transcript. Its Tier-1 set was five items; its own Algorithm pass already deleted
several larger ones (staging pipelines, CAB, full observability, SBOM). Nothing on the list had been
implemented when this plan was written.

The kit's process model is `.agents/rules/factory-phases.md` + `scripts/factory-phases.tsv`. Phases 2
and 4–6 carry a `-` in the gate column. The `.tsv` header calls a `-` "a stated gap, not a licence" —
this plan closes **two** of those five stated gaps (ship, and the verify-evidence half of 5), and says
in writing why the other three do **not** get a gate here.

The decisive constraint, applied to every item: **the kit has no runtime and is deliberately
stack-agnostic.** It is copied into repos of any language; it cannot observe a deploy, an SLO, or a
lockfile without being told which stack it is looking at. A gate it cannot run is decoration.

## Architecture

- **Layers touched:** none — this is a shell + markdown governance kit (`scripts/`, `.agents/rules/`,
  `docs/agents/`). No source code, no ports, no dependency-direction changes.
- **New ports (interfaces):** none.
- **Boundary data:** none.
- **Dependency direction:** unchanged — `scripts/check-launch.sh` stays POSIX sh with no runtime deps,
  matching every other gate.
- **Swap test:** n/a — no vendor or framework is touched.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — the owner asked (a commissioned SME pass), serving the constraint "close what a
  top-tier org has that this kit lacks, *without building a platform*". Named requester: the owner. The
  kit's own purpose constrains every answer: a drop-in, zero-dependency, agent-agnostic governance kit.
- **Delete** — the candidates are the five Tier-1 items; four of five are removed, one survives as a
  shape different from the one proposed. See the table below — this is the load-bearing step here,
  because four of the five "gaps" are impossible to gate from inside this kit.
- **Simplify** — the survivor is one gate (`check-launch.sh`), not a launch *checklist engine*: it
  checks that a ship-phase change records, in a place the gate can see, (a) that the change was
  deployed and (b) its rollback line. Presence only — the same honest limit `check-wireframe.sh` states.
- **Accelerate** — no runtime path exists to measure; the "metric" is honest and integer: gate count
  13 → 14, and stated-gap cells 5 → 3. Recorded, not invented.
- **Automate** — only the survivor is automated. Automating the rejected four (an SLO poller, a
  Dependabot wrapper, a threat-model checklist) would be automating something that should not exist —
  the most expensive mistake available.

### Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| **The whole request** ("close the enterprise-readiness gaps") | rejected | Its ranking assumed gaps in a *kit* that has no runtime; four of five cannot be gated from a stack-agnostic POSIX-sh template without inventing a runtime the kit has four prior plans deleting | Keep the two that live inside the kit's own artifacts; reject the three that describe an adopter's production |
| **1. Runtime unowned — an SLO / error-budget / rollback gate** | removed | The kit has no runtime and no traffic. A gate asserting an SLO would be green forever against anything it can see — a gate that cannot go red is decoration, the kit's own stated failure mode | Its one transferable piece — "a rollback line exists" — is folded into `check-launch.sh` as **presence of a rollback record**, checked at ship time, where the kit *can* see it |
| **2. Deploy phase ungated — a `check-deploy.sh` that observes a deploy** | removed (as a separate artifact) | The kit cannot observe a deploy; it does not know the adopter's deploy mechanism (Vercel, docker-compose, a bare box). A gate that guesses the deploy path is stack-specific, which the kit is not | Merged into `check-launch.sh`: the ship phase must *record* deploy/launch evidence and a rollback line; the gate checks the record, not the mechanism |
| **3. No dependency hygiene — a Dependabot/Renovate + `check-deps.sh` audit gate** | removed | Requires naming a package manager (npm/pip/cargo) — the kit is deliberately stack-agnostic and ships no lockfile. A generic "audit the lockfile" gate cannot exist without picking a stack, and picking one makes the kit correct for exactly one ecosystem | Left to the adopter's CI. The kit's `ci-verify.yml` already leaves the toolchain steps as `<CMD>` placeholders for exactly this reason; dependency audit belongs there, not in the kit |
| **4. No design-time security — the secret scan is commented out in the kit's own CI template** | **kept — built** | This one is a defect in the kit's *own* artifact: `scripts/templates/ci-verify.yml` (and this repo's `.github/workflows/verify.yml`) ship the secret scan **commented out**, so the kit claims a capability it does not provide — the exact "stated guarantee the code does not give" defect class the kit exists to remove. frame-forge already fixed the equivalent by wiring a checksum-verified gitleaks binary | Turn the step **ON** in both files. Unlike an SCA tool, a secret scanner needs no stack and no lockfile — it scans a diff — so it is the one supply-chain-adjacent gate that *is* stack-agnostic. Pin the scanner and record its checksum the way frame-forge did |
| **5. No launch / operational-readiness gate — `check-launch.sh` for phase 6** | **kept — built** | This is the one Tier-1 item that is (a) inside the kit's own model (phase 6 is a cell the kit admits is empty) and (b) mechanically checkable from a diff without knowing the stack: did the ship-phase change *record* a launch and a rollback line | `scripts/check-launch.sh` + a mutation-tested canary; wired into the CI template and named in `factory-phases.tsv` in place of the `-` for phase 6 |
| **A formal ORR review board / stakeholder sign-off / evidence archiving** | removed | Coordination overhead for a team that does not exist (the SME's own Tier-3 deletion). The owner *is* the review board | Reduced to the launch gate's presence check |
| **Post-incident loop (Tier-2 #6), perf budget (#11), a11y gate (#12), API contract snapshot (#9)** | not built | Real but lower blast radius, and each either needs a second consumer (contract snapshot), a UI (a11y), or traffic (perf) to be more than ceremony — the SME ranked them Tier 2 for exactly this reason | Recorded here as the rejections ledger so they are not re-proposed blind; revisit when a trigger fires (a second consumer exists / the product has a UI / there is load) |
| **"Matching a top-tier org" as a goal** | removed | The SME's own first deletion: a 500-person org's process coordinates people who do not know each other; the owner has no such coordination problem | Keep the reference frame, drop the goal |

## Milestones

Each milestone ships something usable and testable.

- [ ] **M1 — the launch gate (fills phase 6).** `scripts/check-launch.sh` + its mutation-tested canary; a ship claim must carry a launch record and a rollback line.
- [ ] **M2 — the secret scan, turned on.** `scripts/templates/ci-verify.yml` and `.github/workflows/verify.yml` carry an enabled, pinned, checksum-verified gitleaks step.
- [ ] **M3 — the phase table and docs tell the truth.** `factory-phases.tsv` names `check-launch.sh` for phase 6; the doctrine says which phases stay ungated; roadmap + queue + CHANGELOG updated.

### M1 — the launch gate (fills phase 6)

**Ships:** `scripts/check-launch.sh` — a ship-phase change must carry launch evidence: a recorded
rollback line and a recorded post-deploy/launch record, in the plan folder or a named doc. Refuses a
ship milestone ticked with no such record; `LAUNCH_OFF=1` escape hatch; "what this gate cannot do"
header, presence-only.

**Proven by:** `scripts/check-launch.test.sh` — mutation-tested, mirroring `check-wireframe.test.sh`:
passes a ship change with a launch record, refuses one without, refuses an empty `--since`, and goes red
under a mutation of the gate (the canary proves it *detects*, not merely runs).

### M2 — the secret scan, turned on in the kit's own CI template

**Ships:** `scripts/templates/ci-verify.yml` and this repo's `.github/workflows/verify.yml` carry an
**enabled** secret-scan step (pinned, checksum-verified binary — the frame-forge pattern), replacing the
commented-out `gitleaks-action` line.

**Proven by:** both files no longer contain a commented-out scan; the step is active; documented in the
CHANGELOG and the rule that references it.

### M3 — the phase table and docs tell the truth about what is now gated

**Ships:** `scripts/factory-phases.tsv` phase 6 gate column `-` → `scripts/check-launch.sh`;
`factory-phases.md` re-worded so "phases 4–6 have no gate" becomes "phase 4 has no gate; 5 is reported
by the detector, 6 is gated by check-launch.sh"; `docs/agents/roadmap.md` gains the initiative;
`docs/agents/in-progress.md` row; CHANGELOG entry.

**Proven by:** `factory-phases.tsv`'s gate column for id 6 names an existing script; `check-docs.sh`
green; the plan's completion recorded.

## Wireframe

`n/a — no user-facing surface.` This is a shell toolchain consumed by the operator and by agents; there
is no screen to design. Recorded here rather than skipped silently.

## Spec coverage

| Requirement | Milestone |
|---|---|
| FR-001 | M1 |
| FR-002 | M1 |
| FR-003 | M2 |
| FR-004 | M3 |

## Build notes

_(appended as milestones land)_
