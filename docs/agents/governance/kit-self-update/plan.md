# Plan: Make the kit updateable — self-detection, a truthful apply, recoverable overwrite, and a migrate path

- **Area:** `governance`  ·  **Started:** 2026-10-03  ·  **Status:** In progress
- **Owner:** the owner (approved scope and priority order) / Hermes (drafting + building)
- **Next step:** run the local gate suite (`sh scripts/panoply.test.sh`, `for t in scripts/*.test.sh; do sh $t; done`, `sh scripts/sync-agents.sh --check`, `sh scripts/check-docs.sh --since origin/main`, `shellcheck scripts/panoply.sh scripts/*.sh`), test `migrate` against the throwaway adopter copy at `<scratch>/`, then open exactly ONE PR on `fix/self-update`.
- **Roadmap initiative:** Kit self-update (new initiative — see `../../roadmap.md`).
- **Spec:** `spec.md` in this folder.

## Goal

After this ships, an adopted repo can pull in kit fixes **deliberately and observably**. A copy of the
kit's doctor that is behind the kit can tell that IT is behind (not just that the repo is), refuses to
print a clean bill of health it cannot justify, `apply` prints a per-file truth about what it changed
and stops stamping repos it did not actually bring current, a forced overwrite always leaves a
recoverable backup, and a documented `migrate` path carries an old-layout repo onto the current layout
once, reviewably.

How we know it worked: on an old-layout adopter fixture, the repo's own doctor exits non-zero
(self-stale, new code 15) instead of `OK` exit 0 — the owner-verified false green flips; `apply` on a
drifted repo prints `DRIFTED`/`KEPT` and does NOT advance the stamp to current; `apply --force-scripts`
leaves a `.panoply-bak` and names it; `migrate` reports the translation before applying it. Each is
proven by an adversarial canary that goes red under mutation.

**Out of scope:** any auto-pull or network fetch (doctrine: a rule change is REVIEWED, not silently
overwritten); changing the 10–14 exit-code meanings; rebuilding the rule corpus; migrating a real
adopter repo (fixtures only).

## Context

- The kit is adopted by ~11 product repos, each keeping its OWN copy of `scripts/panoply.sh`,
  `sync-agents.sh` and the rule modules. Nothing brings a fix forward.
- Owner-measured: 9 of 11 adopters are on the OLD layout (`docs/claude/` + `.claude/rules/`) while the
  current kit requires `docs/agents/` + `.agents/rules/`. The adopter's own (old) doctor validates
  against ITS OWN embedded old-layout expectation, so it reports `OK — kit v1.4.0 applied and current`
  exit 0 while the current doctor reports `HALF-APPLIED` exit 11. **Reproduced in this worktree** on
  a pilot repo: own doctor exit 0, current doctor exit 11.
- Owner-measured: `apply` silently re-stamps drifted repos. **Reproduced**: on a copy of a pilot repo,
  `apply` kept `scripts/panoply.sh` (`KEPT`), changed no managed script to the kit's bytes, and still
  rewrote `kit_sha` — the stamp certified code that was not installed. (It did overwrite the *version*
  to `unreleased`, which then made the copied doctor report STALE — a different symptom of the same
  "stamp certifies the attempt" defect.)
- Owner-measured: `--force-scripts` overwrote locally-edited scripts with no `.bak`, and the kit's own
  source comment names a pilot repo's local `check-docs.sh` work as exactly what it would destroy.
- The design constraint that shapes everything: the doctor cannot detect that IT is the stale party,
  because it validates against its own embedded expectations. The fix requires the copy to compare its
  embedded expectation against a kit source it can reach (the existing `_canonical_kit_root` search),
  and — when it cannot reach one — to refuse to fail open.

## Architecture

- **Layers touched:** none of the product Clean-Architecture layers — this is the kit's machine
  surface (`scripts/`), a shell toolchain, not an application. It ships no runtime.
- **New ports (interfaces):** none. The doctor's "port" is its CLI contract (`check` exit codes).
- **Boundary data:** the machine-readable `STATUS<tab>detail` line from `_inspect`, extended with a new
  `selfstale` status.
- **Dependency direction:** the copy depends on the kit source only through the existing optional
  `_canonical_kit_root` search; no new outward dependency is introduced.
- **Swap test:** the one vendor touchpoint is the git CLI for version resolution, already isolated in
  `_kit_version`/`_kit_sha`; this change adds no new one.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — asked by the kit owner (the owner), serving one constraint: an adopted repo must be able
  to receive kit fixes. Every requirement below traces to an owner-measured consequence, not to a
  hypothetical. The four fixes are ranked by the owner, and the rank is kept.
- **Delete** — see the Deletion candidates table. The most important deletion candidate is **the
  version-string comparison for staleness**: a copy cannot tell it is stale by comparing version
  strings, because between releases both are `unreleased`. The whole "compare the running copy's
  version against the source" shape the prompt suggested is DELETED in favour of comparing an embedded
  **generation marker**. Also deleted: auto-pull, `.bak` numbering schemes, a separate `update`
  subcommand (folded into `migrate`).
- **Simplify** — one embedded constant (`_EXPECTED_LAYOUT`) plus one comparison, not a manifest of
  expected files. `apply` gains one disposition variable and one stamp guard, not a new reporting
  subsystem. `migrate` is `apply` with a layout translation step, reusing the same no-clobber loop.
- **Accelerate** — measured: the false-green detection is one `cmp`-free string compare plus one
  already-existing `_canonical_kit_root` probe (~2 `[ -f ]` tests). It adds no measurable cost to the
  hot path (`check` on a repo takes the same two git subprocesses it already did). The bottleneck this
  addresses is not speed but **review latency**: an adopter currently cannot act on a kit fix at all,
  so the round trip is unbounded. After: `migrate` + `apply` + `check` is a bounded, reviewable PR.
- **Automate** — nothing new is automated. Explicitly NOT built: an auto-pull or a self-updating
  doctor. The owner's doctrine is that a rule change is reviewed, not silently overwritten; automating
  the pull would make permanent the very silence this change removes.

### Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| Version-string comparison as the staleness tell | yes | Between releases both the copy and the source are `unreleased`; two generations can share the string, so the comparison detects nothing in the exact case that matters (the kit between tags). | Compare an embedded **generation marker** (`_EXPECTED_LAYOUT`), which changes exactly when the layout expectation changes. |
| Auto-pull / fetch-the-kit-from-the-network | yes | The owner's doctrine: a rule change is REVIEWED, not silently overwritten. An auto-pull automates the silence. | A deliberate `migrate` path the maintainer runs and a reviewer sees in a PR. |
| A separate `update` subcommand distinct from `migrate` | yes | Two commands that both "bring the kit forward" is two shapes for one requirement; the prompt listed them as alternatives and asked which is right. `migrate` (layout translation) is the distinct, reviewable operation; a plain refresh is `apply --force-scripts`, already documented. | One `migrate` subcommand; `apply` remains the refresh. |
| Numbered/rotating backup scheme (`.bak.1`, `.bak.2`, timestamps) | yes | A collision-safe single path is enough; a rotation scheme is machinery for a case that does not occur (a forced refresh is rare and deliberate). | `.panoply-bak` beside the file, suffixed only on collision. |
| A whole-file byte-comparison of the two `panoply.sh` copies | yes | A cosmetic local edit to a copy would flip the verdict and produce a false red — the always-red failure the kit already fought once (see CHANGELOG case 11b). | Compare the embedded expectation marker only. |
| Re-litigating the 10–14 exit-code table | yes | Stable codes are a contract other tooling keys on. | Add code 15 for the new self-stale state; change nothing existing. |
| The whole request | no | Every clause maps to an owner-measured consequence (false green, dishonest stamp, unrecoverable overwrite, no update path). The request is the fix. | — |

## Milestones

- [ ] **M1 — Self-detection (US-1).** Embed `_EXPECTED_LAYOUT` in `scripts/panoply.sh`; add a
  `selfstale` inspect state (exit 15) computed by comparing the copy's marker against a reachable kit
  source's; make an unreachable source a loud "cannot verify" rather than a green. Canary: stale copy
  reports self-stale, matching copy unchanged, no-source refuses green. Mutation-proven.
- [ ] **M2 — Truthful apply (US-2).** Per-file `ADDED`/`KEPT`/`DRIFTED` dispositions; a `_drifted`
  flag; `cmd_stamp` refuses to write a current stamp when `_drifted=1` (writes a non-current marker).
  Canary: drifted repo prints drift and stamp is not current. Mutation-proven.
- [ ] **M3 — Recoverable force (US-3).** `--force-scripts` writes `.panoply-bak` before overwriting and
  prints the path; collision-safe suffix; no backup when nothing is overwritten. Canary asserts the
  backup bytes and the printed path. Mutation-proven.
- [ ] **M4 — Migrate path (US-4).** `migrate` subcommand: detect an old-layout repo, report the
  translation it will perform, seed the new layout with the same no-clobber contract, then delegate to
  `apply`. Canary: reports translation, does not clobber, reaches a non-self-stale state. Mutation-proven.
- [ ] **M5 — Docs, CHANGELOG, mirrors, cleanup.** Update `README.md`, `AGENTS.md` if needed, the
  `adapt-agents-setup` command if needed, `CHANGELOG.md` `[Unreleased]`, regenerate mirrors
  (`sh scripts/sync-agents.sh`), wire the canary into CI if it is not already covered, and run the
  full gate suite.

## Open questions

_(none — resolved in the spec)_

## Build notes

> **Build note:** 2026-10-03 — the prompt's literal suggestion for fix 1 was "compare the running
> copy's stamp/version against the kit source it can reach". Measured first, as the Algorithm requires:
> between releases BOTH sides report `unreleased`, so the comparison is a no-op in exactly the case
> the false green occurs. The generation marker (`_EXPECTED_LAYOUT`) is the shape that actually
> changes when the doctor's embedded expectation changes, which is what "this copy is stale" means
> here. Recorded so the deletion is not re-proposed.
