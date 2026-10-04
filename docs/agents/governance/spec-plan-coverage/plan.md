# Plan: the spec→plan coverage rivet (M1)

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** complete
- **Spec:** `docs/agents/governance/software-factory/spec.md` (FR-004, FR-005 — the seam this closes)
- **Domain & experts:** `n/a — internal shell gate, no user-facing surface`

## Context

The first milestone of the factory build. The audit proved the seam: the spec rung and the plan rung are
each sound and each blind to the other, so a plan can omit requirements with every gate green. Real
damage found in this repo — a shipped spec promises its test "reports 12 passed" while it reports 21,
invisible to all nine gates.

## Algorithm pass

- **Question** — the audit proved the seam with evidence from this repo's own history; the requirement is
  named (FR-004/FR-005 in the factory spec). Neither the seam nor the fix is speculative.
- **Delete** — see Deletion candidates.
- **Simplify** — one shell script, one canary, one table in the plan doc. No config file, no new
  directory convention, no parser. The plan doc already existed; the table rides in it.
- **Accelerate** — the bottleneck is review attention, not machine time. Measured: the gate runs in
  under a second on this repo. Before this change, a plan could drop a requirement and nothing could
  detect it at all; after, detection is deterministic and local.
- **Automate** — last, and only what survived: a gate wired into CI beside the spec gate, so the check
  cannot be skipped by forgetting it.

## Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| A separate `requirements.txt` / machine-readable spec format | rejected | A second source of truth for requirements drifts from the prose spec; the ids are already in the prose | Parse `FR-NNN` from the existing spec |
| A parser for prose milestones | removed | Prose cannot be checked without guessing; a check that guesses is worse than none | The explicit `## Spec coverage` table |
| Requiring every repo in the tree to have a coverage table | removed | Would fail repos for work predating the rule, making this a second, stricter spec gate rather than a rivet | Change-scoped: only a pair this change touched |
| A confidence/category field on each row | removed | Unverifiable self-report; the kit forbids exactly this kind of theatre | Two facts only: the id, and the milestone |
| Joining `_templates/` scaffolding as a live pair | removed | Caught by the gate on its first real run — the kit's own templates failed it | Exempt scaffolding by path |

## Steps

- [x] Write `scripts/check-coverage.sh` — both directions (uncovered requirement; dangling citation)
- [x] Write `scripts/check-coverage.test.sh` — 11 canaries including the adversarial cases
- [x] Mutation-test the canary: missing-detection, dangling-detection, dead escape hatch, the fail-open
- [x] Prove it on real artifacts — the factory's own 17-requirement pair; one row deleted → refuses and names `FR-009`
- [x] Fix the scaffolding false positive found on the first real run
- [x] Fix the fail-open: an omitted function argument skipped every pair and still printed OK
- [x] Add `## Spec coverage` to the plan template
- [x] Document the rivet in `.agents/rules/spec.md`
- [x] Wire into CI beside the spec gate + the self-tests job + the adopter template
- [x] Fix the CI defect this surfaced: a step cannot carry two `run:` keys
- [x] Full suite green, shellcheck clean

## Review / expert sign-off

- **Security:** `n/a — local shell gate, no network, no credentials, reads markdown only`
- **Performance:** `n/a — sub-second, bounded by repo file count`
- **Maintainability:** reviewed by the parent — the gate follows the house pattern of every sibling
  (loose heading match, change-scoped, declared escape hatch, honest limits in the source header).
  The canary is mutation-tested rather than trusted.
- **UX:** `n/a — no user-facing surface` (the reader is an agent or a maintainer reading a CI failure)

## Outcome

Merged as M1 of the factory build. The seam the audit proved is now mechanically closed, and the gate
that closes it was itself corrected twice by evidence from a real run.
