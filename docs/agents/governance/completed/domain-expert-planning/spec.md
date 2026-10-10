# Spec: Domain expertise and design in the plan

- **Area:** `governance`  ·  **Started:** 2026-10-03  ·  **Status:** Resolved
- **Owner:** the owner (reported the gap, made the delete-and-reconcile decision)
- **Plan:** `plan.md` in this folder — written only AFTER every `[NEEDS CLARIFICATION: …]` below is
  resolved. _(The spec says what and why; the plan says how.)_

## Goal

A contributor planning any structural change is prompted, by the template they must copy, to name the
industry or domain the software serves and to record which outside practitioners were consulted and what
they said — so a film-production app is planned with a filmmaker's input and a restaurant app with a
restaurateur's. The design/UI/UX persona files stop being dead weight: the two whose output is a
planning input are invoked at spec time, and the rest are gone rather than sitting unused.

## User stories

### US-1 — The spec asks who outside software was consulted (P1)

A contributor starting a structural change copies `docs/agents/_templates/spec.md` to draft their spec.
The template carries a `## Domain & outside experts` section with placeholders for the domain and each
consulted expert's role and input, so leaving it unconsidered requires actively deleting a section
rather than never seeing one.

- **Why this priority:** This is the whole requirement. Without it the gap persists exactly as
  described — plans carry software-role input only.
- **Independent test:** open the shipped `docs/agents/_templates/spec.md`; confirm the section exists
  and its cells are placeholders (`{{DOMAIN}}`, `<expert role>`, `<what they said>`) and not fabricated
  example content.
- **Acceptance scenarios:**
  1. **Given** the shipped spec template, **when** a contributor copies it, **then** the copy carries a
     `## Domain & outside experts` section whose first cell names the domain via a placeholder.
  2. **Given** a structural change whose spec omits that section, **when** it is reviewed, **then**
     `.agents/rules/spec.md` and `workflow.md` name the omission as the defect and the section as the
     remedy.

### US-2 — A persona file nothing invokes does not survive (P2)

Anyone reading `.agents/personas/` after this change finds only files that some rule invokes, each with
its invocation named, and the README stating the contract.

- **Why this priority:** The owner's second decision. A library of uninvoked files is the dead weight
  the Algorithm pass exists to remove; leaving it is the cheaper path this spec forbids.
- **Independent test:** list `.agents/personas/*.md`; every file either is `README.md` or is named as an
  invoked consultation in `spec.md`/`workflow.md`.
- **Acceptance scenarios:**
  1. **Given** the personas directory, **when** it is listed, **then** it holds only `README.md`,
     `ux-designer.md`, and `ux-researcher.md`.
  2. **Given** the two kept personas, **when** a maintainer asks how each is invoked, **then**
     `spec.md` names the spec section and `workflow.md` names the planning step that invoke it.

### US-3 — workflow.md's persona list maps to real files (P2)

A reader of `.agents/rules/workflow.md` who follows its persona names finds either a real file or an
honest statement that the name is a review dimension, not a persona.

- **Why this priority:** The unreconciled list is the defect that let 13 files sit uninvoked — it named
  four lens-words as if they were files.
- **Independent test:** read the Expert Review section; the "four default personas" claim is corrected
  so every named file exists, and the UX planning consultation is stated.
- **Acceptance scenarios:**
  1. **Given** `workflow.md` → Expert Review, **when** a persona name is listed, **then** it is either a
     file that exists under `.agents/personas/` or explicitly labeled a review dimension.
  2. **Given** `workflow.md` → Planning Workflow, **when** design is discussed, **then** it states that
     UI/UX consultation is a **planning** input (per the spec section), not only a review step.

## Wireframe

Wireframe: n/a — no user-facing surface. The deliverable is a rule module and a spec template; the
closest thing to an interface is the `## Domain & outside experts` section a later spec fills in, and
that is prose, not a screen with a flow or a form to decide.

## Edge cases

- A change with **no user interface** (a library, CLI, service) — the spec's UX row is written
  "n/a — no user-facing surface", not deleted silently; the domain row still applies.
- A change whose domain expertise is **genuinely absent** (a pure internal refactor) — the spec states
  "no external expert consulted, because <reason>", which is the argued-empty form the Algorithm pass
  already requires for deletion lists, rather than a blank.
- A contributor **reaches for a deleted persona name** — the rule modules it maps to are the remedy;
  the plan's deletion table names the mapping so the lookup is one hop, not a lost file.

## Requirements

- **FR-001**: `docs/agents/_templates/spec.md` MUST carry a `## Domain & outside experts` section.
- **FR-002**: That section MUST name the industry/domain via a placeholder and MUST have one row per
  consulted expert carrying the expert role and what they said — placeholders only, never fabricated
  example content.
- **FR-003**: `.agents/rules/spec.md` MUST state that naming the domain and recording outside-expert
  consultation is an obligation of the spec rung, and MUST state honestly that whether an expert is
  real is unjudgeable and stays a review question.
- **FR-004**: `.agents/rules/workflow.md` MUST NOT name a "default persona" that maps to no file; its
  Expert Review bullet MUST distinguish review dimensions from persona files that exist.
- **FR-005**: `.agents/rules/workflow.md` MUST state that UI/UX consultation is a planning input.
- **FR-006**: `.agents/personas/` MUST contain only files some rule invokes; `README.md` MUST name each
  kept file's invocation.
- **FR-007**: No fabricated expert name, quote, or finding MUST appear in any template or rule module
  (placeholders only).

## Success criteria

Measurable, technology-agnostic.

- **SC-001**: `.agents/personas/` holds 3 files (README + 2 wired personas), down from 13 (12 personas +
  README) — a counted number, verifiable with `ls | wc -l`.
- **SC-002**: The spec template's expert section uses placeholders only; a grep for quoted example
  attributions returns zero hits.
- **SC-003**: `sh scripts/sync-agents.sh --check` exits 0 (mirrors reflect the rule edits), and the
  kit's own gate suite stays green — the change adds no gate and breaks none.

## Assumptions

- A default carried from the owner's explicit decision: delete the dead personas **and** make design part
  of planning, rather than one or the other.
- The kit stays provider-neutral: a persona is a subagent prompt a harness *may* spawn, so "invoked"
  means "named as a required consultation by a rule", not "executed by a specific runtime".
- `.agents/rules/design-system.md` is sufficient as the design-system authority; the deleted
  `ui-designer.md` restated it.

## Open questions

None outstanding — every marker resolved before the plan was written.

## On resolve

Status is **Resolved**; `plan.md` exists in this folder and is linked from the row in
`docs/agents/in-progress.md` — in the same change, per the plan-spine contract.
