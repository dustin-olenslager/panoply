# Plan: canary fixtures must not be sourced from a moving ref

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** In progress
- **Spec:** none — this is a test-fixture defect inside the kit, with no user-facing surface.
  (`scripts/check-spec.sh` exempts it: the change touches only `scripts/*.test.sh` and `CHANGELOG.md`,
  so it is not structural. Recorded here rather than left implicit.)

## What broke

Two canary cases in `scripts/panoply.test.sh` built a marker-less "old doctor" fixture with
`git show origin/main:scripts/panoply.sh`. PR #35 added `_PANOPLY_GENERATION` to the kit, so the moment
it merged, `origin/main` carried the marker and neither fixture was an old copy any more.

The suite passed on the PR branch and went red on merged main. CI could not catch this: on the branch,
`origin/main` was still marker-less, so the fixtures were valid exactly where they were run.

## Deletion candidates

- **`git show origin/main:scripts/panoply.sh` as a fixture source (both call sites)** — **removed.**
  A fixture whose *state* comes from a ref that will move tests the ref, not the behaviour. This is the
  defect itself, not a symptom of it.
- **The `origin/main` sanity assertion** (`"origin/main already carries a marker — the fixture is not an
  old copy"`) — **removed.** It only existed to detect the source going stale; with the source gone the
  check is meaningless. Replaced by an assertion that the STRIP worked, which is the new precondition.
- **A shared `_markerless_doctor()` helper** — **not built.** Two call sites is not enough to justify
  the indirection, and the two sites carry different explanatory comments. Revisit at three.

## The fix

Both sites now build the old copy by stripping the marker from the current doctor:

    { printf '#!/usr/bin/env sh\n'; grep -v '^_PANOPLY_GENERATION=' "$DOC" | grep -vF "$_PANOPLY_GENERATION"; } > "$R/scripts/panoply.sh"

State-independent: it is an old copy whenever it runs, on any branch. The second `grep -vF` also
removes lines that *read* the marker, or the copy would reintroduce one.

## Verification

- `sh scripts/panoply.test.sh` → all green (36 checks), on current `main`.
- Both call sites asserted to produce a genuinely marker-less file.
- `grep -c 'show origin/main:scripts' scripts/panoply.test.sh` → 0.

## Steps

- [x] Replace both `origin/main` fixture sources with the marker-strip construction.
- [x] Assert the strip produced a genuinely marker-less file (the new precondition).
- [x] Run the full canary suite on merged `main` — 36 checks green.
- [ ] Watch for a third call site: if one appears, extract `_markerless_doctor()`.
