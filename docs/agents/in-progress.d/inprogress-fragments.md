---
order: 50
id: 5
item: Queue fragments: the queue is one file per task, so two PRs that each change a queue item merge in either order with no conflict
area: governance
initiative: Queue fragments
plan: `governance/inprogress-fragments/plan.md`
status: In review
---
Dustin 2026-11-20 (dev-kit: 5 of 8 open PRs blocked by the one shared in-progress.md). Kit half in this PR: `scripts/queue.sh` (render / list / check) + canary, doctrine in `documentation.md`, the kit's own queue migrated, `queue.sh check --since` in the CI template. Next: merge, then dev-kit adopts the same files (DevKit card `inprogress-fragments` V1); backlot and frameforge are V2.
