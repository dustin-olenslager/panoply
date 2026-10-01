# Shipped: Agent-readiness module + gate (dual-mode apps)

- **Area:** `governance`  ·  **Started:** 2026-09-26  ·  **Shipped:** 2026-09-26 (PR #6, squash `f58e936`)
- **Owner:** the owner (driven by Hermes)
- **Next step (follow-up, separate repo):** apply the module to Pilot app (`an organization/pilot-app`) as the pilot — its gap list drives a plan doc in that repo, not here.
- **Roadmap initiative:** Agent-readiness doctrine (Shipped)

## Goal

Every an organization app becomes **dual-mode**: usable by a human in its own UI *and* drivable by an AI agent — either by an external harness (Hermes, OpenClaw, Claude Code) or autonomously with nothing but an LLM API key. After this ships, the kit carries a rules module stating what that requires and a CI gate that mechanically enforces the checkable part, so any repo adopting the kit inherits both.

Success = an agent picking up an adapted repo learns the three required surfaces from `AGENTS.md`, and a PR that removes idempotency or hardcodes a vendor endpoint fails CI.

**Out of scope:** applying the module to any specific app (Pilot app is a separate follow-up in its own repo); the A2A/MCP protocol specifications themselves; runtime agent behavior.

## Context

Software is acquiring a second user class. The industry has consolidated around two Linux Foundation standards — MCP (Anthropic, agent→tool) and A2A (Google, agent→agent) — but most adoption is bolting an MCP server onto an existing SaaS. The distinction here is that dual-mode is a first-class architectural constraint from day one, CI-enforced, and includes the requirement most "agent-ready" talk skips: **the app must also stand alone with only an LLM API key**, no harness and no third-party account required.

Panoply already governs Clean Architecture, doc currency, and expert review with shell-script gates that run in required CI. This module follows the same shape: doctrine in `.agents/rules/`, enforcement in `scripts/`, drift detection in CI.

## Architecture

- **Layers touched:** none in the app sense — this kit is shell scripts + markdown. The module it ships governs **Interface Adapters** in adopting repos: the HTTP handler, the MCP tool, and the A2A task handler are three adapters over the same use cases, and none may contain a business rule.
- **New ports (interfaces):** none in the kit. The module requires adopting repos to keep LLM access behind one port, per the existing `ai-features.md`.
- **Boundary data:** n/a for the kit itself.
- **Dependency direction:** the module restates the inward rule — MCP/A2A adapters sit at the edge; nothing inward names a harness, an MCP library, or an agent framework.
- **Swap test:** swapping MCP for a future protocol standard must touch only the adapter package. If a use-case file appears in that diff, the adopting repo did it wrong.

## Milestones

- [x] **M1 — doctrine module** — `.agents/rules/agent-readiness.md`: the premise (UI is a client of the API), the three surfaces, Clean Architecture placement, BYO-LLM-key config, agent identity/scopes/audit, review checklist, anti-patterns.
- [x] **M2 — enforcement gate** — `scripts/check-agent-readiness.sh`: agent card present + served, idempotency on mutations, generated MCP schemas, no vendor lock outside the adapter, scoped non-human principal, `--since` surface-drift check. Warn mode for mid-adoption repos.
- [x] **M3 — canary self-test** — `scripts/check-agent-readiness.test.sh`: builds a defective fixture and a compliant fixture in `$TMPDIR`, asserts the gate fails the first and passes the second, and that warn + `--since` modes work. Wired into the kit's own CI.
- [x] **M4 — kit wiring** — module registered in `CLAUDE.md` (`MODULE:agent` fence), `scripts/sync-agents.sh` ORDER, `README.md` module table, `adapt-claude-setup.md` (detection + prune/keep guidance), `scripts/templates/ci-verify.yml` (the step adopting repos get). Mirrors regenerated.
- [x] **M5 — verify** — shellcheck clean on the new scripts (baseline also clean); `sync-agents.sh --check` passes; canary suite green.
- [x] **M6 — CI hardening** — removed the SC2015 `A && B || C` shape the CI runner's older shellcheck rejected (local 0.11.0 was silent); strengthened canary 3 to assert warn mode still reports. Landed via squash-merge so `main` carries one commit with code + docs together (the docs gate flagged the standalone fix commit).

## Build notes

> **Build note:** 2026-09-26 — the gate's first run reported MCP and scoped-auth as **present in the panoply repo**, which has neither. Cause: `grep_tree` matched the gate's own string literals (it searches for `@modelcontextprotocol`, `scopes`, etc., and those patterns appear in its source). Fixed with a `SELF_EXCLUDE` filter covering this script, other `scripts/check-*` gates, and every generated rules mirror — all files whose job is to *name* the patterns rather than *be* them. This is why the canary self-test exists: it caught a false-positive that a single manual run on a real repo would have read as "already compliant."

> **Build note:** 2026-09-26 — the kit's own `verify.yml` does NOT run `check-agent-readiness.sh` against itself. Panoply is a shell/doc template with no agent surface; running the gate here would fail on a missing agent card and block every kit PR. It runs `check-agent-readiness.test.sh` instead, which proves the gate works on fixtures. Adopting repos get the real gate via `scripts/templates/ci-verify.yml`.

> **Build note:** 2026-09-26 — JSON validation degrades to a loud SKIP when neither `jq`, `python3`, nor `node` is available, rather than passing silently. Same doctrine as `check-docs.sh`: the gate enforces presence, not correctness, and says so.

> **Build note:** 2026-09-26 — shellcheck versions disagree. Local 0.11.0 is silent on SC2015 (`A && B || C`) in the canary; the CI runner's older shellcheck failed the PR on three instances. Removed the shape entirely (a `run_gate` helper using an `if` assignment) instead of suppressing the warning — suppression would leave the next contributor to hit the same version split. Lesson: verify shell scripts against the shellcheck version CI actually runs, not just the local one. Strengthened while in there: canary 3 now asserts warn mode still *reports* (previously a warn mode that silenced everything would have passed).

> **Build note:** 2026-09-26 — the docs gate caught this change's own fix commit: it touched `.sh` files without a CHANGELOG line, because the CHANGELOG entry lived in the earlier commit. Landed via squash-merge so `main` carries one commit with code + docs together (verified green by building the squashed tree locally and running every gate against it before merging). No history rewritten, nothing force-pushed.

## Open questions

- None blocking. For adopting repos: whether to sign A2A agent cards (only needed for cross-organization delegation) is a per-app decision, recorded in that app's plan doc.

## On ship

**Done 2026-09-26.** This folder moved into `governance/completed/` and the plan renamed to
`agent-readiness-module.md`; entry added to `completed-features.md`; worklog line appended to the
CHANGELOG `[Unreleased]`; the `in-progress.md` row removed; the `roadmap.md` initiative moved to
Shipped — all in the same commit as the fold. Durable lessons (canary-with-every-pattern-gate,
shellcheck version split) promoted into the `panoply-governance` skill.
