# Spec: <feature name>

- **Area:** `<area>`  ·  **Started:** YYYY-MM-DD  ·  **Status:** Draft
- **Owner:** <who is driving this>
- **Plan:** `plan.md` in this folder — written only AFTER every `[NEEDS CLARIFICATION: …]` below is
  resolved. _(The spec says what and why; the plan says how.)_

## Goal

One paragraph, in plain language, in terms of what a user or caller can DO after this ships that they
cannot do now. No implementation, no technology, no file names. If this cannot be written without
naming a technology, the requirement is not yet understood — that is a `[NEEDS CLARIFICATION: …]`.

## User stories

Each story is an independently testable slice: implementing only P1 must still leave a viable
increment that delivers value on its own. Order by importance, highest first.

> The `Independent test` line is the point of the whole rung. A story whose only test is "the whole
> feature works" is not a story, it is the feature restated — split it or say what single check proves
> it alone.

### US-1 — <brief title> (P1)

<The journey, in plain language: who is doing what, and what they get.>

- **Why this priority:** <the value, and why it outranks the others>
- **Independent test:** <the single check that proves THIS story works with nothing else built>
- **Acceptance scenarios:**
  1. **Given** <initial state>, **when** <action>, **then** <expected outcome>.
  2. **Given** <initial state>, **when** <action>, **then** <expected outcome>.

### US-2 — <brief title> (P2)

<The journey.>

- **Why this priority:** <...>
- **Independent test:** <...>
- **Acceptance scenarios:**
  1. **Given** <initial state>, **when** <action>, **then** <expected outcome>.

## Edge cases

- What happens when <boundary condition>?
- How does the system handle <failure or error scenario>?
- What happens when <the same action arrives twice / out of order / with no permission>?

## Requirements

Numbered, `MUST`-phrased, each one testable. Requirements state behavior, never implementation.

- **FR-001**: The system MUST <specific capability>.
- **FR-002**: A user MUST be able to <key interaction>.
- **FR-003**: The system MUST <data or persistence requirement>.
- **FR-004**: The system MUST <error, permission, or logging behavior>.

**Unclear requirement? Write the marker, not a guess.** A requirement may carry
`[NEEDS CLARIFICATION: <the exact question>]` while the spec is a draft — and this is the ONLY legal
place for one. The marker is a debt: it must be answered (or the requirement deleted) before `plan.md`
is written, because the plan is where implementation begins and an ambiguity that reaches it becomes a
guess that nobody reviews. Never resolve a marker by inventing an answer.

- **FR-005**: The system MUST <capability whose detail is unknown> — `[NEEDS CLARIFICATION: <the
  question, and the options you think exist>]`.

## Key entities *(only if the feature involves data)*

Name what the data represents and how the parts relate — no tables, columns, types, or technology.

- **<Entity>** — what it represents, and its relationship to the others.

## Success criteria

Measurable, technology-agnostic, and stated as an outcome rather than a build step. If a number is not
available, that is a `[NEEDS CLARIFICATION: …]` — never an adjective.

- **SC-001**: <Measurable outcome, e.g. "a caller can complete <task> in under <N> minutes">.
- **SC-002**: <Measurable outcome, e.g. "the operation completes in under <N> ms at <scale>">.
- **SC-003**: <Measurable outcome with a baseline to compare against>.

## Assumptions

Defaults taken where the description was silent, so a reviewer can challenge them. Each one is a
decision someone could reasonably have made differently.

- [Assumption about scope, e.g. "existing authentication is reused unchanged"].
- [Assumption about the environment or data that the feature relies on].

## Open questions

Every unresolved `[NEEDS CLARIFICATION: …]` above, gathered here as a checklist so nothing is missed
before planning. Delete each row as it is answered, and record the answer in the section it belongs to.

- [ ] <the question> — blocks planning until answered.

## On resolve

Delete this section's blocking rows, set **Status:** Resolved, then write `plan.md` in this folder and
link it from the row in `docs/agents/roadmap.md` — in the same change, per the plan-spine contract.
