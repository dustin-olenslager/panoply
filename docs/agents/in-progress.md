# In Progress

**Read this first.** The ordered queue of what is next. Top of the list is what to pick up now.
Every item points at a plan doc — if an item has no plan doc, it is not ready to start.

The **Notes** cell of the active row is its handoff: keep the *exact next step* there — the file to
open, the command to run, the blocker — refreshed whenever you pause, so the next session resumes
cold. A row with no next step is a row nobody can pick up. (Doctrine: `.agents/rules/documentation.md`.)

Each row rolls up to a `roadmap.md` initiative (the strategic view) and leaves a trail in the worklog
(`worklog.md` or the `CHANGELOG` `[Unreleased]`). A row with no initiative is tactical work with no
strategic home — add the initiative to `roadmap.md`, or say in Notes why it is a deliberate one-off.

When an item ships: remove its row from here, move its folder into `<area>/completed/`, and add an
entry to `completed-features.md`.

## Active queue

| # | Item | Area | Initiative | Plan doc | Status | Notes |
|---|------|------|------------|----------|--------|-------|
| 1 | The Algorithm — five-step pass, in the rules, in every mirror, and in Hermes (injection + gate) | governance | The Algorithm | `governance/execution-algorithm/plan.md` | In progress — M4/M5 open | Kit half (M1–M3) is on `main`: `.agents/rules/algorithm.md`, `scripts/check-algorithm.sh`, and every mirror. Next step = M4 (verify the installed `execution-algorithm` Hermes plugin against the plan's M4 text — its source lives outside this repo, which is why the milestone carries no in-repo evidence path and stays unticked), then M5, the non-code cadence report. No PR is open. |

**Status vocabulary:** `Not started` · `In progress — milestone N of M` · `Blocked — <on what>` ·
`In review` · `Done — archiving`.

## Blocked / waiting

Items that cannot move, and the one thing each is waiting on. Review this list before starting
anything new — an unblocked item here outranks a fresh one.

| Item | Blocked on | Since |
|------|-----------|-------|
| | | |

## Parked

Ideas deliberately deferred. Keep the reason — "we said no because X" is what stops the same
proposal coming back every month.

| Item | Why parked | Revisit when |
|------|-----------|--------------|
| | | |
