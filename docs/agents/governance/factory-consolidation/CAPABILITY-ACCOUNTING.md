# Capability accounting — `a pilot repo` → panoply

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** complete
- **Spec:** `docs/agents/governance/software-factory/spec.md` (FR-001, FR-014, FR-015)
- **Domain & experts:** `n/a — internal governance record`

## Why this document exists

M6's acceptance test: **the accounting table has no unaccounted row.** `a pilot repo` is being archived,
and an archive is only honest if every capability it carried is either folded in, dropped with a stated
reason, or named as deliberately not built. A capability that quietly disappears is indistinguishable
from one nobody noticed was missing.

The inventory below comes from the repo's **actual file tree** (183 files, 33 top-level entries), not from
the architect's summary of it. That distinction found three real gaps the summary had papered over — see
*Gaps found by doing the accounting*.

## The table

Every top-level entry in the archived tree, with its disposition. "Folded" means a live artifact exists
in panoply **today** — not that it was considered.

| # | Capability (archived) | Files | Disposition | Landing place / reason |
|---|---|---|---|---|
| 1 | `core/domain/phase-machine.js` — the ordered phase model, per mode, with exit gates (ADR-0004) | 3 | **Folded** | `scripts/factory-phases.tsv` — the model as **data**, read by `scripts/factory-detect.sh`. Modes folded into the phase table rather than invented as a second dimension. |
| 2 | `core/domain/state.js` + `core/domain/memory-item.js` — the state schema | 2 | **Dropped** | `docs/agents/` spine **is** the state layer. A second state schema is the divergence being removed. |
| 3 | `core/use-cases/*` (brief, execute, migrate, plan, recall) + tests | 6 | **Dropped** | Thin wrappers over the dropped JS core. Their *behaviours* are the phase table's exit gates. |
| 4 | `core/ports/model-router.js` + `adapters/models/*` — model routing | 3 | **Dropped** | Model routing is not this repo's job; Hermes owns it. |
| 5 | `adapters/memory/{jsonl,obsidian}.js` + tests | 4 | **Dropped** | Memory is gbrain's job, and the spine holds project state. Not duplicated here. |
| 6 | `adapters/state/fs.js` + test | 2 | **Dropped** | Same as #2 — the spine is the state layer. |
| 7 | `adapters/gates/hermes/panoply_gate.py` + test | 2 | **Folded** | Already live in Hermes as the `panoply-gate` plugin. The harness-neutral adapter survived. |
| 8 | `adapters/gates/hermes/caveman_anchor.py` + test | 2 | **Folded** | Already live in Hermes as the caveman plugin. |
| 9 | `hooks/gates/pipeline-gate.js` — no commit before a green verify | 2 | **Folded as behaviour** | The rule lives in `git-workflow.md` + `verify.yml`; the code was a Claude `PreToolUse` hook against a dropped harness. |
| 10 | `hooks/gates/secret-gate.js` + test — block secrets at write | 2 | **Folded as behaviour** | panoply's `githooks/pre-commit` secret scan. **Note the fail-open defect** (see Gaps). |
| 11 | `hooks/gates/effect-ca-gate.js` — clean-architecture effect gating | 1 | **Folded as behaviour** | `clean-architecture.md` + the `arch-enforce` skill. |
| 12 | `hooks/gates/loop-integrity-gate.js` — detect a broken loop | 1 | **Folded as behaviour** | The factory's own phase detector reports where a repo actually is (M2). |
| 13 | `hooks/gates/context-budget.js` — checkpoint at the context ceiling | 1 | **Folded as behaviour** | The plan template's `Next step` field **is** the checkpoint, per the architect's own argument. |
| 14 | `hooks/gates/stale-main-gate.js` — refuse a stale base | 1 | **Folded as behaviour** | The factory's phase detector O-observation for a stale local ref; recorded as a hard-won lesson. |
| 15 | `hooks/gates/work-autostart.js`, `work-respawn.js`, `work-intent.js` — the no-babysit supervisor | 3 | **Not built (deferred)** | Claude-Code-process-specific (`claude -p` semantics). Recreating it for Hermes is a different build. The *rule* survives; the daemon does not. |
| 16 | `hooks/gates/lib/*` | 2 | **Dropped** | Support code for the dropped hooks. |
| 17 | `hooks/*` (anchors, session hooks) | 19 | **Dropped** | The harness wiring. `sync-agents.sh` generates every tool mirror from one source; hand-maintained wiring is what the kit deleted on purpose. |
| 18 | `agents/{orchestrator,implementer,researcher,verifier}.md` | 4 | **Partly folded** | The kit's `.agents/personas/` is the one role system. `verifier` is the one genuinely missing role — see Gaps. |
| 19 | `skills/adversary-review` | 1 | **Folded (already present)** | Live as a Hermes skill; named in the kit's review phase. |
| 20 | `skills/arch-enforce` | 1 | **Folded (already present)** | Live as a Hermes skill; wired into 4 repos. |
| 21 | `skills/edge-hunter` | 1 | **Folded** | Landed in Hermes as a skill (review-phase specialist, pre-adversarial). |
| 22 | `skills/token-discipline` (+ `references/full.md`) | 2 | **Folded** | Landed in Hermes as a skill. |
| 23 | `skills/maintain-mode` | 1 | **Folded** | Landed in Hermes as a skill. |
| 24 | `skills/optimize-loop` | 1 | **Folded** | Landed in Hermes as a skill. |
| 25 | `skills/caveman*` (4 files) — the terse-output style | 4 | **Dropped (duplicate)** | The caveman plugin is already live in Hermes. A vendored copy would be a second source. |
| 26 | `skills/{clean-architecture,brief,execute-phase,recall-memory}` | 4 | **Dropped (duplicate)** | Each duplicates a kit rule or a Hermes skill. |
| 27 | `skills/effect-ts` | 1 | **Dropped** | Stack-specific to a codebase this kit does not own. |
| 28 | `scripts/leak-scan.sh` + the deny-list pre-push guard | 2 | **Not built (named gap)** | Genuinely valuable and the kit does **not** have it. Recorded here as an open gap rather than silently lost. See Gaps. |
| 29 | `scripts/run-work.sh`, `run-work.ps1`, `phalanx-watch.sh`, `bot-handoff.sh`, `notify.sh`, `phalanx-gc.sh`, `phalanx-project.sh`, `phalanx-record-preview`, `phalanx-verify`, `seed-task.sh`, `wip-preserve.sh` — the supervisor loop | 11 | **Not built (deferred)** | Same as #15. The supervisor mechanic, not the rules. |
| 30 | `scripts/{merge-claude-md,merge-settings}.mjs` + `claude-md/` | 3 | **Dropped** | Hand-rolled mirror merging. `sync-agents.sh` generates mirrors and CI fails if one is committed — a stronger guarantee than merging. |
| 31 | `scripts/check-docs.sh`, `check-expert-review.sh`, `plan-contract-drift.sh`, `phalanx-docs-reconcile.sh` | 4 | **Folded** | The gate idea landed in panoply with **stronger** implementations (change-scoped, canaried, mutation-tested). |
| 32 | `scripts/install-guards.sh`, `init-repo-protection.sh` | 2 | **Dropped** | Superseded by `panoply.sh apply`, whose dispositions are truthful and whose drift detection is real. |
| 33 | `scripts/run-tests.js` | 1 | **Dropped** | Node test runner for a JS core that is not being carried. |
| 34 | `.claude/`, `.cursor/`, `.clinerules`, `.windsurf/`, `GEMINI.md`, `CONVENTIONS.md`, `.github/copilot-instructions.md` | 35 | **Dropped** | One vendor wiring each. `sync-agents.sh` generates all of them from one canonical source. |
| 35 | `commands/{work,work-loop}.md` | 2 | **Dropped** | Slash-command definitions for the dropped harness. Their behaviour is the phase model. |
| 36 | `docs/adr/*` (6 ADRs) | 6 | **Folded as history** | Copied into this folder's `adr/`. The decision log for the thing being folded in — deleting it destroys the *why*. ADR-0004 is the evidence for the no-JS-port argument. |
| 37 | `docs/claude/` spine | 12 | **Dropped (superseded)** | The old-layout twin of `docs/agents/` — the very thing `panoply.sh migrate` exists to translate away from. |
| 38 | `state/*.json` | 3 | **Dropped** | The state schema in #2. |
| 39 | `policy/risk-policy.json` + `configs/.dependency-cruiser.js` | 2 | **Dropped** | Stack-specific config. `arch-enforce` owns generating it. |
| 40 | `PROMPT.md`, `TASKS.template.md`, `.loop-access.env.example` | 3 | **Dropped** | `PROMPT.md` is the paste-into-Claude prompt the anchors replaced. `TASKS.md` is a **second backlog** beside `in-progress.md` — the exact one-backlog problem phalanx's own ADR-0006 flags. |
| 41 | `install.sh`, `install.ps1`, `uninstall.sh`, `settings/` | 4 | **Dropped** | A second installer. `panoply.sh` is the one. |
| 42 | `githooks/` | 2 | **Partly folded** | The secret-scan hook, with the fail-open defect noted. |
| 43 | `README.md`, `LICENSE`, `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`, `.gitignore` | 6 | **Dropped (repo metafiles)** | Belong to the archived repo. A pointer README replaces the README. |
| 44 | `kapsel` (separate private repo, already archived) | — | **Stays archived** | Its *idea* — point the machine at a repo and it drives the loop — **is** the factory's walk-up discovery + phase pickup. Its *implementation* (queue + panel + async driver) is a substrate not being rebuilt: the front door is a skill, not a panel. Recorded so nobody re-proposes rebuilding the panel. |

**Unaccounted rows: 0.** Every top-level entry in the 183-file tree appears above.

## Gaps found by doing the accounting

The architect's summary said four skills still needed folding and the ADRs still needed copying. Checking
the real tree against the real kit found the work not done — which is what an accounting is *for*:

1. **The ADRs were never copied.** The plan said "copy to `adr/` as history"; the folder did not exist.
   Now copied — the decision log is the only record of *why* the JS core was dropped.
2. **Four skills were marked "folded" in intent but landed nowhere** — `edge-hunter`,
   `token-discipline`, `maintain-mode`, `optimize-loop` are all real, non-duplicate content, and none
   existed in Hermes. Landed as Hermes skills (they belong there, not in the kit: the kit ships rules for
   repos, Hermes ships skills for agents).
3. **The leak guard was dropped in substance and kept only in prose.** `leak-scan.sh` is genuinely
   valuable, the kit genuinely lacks it, and the plan recorded it as "kept as an idea" — which is how a
   capability disappears while the table still looks complete. Named here as an explicit open gap (row
   28) rather than left as an aspiration.

## Open gaps (deliberately not built — not lost)

| Gap | Status | Revisit when |
|---|---|---|
| A deny-list **pre-push leak guard** (row 28) | not built; kit lacks it | when a repo the kit governs holds something worth gating on push |
| The **no-babysit supervisor** (rows 15, 29) | deferred; `claude -p`-specific | when the equivalent serves Hermes directly |
| A `verifier` **persona** (row 18) | not built; 4 persona files from the archived repo mapped onto no kit role | when the review phase has a step needing it by name |
| The **`_src`-is-own-root blind spot** (from M2/M3 work) | known limitation of `panoply.sh apply`'s drift detection | when a normal adopted repo needs genuine drift detection |

## What this document is not

It is not evidence that the fold-in is complete in the sense of *working*. It is evidence that **every
capability was decided**, and where the decision was "folded", a named live artifact carries it. Whether
each folded artifact behaves correctly is what M1–M5's gates and canaries are for.
