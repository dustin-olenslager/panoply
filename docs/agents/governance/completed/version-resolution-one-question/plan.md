# Plan: Version resolution answers one question

- **Area:** `governance`  ·  **Started:** 2026-10-01  ·  **Status:** In progress
- **Owner:** the owner (chose "fix it properly" over deferring) / Hermes (investigating + building)
- **Next step:** gates are green locally (`panoply.test.sh` 18/18, shellcheck clean, all five gates OK); next
  step = commit, push `fix/version-resolution-one-question`, open the ONE PR, confirm CI `verify` green,
  squash-merge, delete the branch.
- **Roadmap initiative:** Rejections are first-class — a decision that was turned down survives where the next agent asks.

## Goal

`scripts/panoply.sh version` gives the **same answer whichever tree resolves it**. After this ships,
`apply` and the doctor it copies into an adopted repo agree on the kit version, so `panoply.test.sh` is
green on a developer machine — not only on a clean CI runner — and the "stale kit" report an adopter sees is
true.

How we know it worked: the canary asserts the copy agrees with the source **in the presence of a canonical
clone**, goes red when the divergence is reintroduced (mutation-tested), and 18/18 checks pass.

**Out of scope:** changing what version a *tagged* release reports, and any change to `_is_copied_doctor`,
the stamp format, or `check`'s exit codes.

## Context

The symptom: `panoply.test.sh` failed case 11 (*"copied doctor reports the kit version"* — local gave
`v1.4.0`, kit is `unreleased`) on this machine only; CI is green, and the failure reproduced on clean
`origin/main` before any of this work.

**The mechanism (Phase 1–3 of `systematic-debugging`, each step measured, not inferred).**
`_kit_version` asked two different questions depending on which branch ran:

- From the kit **source**: `git describe --tags --abbrev=0`, i.e. "what release is this checkout?" — on a
  checkout 14 commits past `v1.4.0` that yields `v1.4.0-14-gc0dee04`, which the guard read as a version
  instead of falling through to `unreleased`.
- From a **copied doctor**: the same command run against a *canonical clone*, i.e. "what is the nearest
  ancestor tag?" — a different question, whose answer for the same commit is the bare `v1.4.0`, because
  `--abbrev=0` strips the `-14-g` suffix.

So `apply` stamped `unreleased` and the copied doctor reported `v1.4.0`. The divergence is invisible with no
canonical clone (the stamp is believed, both agree) and on a tagged checkout (both report the tag); it appears
exactly when the kit has **untagged commits since its last tag** *and* a canonical clone exists — which is a
developer machine, and never a fresh CI runner. That is why this was a local false red in the one gate
adopters are told to run.

**Constraint that shapes the fix:** a false red in that gate is worse than no gate — it trains people to
ignore a failure. The fix must make the two trees agree *by construction*, not by a special case.

Read as user-visible: the canonical kit clone is at the tagged-and-untagged commit `c0dee04`
with `v1.4.0` an ancestor, so it reported `v1.4.0`; the worktree source reported `unreleased`. Both were
answering the question they were asked; only one question was the right one.

## Architecture

- **Layers touched:** none in the Clean-Architecture sense — POSIX `sh` plus markdown, no source tree, no
  ports, no dependency direction.
- **New ports (interfaces):** none.
- **Boundary data:** none. The changed function returns a version string to its own callers.
- **Dependency direction:** unchanged — still POSIX `sh`, still no runtime dependency beyond `git`.
- **Swap test:** n/a (no vendor code). The requirement is `git` on `PATH`.

## The Algorithm pass

- **Question:** *who asked, and which constraint does it serve?* the owner, 2026-10-01 — he chose option A
  ("run `systematic-debugging` on it as its own batch — proper root cause, then a canary case proving the
  fix") over leaving it or patching the symptom. Constraint: the canary is the gate adopters are told to run,
  so a false red there destroys trust in every other gate.
- **Delete:** see the table. The pass deleted a resolution path (the copied doctor's tag lookup) and the
  fallback tag-scan, rather than adding a reconciliation step.
- **Simplify:** the least shape is **one question asked once** — a version comes from a tag only when HEAD is
  at it, and a copied doctor reads its own stamp. Net −4 lines in the function that caused this.
- **Accelerate:** the bottleneck was **diagnosis**, not execution — three prior attempts (stale clone;
  `PANOPLY_KIT_ROOT` reachability; the canary's own root) were each falsified by measurement before the real
  mechanism was found. Measured: the suite runs in ~40 s and the fix is 1 function + 1 canary case; the
  earlier wrong diagnosis cost a full round-trip. No perf claim is made — this is a correctness fix and no
  metric moved.
- **Automate:** the canary case is the automation, and it is **mutation-tested** before being trusted: the
  divergence was reintroduced (mutation 2) and the case went red, then green once restored. Deliberately not
  automated: nothing checks that a *tagged* release reports its tag, because `--exact-match` makes that true
  by construction and a case asserting it would be ceremony.

### Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| The copied doctor's `git describe` against the canonical clone | **removed** | This *is* the bug — the second question. The stamp was written by the source using the same rule, so it is authoritative. |
| The `git tag --sort=-v:refname \| head -1` fallback scan | **removed** | It existed to give a canonical clone with no reachable tag an answer. With the copied doctor no longer reading tags, it has no caller; keeping it would preserve a second answer path. |
| `_canonical_kit_root` / `PANOPLY_KIT_ROOT` / `_kit_source_root` | **kept** | Still used by `_kit_sha` and the self-detection path. Deleting them would be collateral damage beyond this defect. |
| Making the source mirror the clone's behaviour (report the nearest ancestor tag) | **removed** | Offered to the owner as option 2; rejected because it propagates the *wrong* question — an untagged checkout is not release `v1.4.0`, and every adopter would then see a version string that isn't the code they have. |
| `--abbrev=0` → `--exact-match` on the source | **kept, but is not the fix** | Kept for honesty in the source branch, but **measured as behaviourally identical** on an untagged HEAD (both return empty). Recorded because assuming it was the fix would have shipped a fix for a non-bug: the reproducing mutation is the copied-doctor branch. |
| Gating the new canary case on the source's *reported* version | **removed** | It made the case **skip** under mutation — a canary that disables itself when the defect is present proves nothing. The gate is now on raw tree state. |
| Cloning the source *worktree* to stage a canonical clone | **removed** | A clone of a worktree carries no tags, so `describe` returns empty, the copy falls back to the stamp, and the case passes without exercising the bug — a green test measuring nothing. It stages from `origin` now. |
| A new script or a fourth check for version agreement | **removed** | `panoply.test.sh` is the home for exactly this assertion; a second surface would be a second place to be wrong. |

## Milestones

- [x] **M1 — Root cause, measured**: three hypotheses falsified (stale clone, `PANOPLY_KIT_ROOT`
      reachability, canary root), then the two-question mechanism confirmed by forcing both trees to agree
      (17/17 green) and by direct measurement of `describe` in each tree.
- [x] **M2 — RED canary case**: `scripts/panoply.test.sh` case 11b stages a canonical clone from `origin` and
      asserts the copy agrees with the source; goes red at the pre-fix implementation (`copy said 'v1.4.0',
      source said 'unreleased'`) — proven independently of the machine's real clone.
- [x] **M3 — Fix**: `_kit_version` rewritten — source uses `describe --tags --exact-match` (tag only at HEAD,
      else `unreleased`); the copied doctor reads the stamp and never consults tags.
- [x] **M4 — Prove the canary**: mutation 2 (copied doctor reads the clone again) turns 2 cases red;
      mutation 1 (`--abbrev=0`) measured to be non-reproducing. 18/18 green, shellcheck clean.

## Exit criteria

- `sh scripts/panoply.test.sh` → **all green (18 checks)**, with the new case exercised (not skipped).
- The new case goes RED under a reintroduction of the divergence, and GREEN once restored — recorded.
- `shellcheck scripts/*.sh` clean; `sync-agents.sh --check`, `check-plan-home.sh`, `check-algorithm.sh`,
  `check-docs.sh`, `check-expert-review.sh` green locally and CI `verify` green on the PR.
- Exactly one PR open against `main`.

## Open questions

_None — the standardisation choice (stamp-only for the copy; tag-only-at-HEAD for the source) was put to the
owner and, with no answer returned, the recommended option was taken as the safe default per his standing
"often away" rule, and is reported rather than assumed._

## Build notes

> **Build note:** 2026-10-01 — the first diagnosis in this session was **wrong** and had to be retracted: I
> attributed the failure to a stale canonical kit clone. Refreshing that clone to `main` did not fix it,
> which falsified the theory. Recorded because a wrong root cause that ships a fix is the failure mode
> `systematic-debugging` exists to prevent.

> **Build note:** 2026-10-01 — two canary drafts passed for the wrong reason before this one worked: the
> first set the override on *both* sides (same tree, trivially equal), the second staged a clone of a
> *worktree* (no tags → the copy fell back to the stamp → green while measuring nothing). Both were caught
> by running mutation tests, not by reading the case. A test that cannot go red is not a test.

> **Build note:** 2026-10-01 — the `_at_tag` guard had to be removed: it skipped the case *precisely when the
> mutation was present*, because reintroducing the bug makes the source report a tag. Invariant for any
> future case here: **gate on the raw fixture's state, never on the value produced by the code under test.**

## On ship

**Shipped 2026-10-01** in PR #19 (squash-merged), CI `verify` green in 13s. Folder archived at
`governance/completed/version-resolution-one-question/`; the `completed-features.md` entry, the worklog
line, the removed `in-progress.md` row, and the moved `roadmap.md` initiative (to Shipped) landed in the
same batch. The durable lesson — **a gate that asks two different questions of two trees will disagree with
itself, and a canary that cannot go red is not evidence** — was promoted into `key-patterns.md`.

Post-fix verification of the original symptom, run on fresh `main` under all three conditions that used to
distinguish pass from fail: real canonical clone present (`18/18`), empty `HOME` with no clone (`18/18`), and
the machine's own canonical clone (both agreement cases `ok`). The false red is gone everywhere, not just on
the runner.
