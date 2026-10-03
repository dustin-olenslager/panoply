# Plan: Spec artifacts — a spec you must actually write before a plan

- **Area:** `governance`  ·  **Started:** 2026-10-03  ·  **Status:** In progress
- **Owner:** the owner (requested the capability; chose kit-native gates) / Hermes (drafting)
- **Next step:** open exactly ONE PR on `feat/spec-artifacts` carrying M1–M3, run the local gate
  suite first (`sync-agents.sh --check`, `check-docs.sh`, `check-plan-home.sh`, `check-algorithm.sh`,
  `check-spec.test.sh`, `panoply.test.sh`), then record the merged SHA for M4 (the Hermes skill).
- **Roadmap initiative:** Spec artifacts — the *what and why* becomes a checked artifact again.

## Goal

After this ships, a repo carrying the kit cannot land a **structural** change whose plan doc has no
spec behind it, and cannot carry an **unresolved ambiguity** from a spec into a plan.

A spec is a small document at `docs/agents/<area>/<feature>/spec.md` — a sibling of `plan.md`, in the
same folder — carrying:

- **User stories**, each with a priority (P1…), written as a user journey, and each explicitly
  **independently testable** (an implementation of P1 alone is a viable increment).
- **Acceptance scenarios** per story in **Given / When / Then** form.
- **Functional requirements**, numbered `FR-NNN`, each `MUST`-phrased.
- **An ambiguity marker** — `[NEEDS CLARIFICATION: <the question>]` — that is legal anywhere at spec
  time and **must not survive into a plan**.

How we know it worked: the gate refuses a structural change with no spec (proven), refuses one whose
spec still carries an unresolved marker (proven), passes a compliant spec (proven), and the
refusal→remedy→allow round trip closes inside one session (proven). All four directions are asserted
by `scripts/check-spec.test.sh` in required CI, and the refusal names the remedy.

**Out of scope:** a project constitution (Phalanx already owns governance; `AGENTS.md` +
`.agents/rules/` is this kit's constitution), a `specs/NNN-slug` numbering scheme and its own directory
tree, a task list artifact (the queue already is one), the `/speckit-*` command names, any hosted
service, and any change to how the queue or roadmap work.

## Context

The kit has a strong **plan** spine and no **spec** rung. `docs/agents/_templates/plan.md` opens at
`## Goal` and `## Context` and then goes straight to Architecture, the Algorithm pass, and milestones.
Nothing in the chain asks *what a user can do after this ships* or *how we will know it worked*, in a
form something checks. The consequence is measurable in this repo's own artifacts: three plans under
`docs/agents/governance/` name architecture, layers, and milestones, and none carries a prioritized
story or an acceptance scenario. Requirements exist only as prose inside `## Goal`.

Two things the plan rung does well and the spec rung must not duplicate: `plan.md` already owns
milestones and the Algorithm pass, and `docs/agents/in-progress.d/<slug>.md` already owns the task
queue. A spec that needs a task list, or a plan that restates stories, would be redundancy — the exact
thing the Algorithm pass exists to remove.

Source of the shape: `github/spec-kit` (MIT) — `templates/spec-template.md` for the story/priority/
acceptance structure and the `NEEDS CLARIFICATION` convention; `templates/commands/clarify.md` and
`converge.md` for the ambiguity gate and the convergent loop. Its carrier (a `specify` CLI, a `specs/`
tree, per-agent integration modules, a preset/bundle/extension system) is not adopted — see the
Deletion candidates table.

## Architecture

- **Layers touched:** none in the Clean-Architecture sense. This is shell scripts plus markdown, as the
  Algorithm's kit half was: no source, no ports, no dependency-direction change.
- **New ports (interfaces):** none.
- **Boundary data:** none.
- **Dependency direction:** unchanged. `check-spec.sh` reads the working tree and the git index only.
- **Swap test:** n/a — no vendor or framework involved.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

Run in order, before the milestones.

- **Question** — *Who asked?* the owner, 2026-10-03, in this session, routing off `github/spec-kit`; he
  chose kit-native gates over a Hermes-only skill when asked. *Which constraint does it serve?* Two
  named ones: (a) the kit's own premise that a rule which is not mechanically checked drifts — so a
  spec step shipped as advice would be the failure mode the kit exists to prevent; (b) the lock that a
  repo carrying the kit is bound by its gates, so the capability has to live in the kit to bind every
  repo and every tool. No other requester; no requirement arrived without a name.
- **Delete** — see the table below. The largest deletion is the **whole carrier**: Spec Kit's CLI,
  `specs/` tree, integrations, and preset/extension system are replaced by ~90 lines of POSIX sh and
  two markdown files, because this kit's binding plane is already required CI.
- **Simplify** — the least shape that satisfies the named requirement: **one template, one rule module,
  one gate, one canary.** The spec lives beside the plan it belongs to (`<area>/<feature>/spec.md`)
  rather than in a new tree, because `check-plan-home.sh` and `check-algorithm.sh` already glob
  `docs/agents/*/*/` and a new tree would need new allowances in both.
- **Accelerate** — the measured number: today, confirming that a planned change has defined acceptance
  criteria takes a full read of the plan doc and a judgement call (unbudgeted, per change, and it is
  skipped under time pressure). After this, it is one gate run — the same ~2 s the Algorithm gate takes
  on the same glob — with a boolean verdict, and the ambiguity list is machine-enumerable rather than
  something a reviewer must notice. Bottleneck named: **reviewer attention at plan time**, not CI
  runtime; the gate is not on the slow path.
- **Automate** — last, and only what survived 1–3: the *presence and resolution* checks. The parts that
  did not survive are enumerated below and are not automated, because they are judgement (is this story
  really independently testable? is this requirement worth its cost?) and the gate says so in its own
  honest-limits header, the same way `check-algorithm.sh` does.

### Deletion candidates

**Required section — the list is the artifact, because deletion leaves no trace.** Each row names what
was considered and what happened to it.

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| The whole request (i.e. "the plan template is good enough") | rejected | The gap is real and evidenced: three governance plans, zero acceptance scenarios, and nothing checks. Working is the floor, not a reason to keep a rung missing. | Build the spec rung, kit-native. |
| Spec Kit's **carrier** — `specify` CLI, `uv tool install`, Python integration modules | yes | Duplicates what the kit already is. `panoply.sh` + `sync-agents.sh` already stamp and generate every tool's surface; a second installer would be a second source of truth for the same job. | `scripts/check-spec.sh` (POSIX sh) + the existing `sync-agents.sh` mirror pass. |
| Spec Kit's **`specs/NNN-slug/` tree** and its automatic feature numbering | yes | A second plan-shaped directory. `check-plan-home.sh` permits exactly `docs/agents/<area>/<feature>/plan.md` and globs two other gates on the same shape; a new tree is three new allowances to maintain. Numbering also implies an ordering this library does not need. | The spec is a **sibling** of the plan: `docs/agents/<area>/<feature>/spec.md`. |
| Spec Kit's **constitution** (`.specify/memory/constitution.md`, versioned, ratified, amended) | yes | This kit already has governance: `AGENTS.md` + `.agents/rules/*.md`, generated into every tool's native file by `sync-agents.sh`. A per-project constitution would be a second governance document that `sync-agents.sh` cannot see, so it would drift from the ruleset silently — and Phalanx's `core/domain` layer already owns the typed half. | `AGENTS.md` **is** the constitution. The spec rule module cites it. |
| Spec Kit's **`tasks.md`** (task list with `[P]` parallel markers and IDs) | yes | The queue already is the task list and the plan's milestones already decompose the work. A third artifact would restate `plan.md` at the same altitude — precisely the drift the "four altitudes, no overlap" contract forbids. | `plan.md` milestones + `docs/agents/in-progress.d/<slug>.md`. |
| Spec Kit's **`/speckit-*` command names** and per-agent command files | yes | Agent-specific naming defeats the kit's agent-agnostic premise, and `sync-agents.sh` already generates every mirror from one source. | The rule module and the gate; the Hermes skill carries the walkthrough on the Hermes side. |
| Spec Kit's **presets / bundles / extensions** system with its own overlay resolver and catalog | yes (this batch) | Real capability, wrong order. Optimizing the customization layer before the artifact exists is automating a step that has not been justified yet. | Deferred and named as a *revisit* row in `roadmap.md` Later, not built now. |
| Spec Kit's **`research.md` / `data-model.md` / `contracts/` / `quickstart.md`** outputs | yes | Four files per feature, generated before anyone reads the spec. `Context`, `Architecture`, and the plan's own sections already carry this at the altitude the kit uses. | The plan doc's existing sections. |
| Spec Kit's **`converge`** loop as its own command | rejected (redundant) | The loop is real and the kit already runs it: implement → verify → the plan's milestone checkboxes → the queue. A converge *verb* adds a name, not a capability. | The existing batch loop (§5 verify gate in `dev-workflow`) plus milestone checkboxes. **Revisit if** a spec drifts from the code, which nothing currently detects — that is a different, later gate (spec↔code drift) and is named as a revisit row. |
| A **`check-spec.sh --since <base>` "changed spec must move"** rule | yes | Cycle-checking a spec against its own diff has no honest mechanical meaning at this size, and it would be a second rule asking one question of a tree — the trap `references/gate-integrity.md` already documents. | One gate, one question: *does a structural change have a resolved spec behind it?* |
| Making the gate **block writes to `docs/agents/**`** | yes | That is the deadlock this kit already hit once: a gate that refuses the write which *is* its own remedy is unsatisfiable. | `check-spec.sh` exempts `docs/**` and `*.md` exactly as `check-algorithm.sh` does, and the canary asserts the refuse→remedy→allow round trip. |

## Milestones

Each is independently reviewable and leaves the system working.

- [ ] **M1 — the artifact exists.** `docs/agents/_templates/spec.md` with the five sections (stories +
  priority + independent-test line; acceptance scenarios; numbered FRs; success criteria; open
  questions carrying `[NEEDS CLARIFICATION: …]`), and a `Spec:` link row added to
  `docs/agents/_templates/plan.md` so the plan names the spec it implements. Files:
  `docs/agents/_templates/spec.md` (new), `docs/agents/_templates/plan.md` (edited).
- [ ] **M2 — the rule exists.** `.agents/rules/spec.md`: what a spec is, the carry-forward rule
  (unresolved markers must not reach a plan), the routine-work exemption, the honest limits, and the
  `SPEC_OFF=1` escape hatch; plus one line in the `AGENTS.md` MIRROR preamble's read-order list and
  `workflow.md` → Planning Workflow pointing at it. Files: `.agents/rules/spec.md` (new), `AGENTS.md`
  (preamble line), `.agents/rules/workflow.md` (one pointer).
- [ ] **M3 — the gate exists and can go red in both directions.** `scripts/check-spec.sh` + canary
  `scripts/check-spec.test.sh` (cases: no spec at all → refused; spec with an unresolved marker →
  refused; compliant spec → pass; docs-only change → exempt; `SPEC_OFF=1` lifts; refuse→remedy→allow
  round trip; the gate does not mutate the repo). Wired into `scripts/templates/ci-verify.yml` (PR
  context) and `scripts/templates/pre-commit`; mirrors regenerated with `sh scripts/sync-agents.sh`.
- [ ] **M4 — the Hermes side walks it.** The `spec-driven-start` skill: one entry, intake → spec →
  clarify → plan → tasks, stopping at each artifact for the owner's yes/no, writing the same artifacts
  M1–M3 define. Records the kit's merged SHA so the two halves are pinned to each other.

**Ship:** fold each milestone row per the ship convention — `completed-features.md` entry, worklog
line, `roadmap.md` move to Shipped, and promote the "a gate must observe its own remedy" restatement
into `key-patterns.md` if the canary proves it again here.

## Open questions

- [ ] Does the spec rung belong on **new features only**, or on any structural change? The gate follows
  `check-algorithm.sh` and fires on any structural change, which makes it consistent but arguably heavy
  for a refactor. *Blocks M3.* — Answered by default: fire on any structural change, because a refactor
  that changes observable behavior needs the same acceptance criterion, and the `SPEC_OFF`/routine
  exemption already covers the light cases. Recorded here so a later session reads it as a decision,
  not an omission.

## Build notes

> **Build note:** 2026-10-03 — plan written from a live read of `github/spec-kit` at `main` (spec
> template, clarify/plan/tasks/converge commands, `spec-driven.md`) and of the kit at `d3f7495`.
> `check-algorithm.sh`'s `PLAN_GLOB` is exactly `docs/agents/*/*/plan.md`, so a plan anywhere else is
> invisible to the gate — this plan is at `docs/agents/governance/spec-artifacts/plan.md` deliberately.

## On ship

Move this folder to `governance/completed/`, add the `completed-features.md` entry, append the worklog
line, remove the queue row, and MOVE the roadmap initiative to Shipped — in the same commit as the
code.
