# Plan: feature-completeness gate in the kit

- **Area:** `governance` · **Started:** 2026-11-18 · **Status:** In review
- **Owner:** the dev-kit faster-CI lane, for Dev-kit Master
- **Next step:** merge when green; backlot (10-ton-productions/backlot#638) and frameforge (10-ton-productions/frameforge#598) carry the same fix in their own copies.
- **Spec:** none. One gate script and its canary; no new feature surface.

## What

`scripts/check-feature-completeness.sh` lived only in dev-kit and hand copies in backlot and frameforge. Its
opt-out `User-facing: no - <reason>` refused "a read API" (the reason had to open with three letters) and a
bare `no` produced a message listing all five fields as MISSING, which hid the real fault. The kit now ships
the gate so `panoply.sh` can carry it.

## Design

- Reason: 3+ characters, starting and ending with a letter or digit, after `-`, `:`, `–` or `—`. Dashes are
  an alternation, because a bracket matches single bytes of a UTF-8 dash in a C locale.
- A bare or 1-char reason prints `failing line: <the line>` and one MISSING item, the reason. A bare `no`
  with every field filled still passes.
- The rule module stays in dev-kit (`.agents/rules/feature-completeness.md`); repos opt in through
  `.github/gates.json` `feature_completeness`.

## Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| A minimum word count for the reason | **rejected** | "n/a" style reasons are already refused by the 3-character floor; counting words adds a failure mode for no gain. |
| Porting the rule module now | **not built** | Kit adopters outside 10 Ton have no feature-completeness rule yet; the script alone is inert without `gates.json` opt-in. |

## Milestones

- [x] Gate and canary in the kit, cases 4b-4g — `scripts/check-feature-completeness.sh`, `scripts/check-feature-completeness.test.sh`
- [x] Kit CI self-test — `.github/workflows/verify.yml`
- [x] Expert review: C-locale dashes, bare `no` with filled fields, and the merge train parser all checked — `scripts/check-feature-completeness.test.sh`
- [ ] Adopters synced: backlot and frameforge PRs merged

## Launch

- **Launched** by merging this PR. **Rollback:** revert it; adopters keep their own copies.
