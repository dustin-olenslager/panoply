# Small Slices: Ship the Smallest Piece Someone Can Try

> **Applies when:** changes land through pull requests — every agent, lane and branch.
> **Delete this file (and its `@` import in the generated agent hub) if:** the project has no PR/review process at all.

Agents over-build and take on more than one review can hold. By default, work ships as small pieces
of working functionality, as early as possible, so a person can start testing before the whole is done.

1. **Cut to the smallest slice a user can try.** Before building, name the thinnest piece of
   functionality someone can open and use. Build that, ship it as one PR, then cut the next.
2. **A plan is a queue of slices.** Each slice has its own one-line "done" that a person can check by
   hand. A plan with one big "done" at the end is not cut yet.
3. **Build only what the slice needs to work.** No abstraction, config, option or edge-case handling
   the slice does not need. Write the extras down as later slices instead of building them now.
4. **A PR past about 300 changed lines or 10 files stops and splits.** `scripts/check-pr-size.sh`
   flags it in CI and labels it `big`; it warns and never blocks. Docs, generated mirrors and lock
   files do not count. A PR that really cannot split says why in its body. The limits are a default:
   a repo may tune them (`SIZE_MAX_LINES`, `SIZE_MAX_FILES`, `SIZE_EXCLUDE`) and says so in its plan.
5. **A brief names one slice.** A sub-agent or lane brief gives one slice and its "done", not a whole
   program. A multi-slice job is a queue worked one PR at a time, and each PR merges before the next
   starts.
