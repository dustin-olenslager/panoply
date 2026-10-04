# Spec: The Panoply Software Factory

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** Draft
- **Owner:** the owner
- **Plan:** `plan.md` in this folder — written only AFTER every `[NEEDS CLARIFICATION: …]` below is
  resolved. _(The spec says what and why; the plan says how.)_

## Goal

One repository that carries the whole method for building software — from "here is an idea" to "this
shipped and here is the proof" — and that can pick up at whatever point an existing project is already
at. Today that method is split across two repos (`panoply`: the rules, gates and templates;
`a pilot repo`: a pipeline harness) plus one archived orchestrator (`kapsel`), so a fix lands twice
or lands in only one of them and the two drift. This spec consolidates them into one factory whose
phases are enforced by the kit's own gates, and adds the two rungs the process has never had: a
**wireframe** rung and the **seam between spec and plan**.

The organising idea: **a repo's phase is derived from evidence on disk, and each phase has exactly one
artifact, one gate, and one next step.** Nothing is asked of the operator that the evidence cannot
answer, and nothing is claimed as verified that a gate cannot see.

## User stories

### US-1 — Pick up wherever the work actually is

As the operator, I can point the factory at any repo and be told which phase it is in and what the
next step is, so that I never have to remember where I left off or explain the project's history.

- **Independent test:** run the phase detection against three repos in genuinely different states
  (a greenfield idea, a repo mid-build, a shipped repo) and get three different, correct answers with
  the evidence each conclusion was drawn from.
- **Acceptance scenarios:**
  1. **Given** a repo with no spec and no spine, **when** detection runs, **then** it reports Phase 0
     (adopt/audit) and names the doctor's exit code as its evidence.
  2. **Given** a repo whose spec is green but which has a user-facing surface and no wireframe,
     **when** detection runs, **then** it reports the wireframe phase, not the plan phase.
  3. **Given** a repo whose plan is complete and whose code is verified, **when** detection runs,
     **then** it reports the verify or ship phase — never "start at the spec".

### US-2 — Know the plan covers the spec

As the owner, I can see that every requirement in a spec is covered by a milestone in its plan, so
that a plan cannot quietly omit something the spec promised.

- **Independent test:** take a spec with three requirements and a plan covering two; the coverage
  check refuses it and names the uncovered requirement.
- **Acceptance scenarios:**
  1. **Given** a plan whose milestones cite the spec's `FR-NNN` identifiers and which cites all of
     them, **when** the coverage check runs, **then** it passes.
  2. **Given** a plan that omits one requirement, **when** the check runs, **then** it exits non-zero,
     names the uncovered `FR-NNN`, and says how to fix it.

### US-3 — Design against something clickable before building the backend

As the owner, I can have a clickable wireframe produced and interviewed **before** any backend work,
so that wrong screen shapes are found while they are still cheap to change.

- **Independent test:** produce a wireframe from a spec's user stories, run the simulated interviews
  against it, and show at least one finding that changed a decision recorded in the spec.
- **Acceptance scenarios:**
  1. **Given** a spec with a user-facing surface and no wireframe, **when** the wireframe phase runs,
     **then** a framework-free wireframe exists at the feature's own path and the factory reports it.
  2. **Given** a wireframe and four simulated personas, **when** the interviews run, **then** each
     finding is recorded in the spec's interview table with the decision it changed.
  3. **Given** a change with no user-facing surface (a migration, a cron job, a shell gate), **when**
     the wireframe phase is reached, **then** it records `n/a — <reason>` and proceeds without it.

### US-4 — One place for the method

As the owner, I can keep `panoply` and stop maintaining a second repo whose contents overlap it, so
that a rule change is made once, proven once, and adopted everywhere.

- **Independent test:** every capability the archived repo provided is either present in the factory
  or has a written reason for being dropped.
- **Acceptance scenarios:**
  1. **Given** the consolidated factory, **when** a gate or rule changes, **then** no second repo
     needs the same edit.
  2. **Given** the archived repo's capability list, **when** it is audited, **then** each row is
     marked *folded in*, *dropped with a reason*, or *deliberately not built*, with no row unaccounted.

### US-5 — Trust the phases without being told what to run

As the operator, I can let the factory proceed unattended and still know exactly what it did and why,
so that full auto never means silent changes.

- **Independent test:** run the factory on a repo with no operator input and show that every action it
  took was reported, and that it stopped before anything irreversible.
- **Acceptance scenarios:**
  1. **Given** a repo needing adoption, **when** the factory runs unattended, **then** it reports each
     action and each observation that led to it.
  2. **Given** a change that would merge, deploy, drop data, or rewrite history, **when** the factory
     reaches it, **then** it stops and asks.

## Edge cases

- **A repo with no kit at all** — must land in Phase 0 (adopt/audit), and adopting is the first batch
  of work rather than a precondition that blocks everything.
- **A repo whose kit stamp lies or is absent** — the doctor's own generation check (exit 15) decides;
  a stamp the factory cannot verify is never treated as proof of the repo's state.
- **A repo mid-refactor with a partly-complete plan** — the detection must name the phase from the
  artifacts present, not refuse because the history is untidy.
- **A monorepo** — phases are per-package, since one package can be shipped while another is still in
  the spec phase.
- **A spec written after its code** (the brownfield case) — legitimate, but must be recorded as a
  backfill with the code it describes, so it is not mistaken for spec-first work.
- **The factory itself** — building the factory is the first thing it must be able to describe, and
  its own build must run through its own phases.
- **A spec whose success criterion goes stale** — a measure that a gate can observe must be
  re-observable; a criterion that was true once and is not now must be detectable as false.

## Requirements

- **FR-001**: The factory MUST be one repository. The capabilities of the archived harness MUST be
  either folded in, or dropped with a written reason.
- **FR-002**: The factory MUST derive a repository's phase from evidence on disk (files, the kit
  doctor's exit code, git state), with no network call and no model call, and MUST report the evidence
  behind the conclusion.
- **FR-003**: The phase model MUST name, for each phase, its entry signal, its artifact, its gate, and
  its next step.
- **FR-004**: The planning rung MUST require that each plan milestone cite the spec requirement it
  satisfies.
- **FR-005**: A coverage check MUST refuse a plan that leaves any spec requirement uncovered, and MUST
  name the uncovered requirement and the remedy.
- **FR-006**: The spec rung MUST place wireframe design and its interviews BEFORE backend work for any
  change with a user-facing surface. The sequence is: expert input → persona interviews → wireframe →
  interviews against the wireframe → backend.
- **FR-007**: A wireframe MUST be a framework-free, in-tree artifact, reviewable as a diff, at a path
  fixed by the kit — not a hosted third-party tool.
- **FR-008**: Simulated interviews MUST be labelled simulated wherever they are recorded, and MUST
  never be presented as testimony from a real person. A real interview supersedes the simulation and
  is named.
- **FR-009**: Each recorded interview finding MUST name the decision it changed. A finding that
  changed nothing MUST be recorded as such rather than dropped silently.
- **FR-010**: A change with no user-facing surface MUST be able to record `n/a — <reason>` and proceed
  without the wireframe rung, and the reason MUST be required, not optional.
- **FR-011**: The factory MUST operate unattended and MUST report every action it takes and the
  observation that prompted it.
- **FR-012**: The factory MUST stop and ask the owner before anything irreversible — merging,
  deploying, destructive data changes, rewriting published history — and before a decision that is
  genuinely the owner's.
- **FR-013**: Every gate the factory adds MUST have a canary that goes red when the gate is broken, and
  MUST declare an escape hatch that actually works.
- **FR-014**: Every gate and rule MUST state what it cannot see, in the artifact the reader sees.
- **FR-015**: The factory's own construction MUST run through the factory's own phases, and its
  artifacts MUST satisfy its own gates.
- **FR-016**: Before an SME or an agent commits to a design default, it MUST surface the questions whose
  answers would change that design — with the options, the trade-off, and the default it will proceed
  on. The questions MUST reach the owner as one batch of tappable choices, never as prose buried in a
  report or a log. Where the owner has not answered, the recorded default is what ships, and the relay
  MUST say so.
- **FR-017**: A question MUST be owner-level to be asked — a decision that is his to make, or a fact
  only he holds. A question the agent can answer from the artifacts, or that the brief already
  settled, MUST be decided by the agent and not escalated.

## Key entities

- **Phase** — a stage of the method, with one artifact, one gate, one next step.
- **Artifact** — what a phase produces (`spec.md`, `wireframe/index.html`, `plan.md`, a verified
  change), located by a fixed path contract.
- **Requirement (`FR-NNN`)** — a promise in a spec, coverable by a plan milestone.
- **Milestone** — a unit of plan work, citing the requirement(s) it satisfies.
- **Finding** — what an interview surfaced, with the decision it changed.
- **Observation (`O1…On`)** — a fact read from disk that the detection rule reasons over.

## Success criteria

- **SC-001**: Phase detection returns the correct phase, with its evidence, for each of the states
  named in US-1 — greenfield, mid-build, shipped — and each detection is reproducible from disk alone.
- **SC-002**: The coverage check refuses a plan with an uncovered requirement and passes a fully
  covered one; both directions are proven by a canary that goes red under mutation.
- **SC-003**: A wireframe can be produced from a spec's user stories, and at least one simulated
  interview finding is recorded against it with the decision it changed.
- **SC-004**: Every capability of the archived harness appears in an accounting table as *folded in*,
  *dropped with a reason*, or *not built* — with no row missing.
- **SC-005**: Every new gate's canary passes, and each gate's canary goes red when the gate's check is
  disabled.
- **SC-006**: The stale success criterion found in this repo during the audit
  (`docs/agents/governance/completed/spec-before-plan/spec.md:98` promises the canary reports
  *12 passed*; it reports *21*) is either corrected or is caught by a check that can see it.

## Assumptions

- The kit's existing spine (roadmap → queue → area plan → sibling spec → worklog) stays; this spec adds
  rungs and a detection layer rather than replacing the spine.
- The factory stays pure POSIX shell with no runtime dependency. The archived harness's JavaScript
  core is a *behaviour* source, not code to port.
- One operator. There is no design team and no recruiting budget, so any method requiring real users
  on demand cannot be the default.
- The kit's existing gates and their canaries keep passing throughout.

## Domain & outside experts

`n/a — no user-facing product surface.` This is internal developer tooling consumed by the operator
and by agents; there is no screen an end user looks at, so there are no product users to consult. The
practitioners whose input IS load-bearing have been consulted and are recorded here:

| Question | Answer |
|---|---|
| The industry/domain this is built for | software delivery itself — the factory is tooling for building software, so the practitioners are engineers and the working method is the domain |
| Expert role consulted | three independent specialists, run as a debate rather than a single opinion: (1) a software-factory architect asked to design the phase model and argue against consolidation if warranted; (2) a planning auditor asked to test the owner's hypothesis that planning is the weak link against evidence in this repo's own history; (3) a UX/design-research lead asked to design the wireframe mechanism and argue where the owner's framing should change |
| What that expert said, in their terms | The architect: the deletion is the deliverable, not the port; do **not** carry a Node runtime into a zero-dependency shell kit, keep the phase model as data and doctrine. The auditor: the owner's hypothesis is **confirmed but narrowed** — spec and plan are individually good, the failure is at the seams; nothing connects them; the highest-leverage fix is requirement-level coverage. The UX lead: "functional" must mean clickable, not wired, or the wireframe becomes a half-built front end; the interviews' central risk is the generator grading its own homework, which needs a structural control |
| Effect on a requirement or story | Architect → FR-001, FR-003, and the shell-only assumption. Auditor → FR-004, FR-005, US-2, and SC-006 (the stale criterion it found). UX lead → FR-006…FR-010, US-3, and the anti-theatre requirement in FR-009 |

Each of the three was given the real artifacts (both repos, this repo's own governance history, and
published spec-kit documentation) and was explicitly told to judge rather than comply, and to disagree
where the owner's framing was wrong. Each did disagree with at least one part of the framing, and
those disagreements are carried into the requirements above rather than smoothed away.

## User interviews (simulated, 4 personas)

**Simulated role-plays, and this section says so deliberately.** The personas below have no
user-facing surface to interview: the factory's "users" are the operator and the agents. What follows
is a simulation of the two audiences the factory actually has, labelled as simulation, recorded
because the findings changed decisions. It is **not** testimony from real people, and nothing here is
quoted as if it were.

| # | Persona (role, in this domain's terms) | What they were asked | What they said (SIMULATED) | Design / functional decision it changed |
|---|---|---|---|---|
| 1 | The operator working alone, unattended most of the day | What do you need when you come back to a repo you have not touched in a week? | "Tell me what state it is in and what the next action is, and do not make me re-read the history to find out. If you changed something while I was away, tell me every change and why." | FR-002 (phase from evidence + report the evidence), FR-011 (report every action). This is why detection is evidence-based and explainable rather than a confident label. |
| 2 | An agent picking up a cold repo | What stops you starting work? | "Not knowing whether the thing you are asking for is already half-built, and not being trusted to guess. Give me one artifact to read and one gate to satisfy." | FR-003 (one artifact, one gate, one next step per phase). Keeps every phase's entry contract readable without the whole history. |
| 3 | The reviewer reading a plan cold | What would make you distrust this plan? | "If I cannot tell which promise in the spec it is serving. I have seen a plan look thorough while quietly covering two thirds of the requirements." | FR-004, FR-005, US-2 — the coverage requirement, and the reason it is a checked gate rather than a review note. |
| 4 | The operator as the last line of defence | What must never happen unattended? | "Do not merge, deploy, drop data, or rewrite history without me. And do not tell me something is done when a check only saw that it exists." | FR-012 (human gate on the irreversible), FR-014 (state what a check cannot see). This persona is what keeps full auto bounded. |

## Open questions

- [ ] Which existing adopters migrate to the factory, and when? — blocks nothing in the build, but
  blocks the rollout; the owner's standing rule is one repo at a time, as we work on them.

## On resolve

Delete this section's blocking rows, set **Status:** Resolved, then write `plan.md` in this folder and
link it from the roadmap row — in the same change.
