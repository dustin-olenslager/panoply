# Plan: Domain expertise and design in the plan

- **Area:** `governance`  ·  **Started:** 2026-10-03  ·  **Status:** In progress
- **Owner:** the owner (reported the gap, made the delete-and-reconcile decision) / Hermes (implementing)
- **Next step:** land this PR (`feat/planning-panel`). M1–M3 are done and gate-green; on merge, move
  this folder to `governance/completed/`, add the `completed-features.md` row, and delete the
  `in-progress.md` row.
- **Roadmap initiative:** Mechanical enforcement of the governance rules — but here the finding is
  that the missing thing is *doctrine and a template section*, not another gate (see the Algorithm pass
  and "Enforcement" below).
- **Spec:** `spec.md` in this folder — the what and why this plan implements.

## Goal

After this ships, the spec rung requires the plan to **name the industry/domain the software is built
for** and to **record which outside experts were consulted and what they said** — the filmmaker for a
film-production app, the restaurateur for a restaurant app — instead of carrying software-role input
only. The six design/UI/UX persona files that were dead weight (nothing invoked them) are either wired
into planning or deleted, and `.agents/rules/workflow.md`'s "four default personas" name real files
instead of four loose adjectives with no file behind them.

How we know it worked: `docs/agents/_templates/spec.md` carries a **Domain & outside experts** section
whose placeholders (`{{DOMAIN}}`, `<expert role>`, `<what they said>`) make the requirement the default
shape of every new spec; `spec.md` (doctrine) and `workflow.md` name it and name the real persona files
that satisfy it; and the persona directory contains only files some rule invokes (counted, in the PR).

**Out of scope:** a new gate (see the Algorithm pass — prose + template is the least shape; the honest
residue is unjudgeable either way); judging whether a named expert is real; a new document type (the
section lives in the spec, not a sibling file); changing the opt-in sign-off path in
`check-expert-review.sh`; and any persona whose job is already a rule module.

## Context

Two owner-verified problems, not one:

1. **The plan never brings in the industry the software is FOR.** The spec and plan templates ask for
   software roles only (architect, security). `.agents/rules/spec.md` line ~98 already references "an
   SME read" but nothing requires one, and no template gives it a home. A film-production app plans
   with no filmmaker; a restaurant app with no restaurateur.
2. **Six design/UI/UX persona files are never used in planning, and none of the 13 is invoked by
   anything.** `.agents/personas/` holds 13 persona files plus a README. They were carried in by the
   agent-agnostic refactor (#15) as subagent spawn-templates for one particular harness. No gate, no
   command, and no rule requires any of them. `.agents/rules/workflow.md` names "four default personas"
   (Security, Performance, Maintainability, UX) that **map to no file** — the list is four review
   *lenses* wearing the word "persona".

The two connect: making design part of *planning* is the way the dead design personas stop being dead —
their output becomes a spec input rather than a build-stage afterthought.

## Architecture

- **Layers touched:** none in the Clean-Architecture sense. Markdown rule modules, two templates, and
  the persona directory. No source, no ports, no dependency-direction change, no script change (this
  plan adds no gate — see Enforcement).
- **New ports (interfaces):** none.
- **Boundary data:** none.
- **Dependency direction:** n/a.
- **Swap test:** n/a.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — who asked, and which constraint does it serve? The repo owner (the owner), who verified
  both problems against the templates and named the decision: delete the dead personas **and** make
  design part of planning. It serves the kit's core promise — a plan is where a wrong shape is cheapest
  to catch, and a plan that never asked the industry's practitioners has not caught the expensive
  mistakes it exists to catch.
- **Delete** — what can be removed instead? The list below is the substance of this change: 10 of the
  13 persona files (12 personas + 1 README), a `.mdc` prune path that no longer has orphans to prune,
  and — the candidate that matters most — **the new gate this request would normally grow**. Deletion is
  the step this change is mostly made of.
- **Simplify** — the least shape that satisfies the named requirement is **one section in the spec
  template** (`## Domain & outside experts`) plus the doctrine sentence that makes it binding. Not a new
  document type, not a parallel `expert-panel.md`, not a new command. The section is four rows: the
  domain, the experts consulted, what each said, and the requirement it changed.
- **Accelerate** — no measured cycle-time claim is made, and none is owed: this change adds no
  running step and removes no running step from any pipeline. The persona count drops **12 → 2** (a
  measured, verifiable number); the spec rung gains a section writers fill once. Cycle time is not the
  constraint here — whether the industry was ever asked is — so no number is invented to fill the slot.
- **Automate** — nothing is automated. This is the deliberate conclusion, not an omission: see
  "Enforcement — the honest version" below. Automating a section-presence check here is exactly the
  step-5-before-step-2 mistake the doctrine names.

### Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| `backend-architect.md` | **yes** | Nothing invoked it; its job (server design, schema, APIs) is `.agents/rules/api-design.md` + `data-modeling.md` + `clean-architecture.md`. A spawn-template for one harness, not kit doctrine. | The rules modules already named. |
| `code-reviewer.md` | **yes** | Nothing invoked it; `workflow.md` → Expert Review already *requires* independent review, and the review dimensions (correctness/security/maintainability/performance) are checklists in the rule modules. | `workflow.md` Expert Review + the rule modules' review checklists. |
| `cto-review.md` | **yes** | Nothing invoked it; a long-horizon plan review is what `quality-bar.md` and the plan doc's Algorithm pass already demand. | `quality-bar.md` self-check + plan Algorithm pass. |
| `database-optimizer.md` | **yes** | Nothing invoked it; `.agents/rules/database.md` owns indexing, query plans, and migration safety. | `.agents/rules/database.md`. |
| `frontend-developer.md` | **yes** | Nothing invoked it; `.agents/rules/frontend.md` owns components, state, a11y, and UI performance. | `.agents/rules/frontend.md`. |
| `security-engineer.md` | **yes** | Nothing invoked it. Security review is a required dimension in `workflow.md` Expert Review; threat-modeling framing lives in the review checklist. | `workflow.md` Expert Review (Security dimension). |
| `software-architect.md` | **yes** | Nothing invoked it; domain modeling and pattern selection are `.agents/rules/clean-architecture.md` + `quality-bar.md`. | `clean-architecture.md` + `quality-bar.md`. |
| `ui-designer.md` | **yes** | Nothing invoked it, and its content (visual style axes, layout archetypes, component conventions, type/spacing scale) is **already** `.agents/rules/design-system.md`. Keeping it is a second copy of a rule — the drift the kit's "one fact, one home" forbids. | `.agents/rules/design-system.md`, now named as the design-system authority the spec's UX row cites. |
| `ui-reviewer.md` | **yes** | Nothing invoked it; pixel-level review is `design-system.md` → "Consistency check", run against any changed screen. | `design-system.md` Consistency check. |
| `ux-architect.md` | **yes** | Nothing invoked it; CSS architecture, layout systems, and theming are `design-system.md` + `frontend.md`. | `design-system.md` + `frontend.md`. |
| `ux-designer.md` | **no — kept and WIRED** | Planning needs it: flows, information architecture, and competitive research are **spec inputs** (P1 journeys, acceptance scenarios). Wired by the spec template's `## Domain & outside experts` section and `spec.md` doctrine, which name it as the planning consultation for UX. | Invoked at plan/spec time (see "How each kept persona is invoked"). |
| `ux-researcher.md` | **no — kept and WIRED** | Planning needs it: when a requirement rests on a user-behavior assumption, the evidence (or a study plan) is a spec input, not a post-build discovery. Wired by the same section and doctrine. | Invoked at plan/spec time (see "How each kept persona is invoked"). |
| `personas/README.md` | **no — rewritten** | The index must describe what actually exists after this change, or it becomes the next dead artifact. | Rewritten to the 2 kept personas + the "how it is invoked" contract. |
| **A new gate** (e.g. `check-domain-expertise.sh`) | **rejected** | The thing worth enforcing — *was the domain named and a real expert consulted* — is **not mechanically checkable**: a section-presence check passes on a fabricated expert and blocks no real mistake, while adding a second plan-section gate on top of `check-algorithm.sh` and `check-spec.sh`. That is automating an unjudgeable step, the exact step-5-before-step-2 error. | Doctrine + template. The residue stays a review question, stated honestly in `spec.md` and `workflow.md`. |
| **A sibling `expert-panel.md` artifact** | **rejected** | A second file per feature to hold three rows that belong in the spec; the spec is already the cheapest place for "we have not decided this yet". | The `## Domain & outside experts` section in `spec.md`. |
| **A new `domain-expert` persona file** | **rejected** | The experts are industry practitioners (a filmmaker, a restaurateur) — inherently per-project and unknowable at kit-authoring time, so a kit persona for them would be a fabricated role. | The spec section's `<expert role>` placeholder; the project names the real expert. |

## How each kept persona is invoked

A persona is kept only if a rule invokes it. The two kept files are invoked **at planning time**, by
the spec rung — this is the wiring that makes "design is part of planning" true rather than aspirational:

- `ux-designer` — `docs/agents/_templates/spec.md` → `## Domain & outside experts` requires the UX row
  to name it and record its flow/IA findings; `.agents/rules/spec.md` and `workflow.md` name it as the
  planning consultation whose output fills US-N acceptance scenarios.
- `ux-researcher` — same section, invoked when a requirement rests on a user-behavior assumption; the
  spec's `## Assumptions` and `[NEEDS CLARIFICATION: …]` are where its evidence-or-study-plan lands.

`design-system.md` remains the design-system **rule** the spec's design row cites; it is a rule module,
not a persona, and is untouched here.

## Milestones

- [x] **M1 — the spec rung carries the requirement.** Add `## Domain & outside experts` to
  `docs/agents/_templates/spec.md`; add the binding paragraph to `.agents/rules/spec.md`; regenerate
  mirrors.
- [x] **M2 — workflow.md reconciled.** Correct the "four default personas" bullet to name real files
  and the planning-time UX consultation; keep the review dimensions as dimensions.
- [x] **M3 — personas decided.** Delete the 11 dead files, keep and wire `ux-designer` /
  `ux-researcher`, rewrite `personas/README.md`; regenerate mirrors; update the shipped
  `AGENTS.md`-adjacent references if any name a deleted file.
- [x] **M4 — verify and ship.** Run `sync-agents.sh --check`, the full canary suite, `check-docs.sh`,
  `check-spec.sh`, `check-algorithm.sh`, plain `shellcheck`; update `CHANGELOG.md`; open the PR.

## Open questions

(none blocking — the owner's decision is the standing requirement per Algorithm step 1)

## Build notes

> **Build note:** 2026-10-03 — the `.agents/rules/workflow.md` "four default personas" bullet was the
> tell: it named four review *lenses* (Security, Performance, Maintainability, UX) that map to zero
> files, while 13 real files sat invoked by nothing. Reconciling that one bullet is what makes the
> persona decision legible — the lenses stay as review dimensions, and only files a rule invokes are
> kept.

> **Build note:** 2026-10-03 — `ui-designer.md` was the hardest delete call, because at 392 lines it
> *looks* like it earns its place. It does not: it restates `design-system.md` almost section-for-
> section, and two copies of a rule drift. The content was checked before deleting — nothing unique is
> lost, and the surviving rule is the one the design row cites.

## On ship

Move this folder into `governance/completed/`, rename `plan.md` to describe what shipped, add the
`completed-features.md` entry, append the `CHANGELOG` `[Unreleased]` line (already in this change),
remove the `in-progress.md` row, and move the roadmap initiative.
