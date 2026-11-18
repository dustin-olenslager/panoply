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

## Review — opt-out reason fix (2026-11-18)

An independent CI/gates reviewer (a subagent with no prior context) read only the four diffs (10-ton-productions/dev-kit#464, dustin-olenslager/panoply#25, 10-ton-productions/backlot#638, 10-ton-productions/frameforge#598), ran the canaries and tried bodies under `LC_ALL=C` and `C.UTF-8`. Verdict: approve with fixes.

- **Blocking:** a 2-character reason passed (`no - ab`, `no-op`): the reason pattern allowed an empty middle, so the merge train would let it through. Fixed: the middle is now one or more characters; canary case 4d adds `no - ab`.
- **Should-fix:** an unedited PR template matched the opt-out line through its own comment text, so a user-facing PR left blank got "a reason" instead of its five empty fields; and `<!-- User-facing: no - docs -->` passed. Fixed: both patterns are anchored to a bullet or heading line start; canary cases 4h and 4i.
- **Accepted:** `[[:alnum:]]` is locale-dependent, so a non-ASCII reason fails in a C locale; reasons are written in English. `n/a` and `tbd` meet the 3-character rule as stated.
- **Checked fine:** CRLF bodies, all four separators in both locales, the `yes / no - reason` template line, a bare `no` with filled fields, `nothing` is not `no`, the merge-train parser (`scripts/vps/merge-train/completeness.py` in dev-kit) stays comma-safe, and the four copies share identical logic.

## Launch

- **Launched** by merging this PR. **Rollback:** revert it; adopters keep their own copies.
