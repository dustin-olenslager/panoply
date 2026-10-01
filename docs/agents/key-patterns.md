# Key Patterns & Gotchas

Conventions to follow and traps to avoid, discovered the expensive way. Add to this file the moment
something surprises you — record the **symptom**, not just the fix, because the next person arrives
holding the symptom.

## Conventions

Patterns that new code must match. Keep each one checkable — a reviewer should be able to point at
a line and say "this violates it."

- _Example: use named exports; no default exports — so renames are greppable and re-exports stay explicit._
- _Example: shared enums and constants come from the shared module; no magic strings._
- _Example: all outbound HTTP goes through the single typed client wrapper, not raw fetch calls._

## Gotchas

| Symptom you will see | Actual cause | What to do |
|---|---|---|
| _EXAMPLE — tests pass locally, fail in CI with a timeout_ | _CI runs without the local cache warm_ | _Seed the fixture in `beforeAll`, not lazily_ |
| A structural change's plan has no `Deletion candidates` section, so `check-algorithm.sh` refuses the write | Deletion's output is **absence**, so nothing at the end reminds anyone it was skipped | Fill the section from `_templates/plan.md` before retrying. An empty table must be **argued**, not left blank — and a proposal that was considered and **turned down** belongs in the same list (what it was, why it lost, **what we do instead**) |
| An idea gets re-proposed a month after it was rejected | The rejection was a **conversation**; conversations leave no artifact to find | Record it in the plan doc's candidate list when the decision is made. Do **not** build a second decisions store or an index for it — the list the agent already reads before working in that area is the ledger |
| `panoply.sh version` (or a "stale kit" report) disagrees between the kit source and an adopted repo | One function asked **two different questions** depending on which tree resolved it ("what release is this checkout?" vs "what is the nearest ancestor tag?"), and `git describe --tags --abbrev=0` strips the `-n-g<sha>` suffix that made the source's answer correct | Ask **one** question in every tree: a tag counts only when HEAD is exactly at it (`describe --tags --exact-match`), else `unreleased`; a copied doctor reads its own stamp rather than another tree's tags |
| A canary case passes while the bug is present — or skips under a mutation test | It measured nothing: both sides pointed at the same tree, or the fixture carried no tags so the code fell back to the value it was supposed to compare | Stage the fixture from `origin`, never from a worktree (a worktree clone carries no tags), and **gate on the raw fixture's state — never on the value produced by the code under test.** Reintroduce the defect and watch the case go red before trusting it |

## Testing conventions

- What must have a test before it merges — name the categories (business logic, validation,
  transformations, every route/endpoint or public entry point).
- Where tests live and how their paths map to the code under test. State the mapping rule exactly;
  an ambiguous rule means tests get written in three places.
- What gets mocked by default (auth, database, external services) and what must be exercised for real.
- **Never skip, `.only`, or comment out a failing test to get a change through.** Fix it or report it.
- When you change query structure or call ordering, update the mocks in the same change — mocks
  consumed in sequence return the wrong data silently when the order shifts, and the test stays green.

## Performance notes

- Known hot paths and what makes them slow.
- Anything with an N+1 shape that is deliberately tolerated, and the threshold at which it stops
  being acceptable.

## Things that look wrong but are intentional

Guard rails against well-meaning "cleanups" that reintroduce a fixed bug. One line each, with the
reason.
