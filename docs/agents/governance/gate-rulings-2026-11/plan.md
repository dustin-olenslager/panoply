# Plan: two gate rulings, ported from dev-kit

- **Area:** `governance` · **Started:** 2026-11-11 · **Status:** In review
- **Owner:** a dev-kit session porting Dustin's two 2026-11-11 gate rulings (dev-kit code audit lane `dk-ci-lint-waste`)
- **Next step:** merge the docs-gate PR once green; then this plan is done. panoply#9 stays open for its own decision.
- **Spec:** none. Two existing gates change what they accept; no new artifact, no new gate.

## What

An audit of dev-kit's CI on 2026-11-11 found that 8 of the last 10 red `verify` runs came from two
document gates, and that most were the gate being stricter than its own description. Dustin ruled on
both the same day. The gate scripts are identical in dev-kit and in the kit, so the kit carries the
same defects.

1. **Milestone evidence — "Accept any valid reference".** A ticked milestone passes if ANY
   backticked path on the line exists or a `PR #n` on it resolves, matching what the gate's own
   comment promises. Before, only the last backticked text on the line was read, and a PR reference
   was ignored whenever backticked text was present. A line naming a real path and then a label in
   backticks was refused.
2. **Docs landing gate — "Judge the whole PR".** The gate passes when the PR's combined change
   includes the worklog or changelog line, since PRs are squash-merged into one commit anyway. The
   staged (pre-commit) check does not change.

## Design

- `check-milestone-evidence.sh` collects every backticked text and every `PR #n` on a ticked line
  and passes on the first that resolves. When none resolves, the refusal gives `plan:line`, the
  line, every reference that failed and why, and the edit that fixes it.
- `check-docs.sh --since <base>` checks `git diff <base>...HEAD` once. With no flag it still checks
  the staged change.

## Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| Reading only the last backticked text on a milestone line | **removed** | It is not what the gate's comment or its help text describe, and it caused every recent red run of the gate. |
| The per-commit walk in `check-docs.sh --since` | **removed** (second PR) | A squash-merge lands one commit per PR, so the PR is the unit that needs the line. |
| The Milestone evidence gate itself | **kept** | A tick with nothing behind it is still refused; only the over-strict reading goes. |
| panoply#9's `--each-commit` mode and its pre-commit change | **not taken here** | They go beyond the ruling. #9 stays open for its own decision. |

## Milestones

- [x] Milestone evidence gate accepts any valid reference; canary cases from the red runs — `scripts/check-milestone-evidence.test.sh`
- [x] Docs landing gate judges the whole PR; canary cases for a follow-up commit, a range with no line, an unknown ref — `scripts/check-docs.test.sh`

## Launch

- **Launched** by merging each PR: the kit's own CI uses the changed gate at once, and adopters get it on their next `panoply.sh apply`.
- **Rollback:** revert the PR. Both changes only widen what passes, so a revert cannot block a PR that was green before.
