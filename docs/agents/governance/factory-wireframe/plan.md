# Plan: the wireframe rung (M3)

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** in progress
- **Spec:** `docs/agents/governance/software-factory/spec.md` (FR-006, FR-007, FR-008, FR-009, FR-010)
- **Domain & experts:** `n/a — internal process doctrine, no user-facing surface of its own`

## Context

M3 of the factory build. The rung that puts the screen before the backend, so the expensive-to-change
decision is made where changing it is cheap. M3 ships the contract, the doctrine, the interview protocol
and the templates — and **not** the presence gate, deliberately: get the artifact right before gating it.

## Algorithm pass

- **Question** — FR-006…FR-010, each traced to the UX lead's expert review in the factory spec.
- **Delete** — see Deletion candidates. Notably the Figma option, which was tested and removed on
  evidence rather than on taste.
- **Simplify** — one path contract (`wireframe/index.html` + `interviews.md`), two templates, one rule
  module. No new directory convention, no tooling.
- **Accelerate** — the bottleneck is rework, not authoring speed. A wireframe is minutes; discovering the
  screen is wrong after the API is fitted to it is days. No machine-time claim is made, because machine
  time is not the constraint here.
- **Automate** — nothing automated yet, on purpose: the gate is M4. Automating a presence check before
  the artifact shape is settled would freeze the wrong shape.

## Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| Figma as the wireframe target | rejected | **Tested, not assumed.** The Figma REST API returns 404 for `POST /v1/files` and for the Variables API — it reads designs and exports images, and does not author them. Authoring needs the Plugin API running inside Figma's UI, so an agent could not have produced the comparison artifact at all. A wireframe an agent cannot author breaks the kit's premise, and the artifact is not a diff. | In-tree, framework-free `wireframe/index.html` |
| A `check-wireframe.sh` presence gate in M3 | removed | Gating before the artifact shape is settled freezes the wrong shape, and its first real run would fail the kit's own templates — exactly what happened to the coverage gate in M1 | M4, after the shape is proven |
| Screenshots as the artifact | removed | Not a diff: a reviewer cannot see what changed between two PNGs, and it cannot be edited line by line | HTML source, self-contained |
| A separate `wireframes/` tree | removed | Splits the artifact from the spec it serves, so a reader needs two locations for one feature | `wireframe/` inside the feature folder |
| Real copy in wireframes | removed | A wireframe that reads as finished stops being one — the reviewer proofreads instead of judging structure | Grey placeholder bars |
| A `confidence` field per interview finding | removed | Unverifiable self-report, the exact theatre FR-009 exists to prevent | The "changed what" column, which is checkable |
| The whole rung for non-user-facing changes | removed (exempted) | Ceremony the scope test forbids | The required `n/a — <reason>` form |

## Steps

- [x] `.agents/rules/wireframe-first.md` — doctrine, path contract, skip test, interview protocol
- [x] `docs/agents/_templates/wireframe/index.html` — the artifact template
- [x] `docs/agents/_templates/interviews.md` — both rounds, with the required `n/a` form
- [x] **Proof: a real wireframe** for the factory spec's own US-1 (`software-factory/wireframe/index.html`)
- [x] **Proof: a real interview** with four changes and three recorded non-changes
- [x] Detector: metasyntax rule for O6 (a spec documenting the marker is not blocked by it)
- [x] Detector: the BACKFILL flag (a plan with no spec drafts one; it does not block)
- [x] `check-rule-fork.sh`: separate "drift found" from "could not audit"
- [x] 21 detector canaries, both directions for metasyntax and backfill

## Review / expert sign-off

- **Security:** `n/a — markdown and static HTML; no network, no credentials`
- **Performance:** `n/a — no runtime path`
- **Maintainability:** reviewed by the parent. The protocol's load-bearing part is the "changed what"
  column, which makes an empty interview **visible** rather than preventing it — stated as a limit, not
  claimed as a guarantee.
- **UX:** the rung IS the UX requirement; the proof wireframe carries its own annotations and was
  interviewed against, per the protocol it defines.

## Outcome

The proof produced what the rung is for: **four design changes from the interview** (a batch form for
cross-project comparison; Phase-0's `next` naming what adoption leaves alone; visual hierarchy so `why`
outranks `evidence` for a skimming reader; the backfill distinction promoted to the first line) and
**three explicit non-changes**, recorded because a table of only-changes flatters an interview into
looking more productive than it was.

Two defects were found in the detector by running it against the real repo rather than only against
fixtures: it counted the template sentence *documenting* `[NEEDS CLARIFICATION: …]` as four unresolved
questions, and it reported a plan-without-a-spec as a plain Phase 1 rather than a backfill. Both now
have canaries in both directions.
