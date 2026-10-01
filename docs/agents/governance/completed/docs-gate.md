# Plan: docs-gate — the landing gate that makes docs update with every edit

- **Area:** `governance`  ·  **Started:** 2026-08-21  ·  **Status:** In progress
- **Owner:** the owner
- **Next step:** M3 — verify the gate fires (negative + positive case) against the kit repo, then ship (archive plan, completed-features entry, roadmap move).
- **Roadmap initiative:** Docs you can prove are current (see `../../roadmap.md`).

## Goal

After this ships, a code change **cannot land** without its documentation update in the same commit —
for every agent, in every tool, with no prompting. The kit's existing "same-change update contract"
(`.agents/rules/documentation.md`) is currently enforced by *discipline* and detected *after the fact*
by `/audit-agents-setup`. This feature moves the deterministic subset of that audit from **after →
before**: a mechanical gate that fails the commit/CI when code changed but the docs did not.

**How we know it worked:** a commit that changes a non-markdown file but not the worklog target fails
`sh scripts/check-docs.sh` with a message naming the offending commit and the missing doc update.

**Out of scope (deliberate):**
- **Agent-authored "self-updating" docs** — a background pass that writes docs from a diff fabricates
  the "why" (the only part that matters) and loses the change-context the same-change contract exists
  to preserve. The agent writes docs *in-context*; the gate enforces that it did.
- **Deriving docs from code** — impossible generically for a language-agnostic kit.
- **Hosted platform / MCP / search index** — violates the no-hosted-dependency premise.
- **The Claude-only precondition hook** (blocking an edit before it is typed) — a separate, later,
  opt-in decision; it is the one mechanism that cannot be mirrored to non-Claude agents.

## Context

Panoply is a git-based agent-governance kit: a template repo copied into any project, binding every
coding agent to shared rules. It already ships a docs knowledge system (`docs/agents/`: roadmap,
in-progress, worklog, completed-features, architecture, key-patterns, infrastructure) and a
**same-change update contract** — docs updated in the same commit as code — enforced by review and
`/audit-agents-setup` (which detects shipped-but-unlogged work, stale queue rows, drifted layer maps).

The gap: the contract is honored by discipline and detected *after* the fact. Nothing makes it
*impossible* to forget. This feature adds the mechanical gate.

The kit is **language-agnostic and provider-neutral**, so the gate must use only `git` + `grep` +
the docs' own structure — no code parsing, no runtime dependency, POSIX `sh` (matching
`scripts/sync-agents.sh`).

## Architecture

- **Layers touched:** Frameworks & Drivers only. The gate is a shell script (a build/CI concern) that
  reads git history and the docs tree. It introduces no domain logic, no ports, no DTOs — it is a
  mechanical check, not a business rule.
- **New ports (interfaces):** none.
- **Boundary data:** none.
- **Dependency direction:** the script depends only on `git`, `grep`, `awk`, and the filesystem —
  all outermost. Nothing inward depends on it.
- **Swap test:** the "vendor" is git itself; replacing the check with any other VCS's equivalent
  touches only this script and the two templates that invoke it. No rule or doc file changes.

## The gate's rule (the one invariant)

**A commit that changes any non-markdown file must also change the worklog target in the same commit.**

- **"Code"** = any changed file that is not `*.md`. Source, config, schema, scripts, CI — all
  non-markdown — require a worklog line. Markdown files (the docs themselves) are exempt from the
  *mandatory* line (a doc-only change is encouraged to log, but not gate-blocked).
- **Worklog target** = `CHANGELOG.md`/`HISTORY.md` `[Unreleased]` if present, else
  `docs/agents/worklog.md` — auto-detected, overridable via `DOCS_WORKLOG`.
- **Merge commits are skipped** (they are not "changes" in the meaningful sense).

This is deterministic, language-agnostic, and matches the doctrine ("source/config/schema/shipped-docs
earn a line"). It enforces **presence**, not **correctness** — a garbage line passes; that is a review
problem, not an automation problem, and it is the honest limit of any git-native kit.

## Milestones

- [ ] **M1 — the gate** — `scripts/check-docs.sh`: the worklog-currency check (the one invariant). Wire into `scripts/templates/pre-commit` and `scripts/templates/ci-verify.yml`.
- [ ] **M2 — sharpen the non-negotiables** — `AGENTS.md` and `.agents/rules/documentation.md`: the
  same-change contract becomes a MUST with the gate named as its mechanical enforcement.
- [ ] **M3 — dogfood + verify** — update `CHANGELOG.md`, `roadmap.md`, `in-progress.md` in the same
  commit (the contract applied to itself); `chmod +x` the script; run it against the kit repo's own
  history to prove it fires.

## Open questions

- [ ] _none blocking_ — the worklog-target auto-detection prefers `CHANGELOG.md` over
  `docs/agents/worklog.md`; the kit ships both (worklog.md is the template for repos without a
  changelog). Confirm this preference is correct for the kit's own repo.

## Build notes

> **Build note:** 2026-08-21 — the "before code is touched" precondition is not literally achievable
> provider-neutrally; the earliest enforceable point for non-Claude agents is the commit. The landing
> gate is the provider-neutral floor; a Claude-only `PreToolUse` precondition is a later opt-in.

## On ship

Move this folder into `governance/completed/`, rename to `docs-gate.md`, add a `completed-features.md`
entry, append the final worklog line, remove the item from `in-progress.md`, move the `roadmap.md`
initiative, and promote the "presence-not-correctness" limit into `architecture.md` — all in the same
commit.
