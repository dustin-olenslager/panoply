# Plan: two gates that read the wrong thing in CI

- **Area:** `governance`  ·  **Started:** 2026-11-10  ·  **Status:** Shipped 2026-11-10
- **Owner:** coordinator `Dev repo and workflow cleanup [a002eb]` (Dustin, 2026-11-10: "Fix them now")
- **Next step:** none — shipped.
- **Roadmap initiative:** `../../../roadmap.md` → Gate CI fixes.
- **Spec:** `n/a — routine` — two defects inside existing gates, found while building dev-kit's plugin-gaps plan. Nothing new is designed.
- **Domain & experts:** n/a — no outside domain. Shell gates in the kit itself.

## Goal

Two gates give the result their docs promise when they run in CI:

1. `check-milestone-evidence.sh` grades only the lines a change touched, also when every edit in the change is one line long.
2. `check-expert-review.sh` sees the trivial escape in CI: a `trivial` PR label, and a `trivial:` prefix on the PR's own commit.

We will know it worked when each canary has a case that fails against the old script and passes against the new one.

**Out of scope:** what counts as evidence or as trivial; the sign-off rule (`EXPERT_REVIEW_REQUIRE_SIGNOFFS`) other than using the same PR number.

## Context

- **One-line hunks.** `git diff -U0` writes a one-line hunk as `@@ -5 +5 @@`, without `,count`. The gate's `sed` required `+N,M`, so those hunks matched nothing. A change made only of one-line edits produced an empty line set and fell back to grading the whole plan, so an older milestone the change never touched failed it. Ticking one milestone in an old plan is exactly that change.
- **Trivial escape in CI.** CI never set `GITHUB_PR_NUMBER`, so the label branch never ran there. `actions/checkout` on a `pull_request` checks out GitHub's test merge commit ("Merge <head> into <base>"), so `git log -1` never showed a `trivial:` prefix either. Both escapes only worked on a laptop.

## Architecture

- **Layers touched:** none — POSIX `sh` in two gate scripts plus their canaries.
- **New ports (interfaces):** none.
- **Boundary data:** `$GITHUB_EVENT_PATH`, the event file GitHub Actions already writes, read with `python3` (already on the runners) and only when present.
- **Dependency direction:** n/a.
- **Swap test:** n/a.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — both gates claimed behaviour they did not have in CI, which is where they block merges. The requester is every adopter that runs them there.
- **Delete** — the comma requirement in the hunk regex goes. The `gh`-only label lookup stays as a fallback for laptops, behind the event file.
- **Simplify** — read the label from the event file GitHub already wrote, instead of adding a token and a PR-number variable to every adopter's workflow. Read the prefix from the merge commit's second parent, which is the PR's head.
- **Accelerate** — no new network call in CI: the event file is local.
- **Automate** — the new cases ride the existing self-tests job.

### Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| `,` required in the hunk header | **Yes** | It drops every one-line hunk; git omits the count when it is 1. |
| `gh pr view` label lookup | No — kept as the fallback | Laptops have no event file; there `GITHUB_PR_NUMBER` plus `gh` still works. |
| Passing `GITHUB_PR_NUMBER` and `GH_TOKEN` in `verify.yml` | Not added | Every adopter copies the workflow; the event file needs no change there. |

## Build notes

Routine work inside existing gates: one regex, one helper, one parent lookup, three canary cases.

## Milestones

- [x] M1 — one-line hunks stay line-scoped — `scripts/check-milestone-evidence.sh`, canary case 13 in `scripts/check-milestone-evidence.test.sh`
- [x] M2 — label from the event file, prefix from the PR head under a merge checkout — `scripts/check-expert-review.sh`, canary cases 9 and 10 in `scripts/check-expert-review.test.sh`
- [x] M3 — the change record — `CHANGELOG.md`
- [x] M4 — dev-kit takes both scripts and canaries from the kit — dev-kit `PR #52` (`06b58efa`), byte copies
