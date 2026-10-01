# Plan: OpenCode coverage — name and verify, do not mirror

- **Area:** `governance`  ·  **Started:** 2026-09-19  ·  **Status:** In review
- **Owner:** the owner (via OpenCode audit session, koforje-2026-09 Gate 3 Phase A / W1)
- **Next step:** merge PR `docs/opencode-native-coverage`; on merge, fold the queue row and move
  this folder to `governance/completed/` per ship convention.
- **Roadmap initiative:** Every-agent coverage: OpenCode

## Goal

The kit's coverage claims name OpenCode, and the mechanism is recorded: OpenCode is bound by the
refilled `AGENTS.md` hub natively, exactly like the agent — it needs no generated mirror file. After
this ships, a reader of README/sync-agents.sh knows OpenCode is covered and why. We know it worked
when `sync-agents.sh --check` still passes (comment-only change) and no adapted repo needs a
re-sync for coverage.

**Out of scope:** emitting an `OPENCODE.md` or `.opencode/AGENTS.md` mirror — evaluated and
rejected: OpenCode does not load `OPENCODE.md`, so such a mirror would bind nothing while adding
a stale surface. Also out of scope: any change to mirror generation behavior.

## Context

The koforje consolidation audit (`/config/audits/koforje-2026-09/`, Seat 4 memo) found that
`sync-agents.sh` emits 6 vendor mirrors and proposed adding OpenCode as "one more mirror."
Execution-phase verification against the script and against OpenCode's actual loader corrected
this: OpenCode reads repo-root `AGENTS.md` natively (live proof: the audit session itself runs
in OpenCode under AGENTS.md-derived instructions), and the script already refills AGENTS.md
inline between the `PANOPLY:RULES:BEGIN/END` markers "so AGENTS.md-native tools get the full
governance with no @-imports" (sync-agents.sh header). The real gap was documentation: the
README's tool list and the script header named the agent among mirror-file tools and never named
OpenCode, leaving an AGENTS.md-native reader unable to tell whether OpenCode was covered.

## Architecture

None — comment/markdown-only change. No mirror generation, no CI shape, no rule bodies touched.

## Verification

- `sh scripts/sync-agents.sh --check` passes unchanged (no generated file depends on the header
  comment).
- `scripts/check-docs.sh` satisfied: non-md file touched (`sync-agents.sh`) with the worklog
  target (`CHANGELOG.md` `[Unreleased]`) updated in the same commit.
- `scripts/check-plan-home.sh` satisfied: initiative row in `roadmap.md`, queue row in
  `in-progress.md`, this plan doc linked from both.
