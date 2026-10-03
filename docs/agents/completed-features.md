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

### Spec before plan — 2026-10-03
- **What shipped:** a structural change in a kit repo must now carry a spec at
  `docs/agents/<area>/<feature>/spec.md` before its plan — prioritized user stories each with an
  **independent test**, Given/When/Then acceptance scenarios, numbered `MUST` requirements, and
  measurable success criteria. An unknown is written `[NEEDS CLARIFICATION: …]`, which is legal in a
  draft spec and refused toward a plan. `scripts/check-spec.sh` enforces presence and resolution in
  required CI, with a 14-check mutation-tested canary. Hermes walks the same pass through the
  `spec-driven-start` skill.
- **Area:** `governance`
- **Archived plan:** `governance/completed/spec-before-plan/plan.md` (with `spec.md` beside it — the
  shipped feature's own spec, written with the artifact it introduced)
- **Notable decisions:** the spec lives BESIDE its plan, never in a `specs/NNN-slug` tree, so
  `check-plan-home.sh` and `check-algorithm.sh` need zero new allowances; the gate judges presence and
  resolution only and says so in its own limits header; a marker is metasyntax-exempt so the gate cannot
  match its own documentation (the failure the placeholder scan already hit once); and this repo
  deletes its `docs/agents/worklog.md` stub, because two parallel running logs had already cost drift.
- **Known gaps:** the gate cannot judge spec *quality* (independently testable stories, concrete
  scenarios, measurable criteria) — that stays a review question. The Hermes walkthrough is written but
  not yet exercised on a real project.

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

### Version resolution answers one question — 2026-10-01
- **What shipped:** `scripts/panoply.sh version` now gives the same answer from the kit source and from the doctor `apply` copies into an adopted repo. A version comes from a tag **only when HEAD is exactly at it** (`git describe --tags --exact-match`), so an untagged checkout reports `unreleased` in every tree; a copied doctor reads its own stamp and never consults tags. `scripts/panoply.test.sh` gains a case that stages a canonical clone and asserts the copy agrees with the source — mutation-tested, because the first two drafts passed while measuring nothing.
- **Area:** `governance`
- **Archived plan:** `governance/completed/version-resolution-one-question/plan.md`
- **Notable decisions:** the defect was that `_kit_version` asked **two different questions** depending on which branch ran — "what release is this checkout?" from the source (which correctly yields `unreleased` when untagged) and "what is the nearest ancestor tag?" from a canonical clone (which yields the bare tag, `--abbrev=0` having stripped the `-14-g` suffix). Three candidate causes were falsified by measurement before the real one was found: a stale canonical clone, `PANOPLY_KIT_ROOT` reachability, and the canary's own root. Making the source mirror the clone was rejected — it propagates the wrong question. Notably, `--abbrev=0` → `--exact-match` on the source branch is **not** the fix and was measured as behaviourally identical on an untagged HEAD; the reproducing mutation is the copied-doctor branch, which the canary catches.
- **Known gaps:** the new canary case needs a canonical clone it can stage, so it clones from the source's `origin` and **skips loudly** if that is impossible (offline runner, no remote) — a skip, not a false green. `_canonical_kit_root` and `PANOPLY_KIT_ROOT` are unchanged and still used by `_kit_sha` and self-detection.
- **Durable lesson:** **a gate that asks two different questions of two trees will disagree with itself** — and **a canary that cannot go red is not evidence**. Two drafts of this case passed while measuring nothing (both sides pointed at the same tree; then a clone of a *worktree*, which carries no tags, so the copy fell back to the stamp). Both defects were found by running mutation tests, not by reading the case. See the `panoply-governance` skill.

### Rejections are first-class — the step-2 candidate list is also the rejections ledger — 2026-10-01
- **What shipped:** the plan doc's **Deletion candidates** section — already required on a structural change and already checked by `scripts/check-algorithm.sh` — is now also the ledger for proposals that were **considered and turned down**. `.agents/rules/algorithm.md` step 2 states that a rejection and a deletion are one act ("we considered this and are not doing it"), that a rejection owes what it was, why it lost, and **what we do instead**, and that it is recorded in the plan doc rather than in a second store. `docs/agents/_templates/plan.md` gains the "This list is also the rejections ledger" paragraph and the **What we do instead** column; the step-2 row of the step table names rejected items.
- **Area:** `governance`
- **Archived plan:** `governance/completed/rejections-first-class/plan.md`
- **Notable decisions:** the two components originally proposed — a new `.agents/rules/decisions.md` module and a new `check-rejections.sh` gate — were **deleted rather than built**, on running the pass: the artifact already had a required, gated home, so inventing a second home and a second gate would have been the waste the pass exists to catch. **No gate changed**, deliberately: `check-algorithm.sh` still refuses only on the missing section, so its one-refusal-one-remedy property and its canary round trip are untouched, and the "What we do instead" column stays a prose obligation rather than a second matching rule. Vendoring `nicklecoder/requiem` was rejected outright — one author, no long-run evidence by its own README's admission, and it would add a second decisions corpus plus an embedder endpoint and SQLite index to a repo whose premise is POSIX sh with zero runtime deps. Also fixed in passing: the module's Enforcement section had claimed `check-algorithm.sh` verifies that a change's automation names the step it automates — it never did, and the false claim was removed rather than made true.
- **Known gaps:** nothing mechanical checks that a rejection's *instead* names a real thing, or that a rejection was recorded at all — that stays a review question, now stated explicitly in the module's honesty paragraph. Rejections are per-plan-doc, so there is no cross-repo retrieval: finding "we said no to this in another project" is a `gbrain` question, out of scope here. No mirror of this change was made in `a pilot repo` — its `in-progress.d/` fragments carry the same plan-doc contract and were judged to need no edit.
- **Durable lesson:** **a rejection left in a chat thread leaves no artifact — record it in the list that already exists, and do not build a second store for it.** The strongest idea in a tool being considered is usually already expressible in an artifact the system requires; look for that before adding machinery for it. See the `panoply-governance` skill.

### Agent-readiness module + CI gate (dual-mode apps) — 2026-09-26
- **What shipped:** any repo adopting the kit can require that its app be *dual-mode* — usable by a human in its own UI **and** drivable by an AI agent (a harness such as Hermes/OpenClaw/the agent, or autonomously with only an LLM API key). An agent picking up an adapted repo learns the three required surfaces from `AGENTS.md`, and a PR that removes idempotency or hardcodes a vendor endpoint fails CI.
- **Area:** `governance`
- **Archived plan:** `governance/completed/agent-readiness-module.md`
- **Notable decisions:** Premise is *the UI is a client of the API, never the owner of a capability* — so a screen-only action is a capability the app does not have. Three surfaces are the non-negotiable minimum: **HTTP API** (every mutation idempotency-keyed because agents retry; error codes that distinguish retry / fix-input / give-up; cursor pagination), **MCP server** (a thin adapter over the *same* use cases, schemas **generated** from the API's validation schemas — never hand-written, since a second source of truth drifts silently), **A2A agent card** (`/.well-known/agent-card.json`, served unauthenticated; long-running work as stateful tasks with human-in-the-loop pauses). All three are **Interface Adapters with zero business rules**, which is what keeps this cheap instead of a rewrite. LLM config solely via `LLM_BASE_URL` / `LLM_API_KEY` / `LLM_MODEL` so one code path serves a raw vendor key, a LiteLLM-style gateway, or a harness-provided endpoint. Agents are **distinct scoped principals**, never a browser session, enforced in the use case because a second entrypoint skips the route. Trust rule: agent writes are **attributable in the human UI and reversible** — invisibility is why integrations get switched off. `MODULE:agent` is pruned by `/adapt` where no agent consumer exists; `AGENT_READINESS_ENFORCE=warn` covers mid-adoption repos.
- **Known gaps:** The kit's own `verify.yml` runs the **canary self-test**, not the gate — panoply is a shell/doc template with no agent surface of its own, so the gate would fail every kit PR. Adopting repos get the real step via `scripts/templates/ci-verify.yml`. Static detection is best-effort by nature: the gate proves *presence* of an idempotency mechanism, not that it dedupes correctly, and cannot judge whether a tool description reads well to a model — those stay in the review checklist and the agent-perspective smoke test the module requires. The module does not itself ship an MCP server or A2A implementation; it states the contract and enforces the checkable part.
- **Durable lesson:** **ship a canary with every pattern-matching gate.** The gate's first run reported MCP and scoped-auth as *present* in a repo with neither — its own source contained the patterns it searched for. A single manual pass on a real repo cannot distinguish "compliant" from "detects nothing". See the `panoply-governance` skill.
