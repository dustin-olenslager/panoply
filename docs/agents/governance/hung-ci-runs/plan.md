# Plan: hung CI runs fail fast

- **Area:** `governance` · **Started:** 2026-11-18 · **Status:** In review
- **Owner:** the dev-kit faster-CI lane, for Dev-kit Master
- **Next step:** merge when green. Adopters copy the template change on their next kit sync.
- **Spec:** none. Job limits in CI files, and one rule line; no feature surface.

## What

Dustin, 2026-11-18: "Figure out what caused the deployment bottleneck and make sure that dev-kit doesn't allow that in the future. We need to keep the code flowing." A Backlot main verify hung 85 min under GitHub's 6 h default job limit and kept the deploy gate shut. The rule now says a hung main run is cancelled and rerun (dustin-olenslager/panoply#26). This change adds the job-level limit, so a hang fails on its own even where no watchdog runs.

## Design

- Every job sets `timeout-minutes` near 3x its median. Jobs that take under a minute get a 5-10 minute floor, because runner start and checkout jitter would fail anything tighter.
- Kit `verify.yml`: verify 10, size 5, self-tests 10. Measured medians on ubuntu-latest were 0.2, 0.1 and 0.8 min (max 1.1).
- Template `scripts/templates/ci-verify.yml`: 30/5/10 for adopters, with a comment to set 3x their own median.

## Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| A per-step timeout on every step | **rejected** | The job limit catches the same hang; per-step limits add one number per step to keep current. |

## Milestones

- [x] Kit and template set `timeout-minutes` on every job — `.github/workflows/verify.yml`, `scripts/templates/ci-verify.yml`
- [x] Expert review (independent subagent, diff only): approve. Placement is at job level, the YAML parses (10/5/10 and 30/5/10), and `size` keeps its `if:`. Fixed: the CHANGELOG no longer claims 3x for jobs that use the floor — `scripts/templates/ci-verify.yml`
- [ ] Adopters synced (backlot verify gets 60 in 10-ton-productions/backlot#642)

## Launch

- **Launched** by merging. **Rollback:** revert; a job then falls back to GitHub's 6 h default.
