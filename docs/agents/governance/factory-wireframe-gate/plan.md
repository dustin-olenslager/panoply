# Plan: the wireframe gate (M4)

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** complete
- **Spec:** `docs/agents/governance/software-factory/spec.md` (FR-006, FR-010, FR-011, FR-012)
- **Domain & experts:** `n/a — internal shell gate, no user-facing surface`

## Context

M4 of the factory build. M3 shipped the wireframe rung as doctrine and deliberately withheld the gate:
get the artifact right before gating it. M4 adds the mechanical backstop, because doctrine alone is
exactly what drifts — it is unverifiable by reading a diff, it gets skipped under pressure, and nobody
can tell it was skipped.

## Algorithm pass

- **Question** — FR-006 and FR-010 name the rung and its `n/a` exemption; FR-011 requires the factory to
  report what it did, which a gate does at the moment of refusal.
- **Delete** — see Deletion candidates.
- **Simplify** — one shell script, one canary. It reuses the change-scoping and scaffolding-exemption
  patterns the four sibling gates already established rather than inventing a fifth.
- **Accelerate** — the bottleneck is the same rework M3 targets: the gate refuses at PR time rather than
  a reviewer noticing a missing screen after the backend is fitted to it. Machine cost is sub-second.
- **Automate** — last: the canary runs in CI on any tooling change, so a gate that stops detecting fails
  the build rather than going quietly green.

## Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| Checking wireframe QUALITY (layout, hierarchy, copy) | rejected | Unverifiable by machine; a gate claiming to judge design measures the wrong thing while looking rigorous — the exact defect this kit has already shipped once (a rule module asserting four checks, two of which did not exist) | Presence only; quality stays in expert review |
| Requiring the artifact tree-wide | removed | Would fail every repo for work predating the rule, making this a second spec gate rather than a wireframe gate | Change-scoped: only a spec this change touched |
| Accepting a bare `n/a` | removed | The reason is the difference between a deliberate opt-out and an accidental skip | `n/a — <reason>` required; a bare `n/a` is refused |
| Keyword vocabulary as the DECIDER for "user-facing" | removed | A spec reading "no screen, internal only" contains `screen` and would demand a wireframe it explicitly declines — the false positive the detector already hit once | The reasoned `n/a` wins; vocabulary is only the fallback |
| Joining `_templates/` scaffolding as a live spec | removed | The coverage gate's first real run failed the kit's own templates; the same class of false positive was predictable here and was pre-empted | Exempt scaffolding by path |
| A confidence/quality score per check | removed | Unverifiable self-report; theatre | Existence, and the reason |

## Steps

- [x] `scripts/check-wireframe.sh` — presence only, change-scoped, scaffolding-exempt, count-reporting
- [x] `scripts/check-wireframe.test.sh` — 12 canaries, both directions plus the adversarial cases
- [x] Mutation-test: wireframe requirement, interviews requirement, bare-`n/a` acceptance, dead hatch — all caught
- [x] **Proven on real artifacts**: the actual factory spec is refused without its wireframe and passes with the real `index.html` + `interviews.md`, both exit codes verified
- [x] Doctrine updated: `.agents/rules/wireframe-first.md` gains the gate section and its limits
- [x] Wired into CI beside the other gates + the self-tests job, in both the kit workflow and the adopter template
- [x] Both workflows validated as parsing, with no duplicate `run:` keys

## Review / expert sign-off

- **Security:** `n/a — reads markdown and checks file paths; no network, no credentials`
- **Performance:** `n/a — sub-second, bounded by the changed-file list`
- **Maintainability:** reviewed by the parent. Follows the four sibling gates' established shape
  (change-scoped, loose heading match, declared escape hatch, count of what was checked, honest limits in
  the source header and the doctrine). Canary is mutation-tested rather than trusted.
- **UX:** `n/a — no user-facing surface` (the reader is an agent or a maintainer reading a CI failure)

## Outcome

A defect was found in the **canary**, not the gate: its verdict classifier grepped `"no reason"` in lower
case while the gate prints `"NO reason"`, so a bare `n/a` was misclassified as a missing-interviews
failure and the case reported the wrong reason. The gate was right; the test was lying about it. A
classifier that reports the wrong reason is worse than no classifier, because it sends the reader to the
wrong fix — worth recording as its own lesson.

The gate pre-empted two false positives the M1 coverage gate had to discover the hard way (templates
scaffolding, and reporting a count so "checked one" cannot be confused with "checked nothing"), which is
the point of having learned them.
