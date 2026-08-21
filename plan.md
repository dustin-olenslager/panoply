# Master Plan: Panoply Optimization — Mandatory PR Gates + Expert Review + Docs Enforcement

**Goal:** Make Panoply's enforcement plane binding by default — mandatory branch protection, required CI checks, structured expert review, and mechanical docs gate — all provider-neutral, zero hosted deps.

**Mode:** autonomous (auto-chain) — drive to completion across sessions.

---

## Phase 1 — Branch Protection Init Script
- **Scope:** Create `scripts/init-repo-protection.sh` — interactive `gh` CLI command that configures branch protection on default branch (require PR, require `verify` check, forbid force-push, forbid direct push). Wire into adapt command Phase 10.
- **Deps:** none
- **Subagents:** implementer (write script), verifier (test against temp repo)
- **Exit:** Script runs, configures protection on a test repo, adapt command reports success/failure in Phase 5
- **Status:** pending

## Phase 2 — Expert-Review CI Gate Script
- **Scope:** Create `scripts/check-expert-review.sh` — POSIX sh script for CI that verifies via grep: plan.md exists, checklist.md has items, adr.md has new section since base, PR description has ≥2 persona sign-offs. Trivial escape via `trivial` label or `trivial:` commit prefix.
- **Deps:** Phase 1 (shared CI patterns)
- **Subagents:** implementer (write script), verifier (test against sample PRs)
- **Exit:** Script passes/fails correctly on fixture PRs; wired into `ci-verify.yml` template
- **Status:** pending

## Phase 3 — Policy Updates (workflow.md + AGENTS.md)
- **Scope:** Update `.claude/rules/workflow.md` and `AGENTS.md` with expert-review policy: when required, personas, trivial escape hatch, ADR requirement. Keep Clean Architecture layer mapping (policy in use-case layer, gate in framework layer).
- **Deps:** Phase 2 (policy references the gate)
- **Subagents:** implementer (edit rules files)
- **Exit:** Rules updated, sync-agents.sh --check passes, provider mirrors regenerated
- **Status:** pending

## Phase 4 — Complete Docs-Gate (M3)
- **Scope:** Finish in-progress docs-gate: chmod +x check-docs.sh, run against kit repo history, verify it fires on negative/positive cases. Archive plan, update roadmap, completed-features, worklog.
- **Deps:** none (already M3 of 3 in progress)
- **Subagents:** verifier (run gate)
- **Exit:** Gate passes on compliant commits, fails on non-compliant; roadmap moved to Shipped
- **Status:** pending

## Phase 5 — Dogfood Full Optimization on Kit Repo
- **Scope:** Apply all changes to this repo: enable branch protection via init script, add expert-review gate to CI, verify docs-gate fires, ship via PR that passes all gates.
- **Deps:** Phases 1–4
- **Subagents:** orchestrator (this thread) — commits, pushes, verifies
- **Exit:** Kit repo has green CI with all gates; PR merged; roadmap initiative moved to Shipped
- **Status:** pending

## Phase 6 — Adapt Command Integration
- **Scope:** Update `.claude/commands/adapt-claude-setup.md` Phase 10 to run `init-repo-protection.sh` interactively and report result. Update Phase 5 report to include expert-review gate status.
- **Deps:** Phases 1–3
- **Subagents:** implementer (edit adapt command)
- **Exit:** Fresh project running `/adapt-claude-setup` gets interactive branch protection setup + expert-review gate wired
- **Status:** pending

---

## One-Way Doors (⚠)
- **Phase 5 merge to main** — requires all gates green, operator confirm
- **Phase 6 adapt command change** — affects all future adoptions; test thoroughly

## Operator Sign-Off Gates
- Phase 5: Confirm kit repo merge to main
- Phase 6: Confirm adapt command changes before shipping kit update

---

## Checklist
- [ ] Phase 1: `scripts/init-repo-protection.sh` created and tested
- [ ] Phase 1: Adapt command Phase 10 wires the script
- [ ] Phase 2: `scripts/check-expert-review.sh` created and tested
- [ ] Phase 2: `ci-verify.yml` template includes expert-review job
- [ ] Phase 3: `workflow.md` updated with expert-review policy
- [ ] Phase 3: `AGENTS.md` updated with expert-review policy
- [ ] Phase 3: `sync-agents.sh --check` passes
- [ ] Phase 4: Docs-gate M3 complete — gate fires, roadmap shipped
- [ ] Phase 5: Kit repo branch protection enabled via script
- [ ] Phase 5: Kit repo CI has expert-review gate + docs-gate + arch gate
- [ ] Phase 5: Optimization PR passes all gates, merged to main
- [ ] Phase 6: Adapt command updated and verified
- [ ] All: Roadmap initiative moved to Shipped, completed-features entry added