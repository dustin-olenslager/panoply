# Interviews: the software factory (US-1, the phase report)

> Both rounds. Every simulated entry is marked SIMULATED — a hypothesis about a user, not testimony
> from one. A real interview supersedes the simulation and is recorded under the person's name.
>
> Round 1 was folded into the three expert reviews (architect, planning auditor, UX lead) that shaped
> FR-001…FR-017; their findings and the requirements they changed are recorded in the spec's expert
> section. What follows is **Round 2 — against the wireframe**, which is the round that judges the
> screen rather than the idea.

## Round 2 — against the wireframe

**Refuter:** persona 1 is assigned to BREAK this screen, not confirm it. The refuter's job is to name at
least one thing that should change; "nothing" is legal only with a statement of what it tried and could
not break.

| # | Persona (domain role) | Simulated? | What surfaced | Changed |
|---|---|---|---|---|
| 1 | Operator running several projects at once | SIMULATED (refuter) | "Three examples in one screen is right for a demo and wrong for the real thing. When I run it I get ONE repo's answer, and the thing I most need is to compare across projects — which repo is furthest behind. The wireframe answers 'where is this repo' and quietly implies I'll run it three times." | **Added a batch form to the report shape**: `factory-detect` with no `--path` over a list of repos, printing one line per repo with the phase, so cross-project comparison is a first-class output rather than three manual runs. Recorded as a new interaction to design against (4): *what does the multi-repo line look like?* |
| 2 | Maintainer who inherits someone else's repo | SIMULATED | "Phase 0 says 'run doctor and apply' — but I've inherited a repo where the kit is absent AND the work is half built. 'Adopt' tells me nothing about the half-built work. I need to know the adoption won't destroy what's there." | **`next` for Phase 0 must name the risk it is not taking.** The Phase-0 next step now has to state that adoption is additive and what it will leave alone — not just "run apply". Recorded as a change to the Phase-0 report text. |
| 3 | Owner (non-author) reading a report they did not run | SIMULATED | "The `why` line is the whole product and it's the least visual thing on the screen. Everything is the same weight — phase, why, next, evidence. If I'm skimming after being away, I read the phase and stop, and the phase number alone is the least trustworthy part." | **Hierarchy: `why` must not be visually equal to `evidence`.** The wireframe gave all four fields the same treatment; the revision indents and separates `why` so a skim reads phase → why → next, and evidence stays available but subordinate. |
| 4 | Ops person who runs this in CI, not by hand | SIMULATED | "This is a human report. In CI I need *no* prose — I need the phase as a machine token, and a non-zero exit only when something is actually wrong. A confident human-shaped report is exactly what I can't consume." | **Recorded as `nothing` for the human wireframe**, with the requirement moved to the `--json` interaction (3) rather than changing the human shape. The two consumers get two shapes on purpose; conflating them would ruin the human one. |
| 5 | New contributor reading a Phase-1 report | SIMULATED | "It says 'write spec.md' or 'BACKFILL from what exists'. Those are different instructions and from the outside they look the same — one is 'do work' and one is 'don't block on work'. As a newcomer I cannot tell which I'm being told." | **The backfill distinction must be visible in the report's first line**, not buried in `why`. A backfill report is a different instruction from a plain spec report, so it cannot share a heading. |

## What did NOT change, and why

Recording this explicitly, because a table of only-changes flatters the interview into looking more
productive than it was:

| Surfaced | Kept as-is, because |
|---|---|
| "Add colour to distinguish phases" | Phase identity is in the text, not the colour; colour would imply severity, and Phase 0 is not an error. |
| "Show the file paths the evidence came from" | `git rev-parse` paths are already printed for O1; adding more would make a 5-line answer into 15 lines for a case nobody has hit. |
| "Make it a web dashboard" | It is read where the operator already is — a terminal. A dashboard adds a dependency to serve the output of a shell script. |

## `n/a — <reason>`

Not applicable: this is a terminal report, and the interview round ran against it as required. The
`n/a` form applies to changes with **no** user-facing surface; US-1 has one (the operator reads it).
