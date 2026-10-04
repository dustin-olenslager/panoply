# Plan: the doctor's silent skip inside a git worktree

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** In progress
- **Owner:** Hermes
- **Next step:** merge this PR; then port the same guard into every adopter's `scripts/panoply.sh` (frame-forge already has it in PR #754; a pilot repo needs it) and re-run `sh scripts/panoply.sh check` there from a worktree.
- **Roadmap initiative:** `../../roadmap.md` → Mechanical enforcement.
- **Spec:** `n/a — routine` — a one-line guard fix inside an existing script, found by running the tool. Nothing new is designed; see Build notes.
- **Domain & experts:** n/a — no outside domain. This is a shell-guard defect in the kit's own doctor.
- **Parent plan:** `../software-factory/plan.md`.

## Goal

`sh scripts/panoply.sh check` runs — and returns a real verdict — inside a git **worktree**, not just
in a primary checkout. Today it prints `not a git working tree (nothing to check)` and exits 0 there.

We will know it worked when: in a tree created by `git worktree add`, the doctor prints a kit verdict
(current / drifted / partial / …) rather than the skip message, and `PANOPLY.TEST` has a case that
fails if it goes back to skipping.

**Out of scope:** changing what any verdict means; auto-fixing still belongs to `apply`/`migrate`.

## Context

The guard was `[ ! -d .git ]`. A linked worktree — and a submodule — has `.git` as a **file**
containing a gitdir pointer, not a directory. So the branch is taken, the message prints, and the
script exits 0: the check did not run and the exit code says everything is fine.

That is the exact defect class the kit exists to remove — a run that looks like it checked and had not
— and it fired in precisely the environment parallel agent work uses, because every adopter creates one
worktree per task (`frame-forge` has ~30 live). Every `panoply.sh check` run from a task worktree in
any adopted repo has been reporting success without checking anything.

Found by porting the mirror-index change into `frame-forge` (PR #754), where the ported doctor reported
`MIRRORS DRIFTED` and the pre-existing one reported nothing.

## Architecture

- **Layers touched:** none — a POSIX `sh` guard in `scripts/panoply.sh` plus a test case.
- **New ports (interfaces):** none.
- **Boundary data:** none.
- **Dependency direction:** n/a.
- **Swap test:** n/a.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — the kit's own doctrine names the target: a check that cannot fail is decoration, and a
  false green is worse than no check. The requester is the adopter workflow that runs one worktree per
  task.
- **Delete** — the defect is a wrong *test*, so the deletion candidate is the test itself. Named and
  answered in the table below.
- **Simplify** — the least shape is a one-line replacement of the guard with the question git already
  answers: `git rev-parse --is-inside-work-tree`.
- **Accelerate** — measured: in a worktree the old guard checked **0 of 1** repo state and exited 0; the
  fixed guard checks it and returns the real code (14, `MIRRORS DRIFTED`, on `frame-forge`'s tree before
  regeneration). The bottleneck was never speed — it was that the check did not execute at all.
- **Automate** — nothing to automate. The guard is already wired into CI's `self-tests` job; the new
  case rides the existing suite.

### Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| `[ ! -d .git ]` as the working-tree test | **Yes** — replaced by `git rev-parse --is-inside-work-tree` | It is wrong for worktrees and submodules, and it fails **open** (exit 0). Deleting it is the whole fix. |
| The `not a git working tree` message | No — kept verbatim | The case is still real (a bare directory); only its trigger changes, so every consumer still recognizes it. |
| The guard entirely | No | Without it, a non-repo directory would be checked against kit files that cannot exist there, which is a worse error than the skip. |
| The first version of the new test | **Yes** — rewritten | It ran the *worktree's own* stale `scripts/panoply.sh` instead of the doctor under test, so it passed against the buggy guard too. A probe that runs the wrong binary is decoration; the mutation test caught it. |
| The whole request (do not fix) | No | The adopters run their work in worktrees; leaving it means the kit's primary verdict silently does not run where the work happens. |

## Build notes

Routine work inside an existing pattern: a guard condition and one test case, no new surface.

## Milestones

- [x] M1 — the guard — `scripts/panoply.sh`
- [x] M2 — the worktree regression case — `scripts/panoply.test.sh`
- [x] M3 — the change record — `CHANGELOG.md`
- [ ] M4 — port the guard into the adopters' copies — frame-forge #754; a pilot repo pending
