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

### Claims are evidence, and comments are not decoration — 2026-10-10
- **What shipped:** `.agents/rules/claims.md` — a claim a reader sees (a metric, a testimonial, a terminal
  transcript, a security or compliance statement, a price, sample data) is real and traceable or it is
  deleted — and a **Comments** section in `code-style.md`: a comment earns its place by saying *why*;
  banners, emoji markers, workflow narration, end markers, restating comments and empty labels do not.
  The comment half is enforced by `scripts/check-comments.sh` (change-scoped: it refuses only a comment a
  change **adds**), with a 34-assertion mutation-tested canary, wired into the kit's CI and the shipped
  adopter template.
- **Area:** `governance`
- **Archived plan:** `governance/completed/claims-and-comment-slop/plan.md` (with the shipped `spec.md` beside it)
- **Notable decisions:** the comment rule is **gated** and the claims rule is **doctrine, deliberately** —
  no script can tell a real number from a plausible invented one, and the module says so instead of implying
  a check it does not have. The gate is change-scoped because this tree carries **177 pre-existing banner
  comments**, measured with the gate's own `--tree` mode — a tree-wide gate would have been red on the PR
  that introduced it and on every PR after. Docs and the gate's own sources are excluded by path (a rule
  module quoting the banned shapes is *discussing* the convention), emoji are matched by byte prefix so a
  curly apostrophe or an em dash is not "non-ASCII slop", and an all-caps label is a **note**, never a
  failure. Both gaps were taken from the public `anti-slop` rulebook (MIT); its other 36 rules were
  rejected because they duplicate `frontend.md`, `design-system.md` and the `humanizer` skill, and its
  "Delivery Gate" is an unenforced self-report.
- **Known gaps:** a trailing `#` or `--` comment is not detected (stated in the module rather than
  implied); the claims half has no mechanical check by design; the 177 pre-existing banners are measured
  and parked, not cleaned.
- **Durable lesson:** **a rule adopted late must not grade the tree that predates it** — measure the
  existing debt with the gate's own audit mode first, then gate only the delta, or the gate becomes
  something people route around. See the `governance-kit-maintenance` skill.

### Kit self-update — a copy that knows it is stale, and an apply that tells the truth — 2026-10-06
- **What shipped:** an adopted repo can now pull kit fixes deliberately. `panoply.sh check` detects that
  its own copy is an older kit generation and reports **exit 15 SELF-STALE** instead of a green computed
  against a layout the current kit no longer uses; `apply` reports a per-file disposition
  (`ADDED`/`KEPT`/`DRIFTED`/`FORCED`) and writes a `<version>+drifted` stamp rather than certifying the
  attempt; `--force-scripts` writes a `.panoply-bak` before overwriting and prints its path; `migrate`
  translates an old-layout repo onto the current layout, reports the translation it will perform, and
  never deletes the old tree.
- **Area:** `governance`
- **Archived plan:** `governance/completed/kit-self-update/plan.md` (with its `spec.md`)
- **Notable decisions:** a stamp certifies the **state**, never the attempt; nothing pulls from the
  network, so a kit fix is **reviewed** rather than silently overwritten; an unreachable kit source is a
  loud "cannot verify", not a green.
- **Known gaps:** `migrate` leaves the old tree for a human to review and remove; the doctor's verdict is
  only ever as good as the reachability of the kit source it compares itself to.

### The launch gate — phase 6 records a launch, and the secret scan is ON — 2026-10-06
- **What shipped:** `scripts/check-launch.sh` + its mutation-tested canary: a change that claims it went
  out must carry a launch record and a rollback line, which fills phase 6's previously stated-empty gate
  cell; `factory-phases.tsv` names the gate for phase 6 so the table no longer claims a cell is unwatched;
  and the kit's secret scan moved from commented-out to **ON** as a pinned, checksum-verified binary in
  both the kit's workflow and the shipped adopter template.
- **Area:** `governance`
- **Archived plan:** `governance/completed/launch-gate/plan.md` (with its `spec.md`)
- **Notable decisions:** a self-reported "delivery gate" was rejected — the record must be something a
  gate can read, which is what `check-launch.sh` does.
- **Known gaps:** the classifier reads the plan's milestone lines by keyword (ship / launch / deploy /
  released / live), so a plan whose milestones name the launch gate itself cannot tick them without being
  read as a ship claim — recorded in the archived plan rather than papered over.

### The PR-context guard on the gate steps — 2026-10-04
- **What shipped:** every gate step that reads `pull_request.base.sha` carries its
  `if: github.event_name == 'pull_request'` in both `.github/workflows/verify.yml` and the shipped
  `scripts/templates/ci-verify.yml`, so a push to `main` is never red for a context it cannot use.
- **Area:** `governance`
- **Archived plan:** `governance/completed/pr-context-guards/plan.md`
- **Notable decisions:** the fix was kept to the two keys, so the PR stayed a minimal, reviewable
  regression fix rather than a workflow refactor.
- **Known gaps:** M2 — a structural check that would fail when a step consuming the PR base SHA has no
  following guard — was written and run in that change but is **not wired into the workflow's self-tests**,
  so a future step can still be added unguarded.

### Scope the expert-review gate to the change, not the tree — 2026-10-03
- **What shipped:** `scripts/check-expert-review.sh` scopes its evidence to the files a change touches
  (`git diff --name-only <base>...HEAD`) and its checklist grep to the touched plan file, so a green
  result means *this* change carried the review evidence rather than that the rule's shape exists
  somewhere in the tree. Its canary gained adversarial cases plus positive controls, and both halves of
  the old rule were mutation-tested.
- **Area:** `governance`
- **Archived plan:** `governance/completed/expert-review-scope/plan.md`
- **Notable decisions:** the defect was reproduced against a fixture repo (plan for A, big change to B,
  old gate green) before anything was rewritten — the fix was justified by a failing case, not a reading.
- **Known gaps:** the gate can judge that review evidence exists and is scoped; it cannot judge whether
  the review was substantive.

### Domain expertise and design in the plan — 2026-10-03
- **What shipped:** the spec template and `.agents/rules/spec.md` require a `## Domain & outside experts`
  section — the industry the software is built for, which outside practitioners were consulted and what
  they said — with UI/UX as a **planning** input (the `ux-designer` and `ux-researcher` personas) rather
  than a review afterwards; non-UI work writes `n/a — no user-facing surface`. Eleven persona files that
  were never wired to anything were deleted and the two real ones kept and referenced.
- **Area:** `governance`
- **Archived plan:** `governance/completed/domain-expert-planning/plan.md` (with its `spec.md`)
- **Notable decisions:** software-role input is not domain input — a "Security persona" is not the
  filmmaker or the restaurateur; placeholders until a real person was consulted, never a fabricated quote.
- **Known gaps:** presence and the `n/a` declaration are what the gates read; whether the expert was real
  and useful stays a review question.

### The locked dev-workflow policy in the rules and every mirror — 2026-10-01
- **What shipped:** the owner-locked 2026-09-29 dev-workflow policy (points 1–10) is encoded in the rule
  modules — pre-flight + plan-first + the plan-home rule, including the small-repo `docs/PLAN.md`
  carve-out — and regenerated into every tool-native mirror, so the policy travels with the kit into any
  harness. Policy drift between the kit's rules and a fork is detected.
- **Area:** `governance`
- **Archived plan:** `governance/completed/dev-workflow-locked-policy/plan.md`
- **Known gaps:** for non-agent tools the guardrails remain doc-level MUST-NOT prose; the only cross-tool
  enforcement is server-side (branch protection + required checks).

### Every-agent coverage: the agent, named and verified — 2026-10-01
- **What shipped:** the agent is named and verified as an **AGENTS.md-native** tool, so no additional
  mirror file is required for it and the generated-file set does not depend on the naming header.
- **Area:** `governance`
- **Archived plan:** `governance/completed/opencode-native-coverage/plan.md`
- **Known gaps:** coverage is verified by `sh scripts/sync-agents.sh --check` staying green rather than by
  a gate that names the tool.


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
