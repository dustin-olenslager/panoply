# Completed Features

The shipped log. One entry per feature, newest first. Read this before proposing work — it is the
cheapest way to avoid rebuilding something that already exists.

Add an entry when a feature is tested and signed off, at the same time you move its folder into
`<area>/completed/`.

## Entry format

```markdown
### <Feature name> — YYYY-MM-DD
- **What shipped:** one or two sentences, in terms of what a user or caller can now do.
- **Area:** `<area>`
- **Archived plan:** `<area>/completed/<feature>/<renamed-file>.md`
- **Notable decisions:** anything that constrains future work; link the ADR in `architecture.md`.
- **Known gaps:** what was deliberately left out, so the next person does not read it as a bug.
```

---

### EXAMPLE — Paginated records list — 2026-01-15
- **What shipped:** the records table loads a page at a time with server-side filtering and sort,
  replacing the load-everything fetch.
- **Area:** `ui`
- **Archived plan:** `ui/completed/records-list/server-side-pagination.md`
- **Notable decisions:** cursor-based paging over offset — see ADR-0004 in `architecture.md`.
- **Known gaps:** no saved filter presets; deferred, tracked in `in-progress.md` under Parked.

_Delete the example entry once the first real feature ships._

---

### Panoply Optimization — Mandatory PR gates, expert review, docs enforcement — 2026-08-21
- **What shipped:** Full enforcement plane for any project adopting the kit: (1) `scripts/init-repo-protection.sh` — interactive branch protection via `gh` CLI (require PR, require `verify` check, forbid force-push, forbid direct push); (2) `scripts/check-expert-review.sh` — CI gate verifying expert review evidence (plan.md, checklist.md, adr.md new section, ≥2 persona sign-offs) with trivial escape hatches (label "trivial", commit prefix "trivial:", 1-file ≤15-line no-schema); (3) Expert-review policy in `.agents/rules/workflow.md` and `AGENTS.md` (4 default personas: Security, Performance, Maintainability, UX); (4) Updated CI/pre-commit templates with expert-review + docs gates; (5) Kit repo dogfood: `.github/workflows/verify.yml` with all gates; (6) Adapt command Phase 10 updated to wire expert-review gate and report branch protection outcome.
- **Area:** `governance`
- **Archived plan:** `governance/completed/plan.md` (master plan), `governance/completed/checklist.md`, `governance/completed/brief.md`, `governance/completed/adr.md` (ADR-0001)
- **Notable decisions:** Interactive `gh` CLI for branch protection (not auto-API, not CI-fail); grep-based evidence check for expert review (not artifact check); trivial escape hatch prevents ceremony overload; policy in use-case layer (workflow.md), gate in framework layer (CI script) — Clean Architecture honored.
- **Known gaps:** Branch protection requires `gh` auth (falls back to manual instructions); expert-review evidence can be boilerplate (mitigated by review culture + adversary-review skill); no hosted platform/MCP/self-updating docs.

---

### Docs-gate — Mechanical landing gate enforcing worklog currency — 2026-08-21
- **What shipped:** `scripts/check-docs.sh` fails any commit that changes non-markdown files (source, config, schema, scripts, CI) without also updating the worklog target (`CHANGELOG.md`/`HISTORY.md` `[Unreleased]` or `docs/agents/worklog.md`) in the same commit. Runs in required CI and pre-commit hook — provider-neutral, POSIX sh, no runtime deps.
- **Area:** `governance`
- **Archived plan:** `governance/completed/docs-gate.md`
- **Notable decisions:** Enforces presence, not correctness — a garbage worklog line passes; correctness is a review problem. Worklog target auto-detected, overridable via `DOCS_WORKLOG`. Doc files exempt by default (ext `md`).
- **Known gaps:** No agent-authored self-updating docs; no hosted platform/MCP; no tool-only PreToolUse precondition.

---

<!-- New entries go directly below this line, newest first. -->

### Agent-readiness module + CI gate (dual-mode apps) — 2026-09-26
- **What shipped:** any repo adopting the kit can require that its app be *dual-mode* — usable by a human in its own UI **and** drivable by an AI agent (a harness such as Hermes/OpenClaw/the agent, or autonomously with only an LLM API key). An agent picking up an adapted repo learns the three required surfaces from `AGENTS.md`, and a PR that removes idempotency or hardcodes a vendor endpoint fails CI.
- **Area:** `governance`
- **Archived plan:** `governance/completed/agent-readiness-module.md`
- **Notable decisions:** Premise is *the UI is a client of the API, never the owner of a capability* — so a screen-only action is a capability the app does not have. Three surfaces are the non-negotiable minimum: **HTTP API** (every mutation idempotency-keyed because agents retry; error codes that distinguish retry / fix-input / give-up; cursor pagination), **MCP server** (a thin adapter over the *same* use cases, schemas **generated** from the API's validation schemas — never hand-written, since a second source of truth drifts silently), **A2A agent card** (`/.well-known/agent-card.json`, served unauthenticated; long-running work as stateful tasks with human-in-the-loop pauses). All three are **Interface Adapters with zero business rules**, which is what keeps this cheap instead of a rewrite. LLM config solely via `LLM_BASE_URL` / `LLM_API_KEY` / `LLM_MODEL` so one code path serves a raw vendor key, a LiteLLM-style gateway, or a harness-provided endpoint. Agents are **distinct scoped principals**, never a browser session, enforced in the use case because a second entrypoint skips the route. Trust rule: agent writes are **attributable in the human UI and reversible** — invisibility is why integrations get switched off. `MODULE:agent` is pruned by `/adapt` where no agent consumer exists; `AGENT_READINESS_ENFORCE=warn` covers mid-adoption repos.
- **Known gaps:** The kit's own `verify.yml` runs the **canary self-test**, not the gate — panoply is a shell/doc template with no agent surface of its own, so the gate would fail every kit PR. Adopting repos get the real step via `scripts/templates/ci-verify.yml`. Static detection is best-effort by nature: the gate proves *presence* of an idempotency mechanism, not that it dedupes correctly, and cannot judge whether a tool description reads well to a model — those stay in the review checklist and the agent-perspective smoke test the module requires. The module does not itself ship an MCP server or A2A implementation; it states the contract and enforces the checkable part.
- **Durable lesson:** **ship a canary with every pattern-matching gate.** The gate's first run reported MCP and scoped-auth as *present* in a repo with neither — its own source contained the patterns it searched for. A single manual pass on a real repo cannot distinguish "compliant" from "detects nothing". See the `panoply-governance` skill.
