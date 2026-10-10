# Spec: claims are evidence, and comments are not decoration

- **Area:** `governance`  ·  **Started:** 2026-10-10  ·  **Status:** Resolved
- **Owner:** Hermes (SME-drafted), the owner (approving)
- **Plan:** `plan.md` in this folder.

## Goal

A person building with Panoply can now be held to two things the kit did not previously say out loud:
that **no claim a reader sees is invented** (a statistic, a testimonial, a metric, a fake terminal
window, a capability the product does not ship), and that **a comment earns its place by saying why**
rather than by decorating the code with banners, emoji, narration, and end markers. The first arrives
as doctrine a reviewer can point at, because no script can detect an invented number. The second
arrives as doctrine **plus a gate**, because the shapes that carry no information are recognizable
machanically and a rule with no gate is the rung that never gets used.

## User stories

### US-1 — a change that decorates its comments is refused (P1)

An agent or a person adds a section banner, an emoji marker, a `// Step 1:` narration comment, or a
`} // end if` marker. The kit's new comment gate refuses the change and names the file, the line, and
the shape. The author deletes the decoration, keeps the comment that says why, and the change lands.

- **Why this priority:** it is the only half of this work a script can actually prove, and it is the
  half that accumulates silently in every diff. It also closes the kit's own worst habit: this repo's
  tree carries 177 banner comments written before the rule existed.
- **Independent test:** run `sh scripts/check-comments.sh --since <base>` on a branch whose added lines
  carry a banner → exit 1 naming it; delete the banner → exit 0. Nothing else built.
- **Acceptance scenarios:**
  1. **Given** a change whose added lines include `// ===== Authentication =====`, **when** the gate
     runs against that change, **then** it exits 1, names that file and line, and says which shape.
  2. **Given** a change whose added lines are honest comments, **when** the gate runs, **then** it
     exits 0 and prints how many comment lines it inspected.
  3. **Given** a change that adds no comments at all, **when** the gate runs, **then** it exits 0 and
     says distinctly that nothing was compared.

### US-2 — a claim on a shipped surface has something behind it (P2)

A landing page, an empty state, a pricing table, or a model-written summary asserts a number or a
capability. The reviewer, holding `claims.md`, asks "says who?" — and either a source is named or the
claim is deleted before the change ships. No gate is claimed for this, and the module says so.

- **Why this priority:** it is the failure the kit forbids everywhere else (a fabricated expert in a
  spec, Lorem Ipsum in a wireframe) reaching the one surface where a reader trusts it. It outranks
  every other content rule because an invented statistic is a false statement, not a style choice.
- **Independent test:** read a change's added user-visible strings and check each claim against a
  named source; the deliverable is the doctrine that makes the question askable, and its independent
  test is that the module is loaded from the generated index (`sh scripts/sync-agents.sh --check`
  green with `claims` listed) rather than the module's presence on disk.
- **Acceptance scenarios:**
  1. **Given** the kit is applied to a repo, **when** an agent reads `AGENTS.md`, **then** the rule
     index names `claims` and its one-line description, so the rule is reachable without being told
     it exists.
  2. **Given** a UI change whose copy is invented, **when** review runs, **then** the reviewer has a
     named rule to cite and a stated remedy (delete the claim, or name its source).

### US-3 — the operator can take a deliberate exception, openly (P3)

An operator migrating a repo with a large backlog of pre-existing banner comments does not want every
PR red for debt that predates the rule. They pass `COMMENTS_OFF=1`, or they fix the lines they touched,
and they say which they did.

- **Why this priority:** a gate with no escape hatch is a gate people route around with `--no-verify`,
  which makes the exception invisible instead of declared.
- **Independent test:** `COMMENTS_OFF=1 sh scripts/check-comments.sh --staged` on a staged banner →
  exit 0 and a line naming the hatch.
- **Acceptance scenarios:**
  1. **Given** a staged banner comment, **when** the gate runs with `COMMENTS_OFF=1`, **then** it
     exits 0 and prints that it was disabled by that variable.
  2. **Given** the same staged banner, **when** the gate runs without it, **then** it exits 1.

## Edge cases

- **A doc that quotes the shapes.** A rule module, a plan, or a changelog showing
  `// ===== Auth =====` is discussing the convention, not using it. Documentation files are not
  scanned, and the gate's own sources are excluded by path; the canary asserts both.
- **Typography is not emoji.** A curly apostrophe or an em dash in a comment stays legal; only the
  emoji byte ranges are flagged. Asserted in the canary, because "non-ASCII" would have been the lazy
  pattern and would have made the gate an ASCII-only lint.
- **A URL in a comment.** `https://…` must not read as a comment marker; the trailing-comment path is
  guarded against a scheme's `//`.
- **An all-caps TODO or acronym.** `// TODO …` and `// HTTP timeouts are 30s` are legitimate. An
  unknown single-token all-caps label is reported as a note that never fails the build.
- **A numbered list inside an explanatory comment.** Prose, not narration: the gate flags the
  `Step N` and ordinal-word forms only.
- **A repo whose base ref does not resolve.** The gate refuses (exit 2) rather than comparing nothing
  and reporting a pass.
- **Pre-existing debt.** The kit's own tree carries 177 banner comments. The gate grades only lines a
  change adds; `--tree` exists to measure history, and it is not a CI mode.

## Requirements

- **FR-001**: The kit MUST ship a rule module stating that any claim presented as fact is real and
  traceable to a source or is deleted, naming invented metrics, fake product decoration, fabricated
  social proof, unverifiable capability claims, drifting pricing claims, and unlabelled sample data.
- **FR-002**: That module MUST state that no mechanical gate detects an invented claim, and MUST name
  the review step that asks the question instead.
- **FR-003**: `.agents/rules/code-style.md` MUST carry a Comments section banning restating comments,
  decorative separators and banners, emoji, workflow narration, end markers, empty labels, and
  commented-out code, and MUST name the gate that enforces the mechanical half.
- **FR-004**: `scripts/check-comments.sh` MUST grade only the lines a change adds, defaulting to a
  change-scoped diff, with `--since REF` and `--staged` modes and an explicit `--tree` audit mode.
- **FR-005**: The gate MUST NOT scan documentation files, and MUST exclude its own sources by path, so
  prose that teaches the convention is never reported as a use of it.
- **FR-006**: The gate MUST report how many comment lines it inspected and MUST print a distinct
  message when it inspected none, without failing a change that legitimately adds no comments.
- **FR-007**: The gate MUST exit 2, never 0, when its diff base does not resolve or lacks an argument.
- **FR-008**: The gate MUST ship a canary that asserts both directions for every shape, plus the
  docs/metasyntax direction, the note bucket, the escape hatch, the zero-count message, the
  unresolvable-base refusal, and that a run never mutates the tree.
- **FR-009**: The gate MUST carry the declared escape hatch `COMMENTS_OFF=1`, and both the module and
  the gate's refusal text MUST name it.
- **FR-010**: The repo's CI workflow and the shipped adopter template MUST run the gate on pull
  requests with the PR base SHA, and the gate's canary MUST run in the workflow's self-tests job.
- **FR-011**: The new module MUST appear in the generated rule index (`AGENTS.md` and every mirror),
  with `scripts/sync-agents.sh --check` green.
- **FR-012**: The CHANGELOG `[Unreleased]` entry MUST state the class of change (MINOR: a new module
  and a new gate) and what an already-adapted repo must do about it.

## Success criteria

- **SC-001**: A change whose added lines carry any of the five banned shapes exits non-zero from the
  gate, naming the file and line; the same change with the decoration removed exits 0.
- **SC-002**: The canary passes with zero failures, and eight independent mutations of the gate's
  detection paths each turn it red — measured, not asserted.
- **SC-003**: `sh scripts/sync-agents.sh --check` and `sh scripts/panoply.sh check` both exit 0 with
  the module present in the index.
- **SC-004**: The gate's own CI step passes on the pull request that introduces it, so the rule is
  demonstrated on the change that added it.

## Assumptions

- The rule is adopted against a tree that predates it (177 pre-existing banners in this repo alone),
  so change-scoped grading is the only shape that keeps the gate usable rather than always-red.
- Adopters who want the mechanical half in their own CI copy the step from the adopter template; the
  kit does not edit a repo's workflow for it.
- `LC_ALL=C` byte matching is acceptable for emoji detection because the kit is POSIX sh with no
  runtime dependencies; the limits of that choice are stated in the module rather than hidden.

## Domain & outside experts

| Question | Answer |
|---|---|
| The industry/domain this is built for | Developer tooling — governance kits consumed by coding agents and the engineers supervising them |
| Expert role consulted | None consulted for this change. Stated rather than fabricated, as the kit requires: the source material is the public `anti-slop` rulebook (MIT, read in full during this work), whose rule text is the outside input here — a published artifact that can be cited, not a person who was interviewed |
| What that expert said, in their terms | Its code-comment skill names the same four shapes this gate detects (decorative separators, workflow narration, end markers, decorative emoji) and states the governing principle as "a comment that restates the line below it adds nothing" |
| Effect on a requirement or story | Shaped FR-003 and FR-004, and produced the honest limit recorded in FR-002: the upstream rulebook states plainly that it is a filter which cannot supply direction, and it ships no mechanical gate — which is why the claim half is doctrine plus review rather than a gate |

## User interviews (simulated, 4 personas)

n/a — no user-facing surface, so no personas to interview. This change is to the kit's own shell
tooling and markdown doctrine, consumed by agents and maintainers rather than by end users: there is
no screen, flow, or interaction to design. The personas who WOULD be interviewed if this shipped a UI
are the maintainers running `check-comments.sh` and the reviewers asking the claims question, and
their input is captured above as the reproduced before/after in the Goal and in the canary's cases.

## Open questions

None. Every requirement above is resolved or deleted; there is no `[NEEDS CLARIFICATION: …]` carried
forward, and the owner's decision (extract the two gaps rather than import the upstream rulebook) is
recorded in the plan's deletion candidates.

## On resolve

Status is Resolved. The plan is written as a sibling in this folder and linked from the row in
`docs/agents/roadmap.md`, in the same change.
