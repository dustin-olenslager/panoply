# Roadmap — the overall plan

> **SINGLE SOURCE OF TRUTH for this project's plans.** Every agent and contributor reads and edits
> *this* file. A new plan is a **row here** — never a new doc at the repo root, never a flat file in
> `docs/agents/`, never a top-level `<name>-plan/` directory. Detail belongs in
> `docs/agents/<area>/<feature>/plan.md`, linked from its row. Enforced by
> `scripts/check-plan-home.sh`. If you found a plan somewhere else, it is stale by definition —
> fold it into a row here and archive it.

The one canonical strategic view: the **initiatives** this project is committed to, in priority order.
One row is one initiative — a body of work that spawns several plan docs and several `in-progress.md`
queue rows — **not** a single task.

Three views, three altitudes, no overlap:
- **`roadmap.md` (this file)** — strategic. Initiatives and their band (Now / Next / Later).
- **`in-progress.md`** — tactical. The queue of what is next, which rolls up into these initiatives.
- **The worklog** (`worklog.md`, or the `CHANGELOG` `[Unreleased]` section) — the change history underneath both.

**This file owns exactly three things:** an initiative's *existence*, its *band*, and its *links down*
to the queue rows and plan docs that execute it. It does **not** restate task status — that is derived
from the linked `in-progress.md` rows — so there is almost nothing here to go stale.

**Update it in the SAME change that starts, reprioritises, or finishes an initiative:**
- New initiative → add a row to Now/Next/Later.
- Its first plan doc or queue row → link it here.
- Its last queue row ships → move the row to **Shipped** with the date, in the same commit as the ship.

## Now — in active development

| Initiative | Intent (one line) | Queue rows (`in-progress.md`) | Plan docs |
|---|---|---|---|
| The Algorithm — one pass for every effort | Question / delete / simplify / accelerate / automate, in order, on anything structural — code and non-code, in repos and in Hermes (injection + gate) | row 1 | `governance/execution-algorithm/plan.md` |

## Next — committed, not yet started

| Initiative | Intent | Depends on |
|---|---|---|
| | | |

## Later — directional, not yet committed

Records the "why we said no / not yet" so the same idea does not get re-proposed every month
(the strategic twin of `in-progress.md` → Parked).

| Initiative | Why it matters | Revisit when |
|---|---|---|
| | | |

## Shipped

Newest first. Each links to the `completed-features.md` entries that make it up — the strategic index
into the feature log.

| Initiative | Shipped | Features (`completed-features.md`) |
|---|---|---|
| Claims and comment slop | 2026-10-10 | Claims are evidence, and comments are not decoration |
| Kit self-update | 2026-10-06 | Kit self-update — a copy that knows it is stale, and an apply that tells the truth |
| Launch and verify phases gated | 2026-10-06 | The launch gate — phase 6 records a launch, and the secret scan is ON |
| PR-context guards on the gate steps | 2026-10-04 | The PR-context guard on the gate steps |
| Mechanical enforcement of the governance rules | 2026-10-03 | Scope the expert-review gate to the change, not the tree |
| Domain expertise & design in planning | 2026-10-03 | Domain expertise and design in the plan |
| Locked dev-workflow policy | 2026-10-01 | The locked dev-workflow policy in the rules and every mirror |
| Every-agent coverage: the agent | 2026-10-01 | Every-agent coverage: the agent, named and verified |
| Spec artifacts — a spec before a plan | 2026-10-03 | Spec before plan — a structural change carries a spec, and an unresolved ambiguity cannot reach the plan |
| Version resolution answers one question | 2026-10-01 | Version resolution answers one question — the source and the copied doctor agree |
| Rejections are first-class | 2026-10-01 | Rejections are first-class — the step-2 candidate list is also the rejections ledger |
| Agent-readiness doctrine | 2026-09-26 | Agent-readiness module + CI gate (dual-mode apps) |
| Mandatory PR gates + expert review + docs enforcement | 2026-08-21 | Branch protection init, expert-review CI gate, docs-gate completion, adapt command wiring |
| Docs you can prove are current | 2026-08-21 | Docs-gate — mechanical landing gate enforcing worklog currency |

<!-- Small project? An initiative and a queue row may be nearly the same thing — that is fine. Keep
     this file to a handful of rows; if an initiative needs more than a line, it has become a plan doc,
     not a roadmap entry. But do NOT delete the file: it is step 2 of the AGENTS.md onboarding contract,
     the one place any-provider agent learns the overall arc. -->
