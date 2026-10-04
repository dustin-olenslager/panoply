# Plan: plan→code reconciliation (M5)

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** complete
- **Spec:** `docs/agents/governance/software-factory/spec.md` (FR-005, FR-013)
- **Domain & experts:** `n/a — internal shell gate, no user-facing surface`

## Context

M5 of the factory build, and the second of the two seams the planning audit named. M1's coverage gate
closed **spec → plan** (every requirement claimed by a milestone). This closes **plan → code**: a plan
could tick a milestone with nothing behind it and every gate stayed green. The audit's own words were
that spec and plan are individually good and "the failure is at the seams."

## Algorithm pass

- **Question** — FR-005 names the gap the audit found; FR-013 requires the factory to say what it did,
  which a gate does at the moment of refusal.
- **Delete** — see Deletion candidates.
- **Simplify** — one shell script, one canary, reusing the change-scoping and count-reporting patterns
  the five sibling gates already established rather than inventing a sixth shape.
- **Accelerate** — the bottleneck is the same class M1 targeted: a false "done" is caught at PR time
  rather than discovered later as work nobody did. Machine cost is sub-second.
- **Automate** — last: the canary runs in CI on any tooling change, so a gate that stops detecting fails
  the build rather than going quietly green.

## Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| Grading the WHOLE plan, as the first draft did | removed | It failed **19 of this repo's 54** completed milestones — debt predating the rule. Any edit to an older plan would be blocked by history, which teaches people to avoid touching plans | Grade **only the milestone lines this change wrote**, unioning the committed range and the index so both CI and pre-commit see the right set |
| Requiring evidence on OPEN milestones (`- [ ]`) | removed | An open milestone claims nothing yet, so it owes nothing — demanding evidence there is over-strict and would train people to write fake references | Completed only |
| Accepting any backtick as evidence without resolving it | removed | A reference that resolves nowhere is the same as no reference — the coverage gate already learned that a dangling citation must be caught | Resolve each: the path must exist, the PR must appear in the log |
| A fixed evidence format (exactly one path) | removed | The honest artifact varies — a file, a directory, a script, a PR | A path OR a PR reference, anywhere in the line |
| Judging whether the claim is TRUE | rejected | Unverifiable by machine; a gate asserting it would look rigorous and measure nothing | Presence + resolution only; truth is a review question |
| A per-milestone confidence score | removed | Unverifiable self-report; theatre | Evidence offered, and it resolves |

## Steps

- [x] `scripts/check-milestone-evidence.sh` — change-scoped, line-scoped, resolves path or PR
- [x] `scripts/check-milestone-evidence.test.sh` — 11 canaries, both directions plus adversarial cases
- [x] Mutation-test: no evidence required, no resolution, open milestones judged, dead hatch — all caught by `scripts/check-milestone-evidence.test.sh`
- [x] **Line-scoping proven on the real repo** against `docs/agents/governance/factory-phase-detect/plan.md`: a comment-only touch passes; a bad milestone *added* is refused; an existing milestone line *modified* to drop its evidence is refused
- [x] Doctrine updated: `.agents/rules/spec.md` gains the plan→code seam and the gate's limits
- [x] Wired into CI beside the other gates + the self-tests job, in `.github/workflows/verify.yml` and `scripts/templates/ci-verify.yml`
- [x] Both workflows validated as parsing, and clean under shellcheck — see `scripts/check-milestone-evidence.sh`

## Review / expert sign-off

- **Security:** `n/a — reads markdown and git history; no network, no credentials`
- **Performance:** `n/a — sub-second; one diff plus one log scan bounded at 5000 commits`
- **Maintainability:** reviewed by the parent. Follows the five sibling gates' shape (change-scoped,
  declared escape hatch, count of what was checked, honest limits in the source header and doctrine).
  Canary is mutation-tested rather than trusted.
- **UX:** `n/a — no user-facing surface` (the reader is an agent or a maintainer reading a CI failure)

## Outcome

Three real defects, all found by running the gate against the actual repo rather than by testing it:

1. **Whole-file grading punished touching old plans** — measured before fixing: **19 of 54** completed
   milestones lacked a checkable reference. Line-scoping was the fix, and the measurement is why the
   decision was made rather than guessed.
2. **The line-number prefix leaked into the message** (`44:- [x] Mutation-test…`), sending the reader to
   a garbled claim. Stripped before the trim.
3. **A shell syntax error in the command substitution** — a trailing `; \` between two `git diff` calls
   inside `$(…)` with the second piped. `sh -n` caught it; the gate died before assigning, and the
   symptom was a wrong verdict rather than an error. Two separate substitutions, unioned, then parsed
   once.

A fourth finding was **not** a defect: three consecutive failures during verification were my own
cleanup. `git checkout -- <file>` restores from the INDEX, and the index still held the bad test
milestone, so the file kept the defect and the gate kept refusing it correctly. The gate was right three
times while I believed it was wrong — worth recording, because "the tool is broken" is the cheapest
hypothesis to reach for and the one that wastes the most time when it is false.

A **fifth** defect was found only in CI, and is the most instructive of the five. `gh pr view` verified a
PR reference against the **real** GitHub repository while the canary's fixture is a throwaway temp repo —
so a fixture's deliberately-resolvable fake `PR #42` was queried against the real repo, reported as
nonexistent, and the canary failed on the **environment** rather than on the behaviour. The same fixture
class as "cannot look, reported as found nothing": the check ran somewhere other than where it believed
it was running. Fixed by restricting the gh lookup to a gh-resolvable, non-fixture checkout and letting
the commit log be the authority everywhere else, which is deterministic. Both directions re-verified
under simulated CI conditions (`GITHUB_ACTIONS=1`): a resolvable PR passes, a bogus one is still refused.
