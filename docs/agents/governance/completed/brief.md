# Brief: Panoply Framework Optimization

**Intent:** Optimize the Panoply agent-governance kit by adding mandatory PR gates, provider-neutral documentation enforcement, and a structured expert-review process — while preserving its language-agnostic, zero-hosted-dependency premise.

**Constraints:**
- Must remain provider-neutral (any agent)
- Must remain language-agnostic (no runtime deps, POSIX sh only)
- Must keep "prune don't leave blanks" — no half-filled modules
- Must keep Clean Architecture as the premise, not a module
- Must keep docs in the repo (docs/agents/), not in chat history
- CI/pre-commit is the only cross-tool enforcement plane

**Success criteria:**
1. Every project using Panoply gets mandatory PR gates (branch protection + required CI status checks) by default — not optional
2. Documentation updates are mechanically enforced at commit/CI (the docs-gate already in progress completes this)
3. A structured expert-review process exists for non-trivial changes, with named personas and escalation rules
4. The optimization plan itself ships using the same gates it proposes
5. No new hosted dependencies, no vendor lock-in, no tool-only features in the shared contract

**Scope:**
- Phase 1: Harden the CI/pre-commit templates to require branch protection + required checks (not just provide them)
- Phase 2: Complete and ship docs-gate (already M3 of 3)
- Phase 3: Design and implement expert-review protocol (named personas, conflict surfacing, ADR recording)
- Phase 4: Add the expert-review protocol to the adapt command so new projects get it by default
- Phase 5: Dogfood the full optimization on the kit repo itself

**Out of scope:**
- Hosted platform / MCP / search index
- Agent-authored self-updating docs
- tool-only PreToolUse preconditions (provider-neutral floor only)
- Any change that makes the kit opinionated about a specific language/framework beyond what clean-architecture.md already requires