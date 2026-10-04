# Plan: the phase model and detection rule (M2)

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** in progress
- **Spec:** `docs/agents/governance/software-factory/spec.md` (FR-002, FR-003, FR-011, FR-012, FR-016, FR-017)
- **Domain & experts:** `n/a — internal tooling, no user-facing surface`

## Context

M2 of the factory build. Every later rung needs to know which phase it is being asked about, so the
phase model and its detector ship before the rungs that consume them. M2 **detects and reports only** —
acting on the phase is a later milestone, deliberately, because the detector must be provable before
anything is allowed to act on its answer.

## Algorithm pass

- **Question** — the factory spec names it (FR-002/FR-003); the owner asked for phase-aware behaviour.
- **Delete** — see Deletion candidates. Notably: no model call, no network, no JS, and no fallback
  to the kit's own repo.
- **Simplify** — one shell script plus one TSV. The phase ORDER lives in the data file, so the script
  never hard-codes the sequence.
- **Accelerate** — the bottleneck this removes is a human answering "where is this repo up to?" before
  every task. Measured: detection runs in well under a second on this repo (13 observations, all file
  tests and greps). Before: no mechanical answer existed at all.
- **Automate** — last: the canary runs in CI on any change to the kit's tooling, so a detector that
  stops detecting fails the build.

## Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| A JS/TS implementation of the detector | rejected | The kit is POSIX sh + markdown; carrying a Node runtime to read twelve file tests recreates the dependency the consolidation exists to remove | `factory-detect.sh` + `factory-phases.tsv` |
| A model call to classify the phase | rejected | Non-deterministic, unauditable, and unnecessary — every observation is a file test or a grep | The fixed precedence rule, as data + code |
| Hard-coding the phase order in the script | removed | A process fact trapped inside a script can only be read by running it; a repo can then never be asked "what phases exist?" | The order lives in `factory-phases.tsv` |
| Falling back to the kit's own repo when cwd is not a repo | removed | It reported a confident phase for a tree the caller never named — "could not look" dressed as a finding | Refuse with exit 2; `--kit-repo` is the explicit opt-in |
| Keyword-matching `screen|page|ui` to decide "user-facing" | removed | A spec reading "no screen, internal only" contains `screen` and would demand a wireframe it explicitly does not need | The spec's own `n/a` opt-out wins; otherwise user-surface language |
| Gating the phase (acting on it) in M2 | removed | Detection and action must be separable, or a wrong detection silently drives the wrong work | M2 reports; acting is a later milestone |
| `check-phase.sh` as a gate | rejected | A phase is a fact to report, not a condition to fail a build on. Gating it would make "this repo is at ADOPT" an error | The detector reports; the gates at each rung do the refusing |

## Steps

- [x] `scripts/factory-phases.tsv` — the seven phases as data
- [x] `scripts/factory-detect.sh` — the 12 observations + the precedence rule, reporting evidence
- [x] `scripts/factory-detect.test.sh` — 16 canaries, each asserting the phase AND the evidence
- [x] Mutation-test the canary: non-repo refusal, doctor exit code, unresolved markers, wireframe demand — all caught
- [x] Fix the six defects the canary found (see Outcome)
- [x] `.agents/rules/factory-phases.md` — the doctrine, including what the detector cannot see
- [x] Wire the canary into CI (kit workflow + adopter template)
- [x] Real-repo check: detect against this repo and against a non-repo

## Review / expert sign-off

- **Security:** `n/a — read-only file tests and greps, no network, no credentials, changes nothing`
- **Performance:** `n/a — sub-second, bounded by repo size; all 12 observations are file tests`
- **Maintainability:** reviewed by the parent. Follows house patterns: a loose heading/data file rather
  than hard-coded strings, a declared escape hatch, honest limits in the source header AND the doctrine.
  Canary is mutation-tested rather than trusted.
- **UX:** `n/a — no user-facing surface` (the reader is an agent or a maintainer running a command)

## Outcome

Two classes of defect the canary caught that reading the code did not:

1. **Vocabulary false positives.** `grep -qiE 'screen|page|ui'` matched the spec text "internal tool, no
   user-facing surface" — a spec explicitly declining a wireframe demanded one. Fixed by making the
   spec's own `n/a` opt-out authoritative.
2. **The confident wrong answer.** `git rev-parse --show-toplevel` failing left `$R` empty, the arithmetic
   guard errored, and the script carried on inspecting whatever directory it was in — reporting a
   phase 1 with full evidence about a repo nobody asked about. Fixed by checking the VALUE, and by making
   the fallback opt-in.

Plus three smaller ones: an unset counter tripping `set -u` in a `-gt` test, a `grep -c` leak printing a
bare `0` into the evidence list, and `master` not being recognised as a trunk.

Every one was found by a fixture, not by reading. That is the argument for the canary being the
deliverable and the script being the by-product.
