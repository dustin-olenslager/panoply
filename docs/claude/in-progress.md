# In Progress

**Read this first.** The ordered queue of what is next. Top of the list is what to pick up now.
Every item points at a plan doc — if an item has no plan doc, it is not ready to start.

When an item ships: remove its row from here, move its folder into `<area>/completed/`, and add an
entry to `completed-features.md`.

## Active queue

| # | Item | Area | Plan doc | Status | Notes |
|---|------|------|----------|--------|-------|
| 1 | _EXAMPLE — delete this row_ — paginated list view for the records table | `ui` | [`ui/records-list/plan.md`](ui/records-list/plan.md) | In progress — milestone 2 of 4 | Server-side paging landed; filters next. Waiting on sort-order decision. |
| 2 | | | | Not started | |
| 3 | | | | Not started | |

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
