# Changelog — panoply

Versions the **kit itself**, not any project it is applied to. When you edit a rule, command, agent,
or setting in this template, add a line here and tag a release (`vMAJOR.MINOR.PATCH`). This is the
human-readable "what governance changed between kit-versions" surface: read it before pulling a newer
kit into an already-adapted repo, so a rule change is reviewed rather than silently overwritten.

Semver, applied to governance:
- **MAJOR** — a rule reverses or a required placeholder/command changes shape (adapted repos need attention).
- **MINOR** — a new rule, command, agent, or module added (additive; safe to adopt).
- **PATCH** — wording, typo, or clarification with no behavioral change.

## [Unreleased]

- MINOR — **policy drift between the kit's rules and a fork is now detected.** `.agents/rules/*.md` and a
  forked copy (the harness's `.claude/rules/*.md`) diverged silently: measured module-by-module, two
  shared rungs were simply missing from the fork — the Algorithm pass and the spec rung — while the other
  seven differences were legitimate adaptation (retargeted paths, filled placeholders). Adds
  `scripts/check-rule-fork.sh`, a read-only anchor-based detector that fails when a shared policy anchor is
  missing with no allowlist entry and exits 2 if its own anchor list rots, so it cannot become a silent
  no-op. A line-diff was rejected (it flags adaptive noise and would be always-red); generating one repo's
  rules from another's was rejected as coupling. Canary asserts both directions and exits 2 on anchor rot.

- PATCH — **two gates could not be escaped and one silently stopped guarding.** `check-expert-review.sh
  --since <unresolvable-ref>` failed OPEN: `git rev-list` errored, the loop body never ran, and the gate
  reported OK — deregistering itself in the exact checkout it exists to guard. It now refuses with exit 2,
  matching `check-spec.sh` / `check-algorithm.sh`. `check-docs.sh` and `check-expert-review.sh` had no
  escape hatch at all, contradicting the kit's own hatch doctrine, so adds `DOCS_OFF` and
  `EXPERT_REVIEW_OFF`. Also fixes a real hole found while testing: a docs-only change in a repo with no
  worklog target was refused, blocking a fresh repo's first markdown commit — the worklog is now resolved
  lazily and only matters when code actually changed. Both gates had NO test, which is how the fail-open
  survived; adds `check-docs.test.sh` (5 cases) and `check-expert-review.test.sh` (4 cases), each
  mutation-tested to prove it goes red.
- PATCH — **the kit's gate self-tests no longer run on every PR, and the plan-home gate finally has a
  canary.** Two findings from the adversarial audit. (a) `.github/workflows/verify.yml` and the shipped
  template ran the gate self-tests (`check-spec.test.sh`, `check-algorithm.test.sh`,
  `check-plan-home.test.sh`, `check-agent-readiness.test.sh`, `panoply.test.sh`) on EVERY pull request —
  4 of the 11 steps of the shipped template — re-proving the kit's own canaries on unrelated product PRs.
  A docs-only PR cannot tell anyone whether a gate still detects, so this was cost with no signal. The
  self-tests now live in a separate `self-tests` job gated on the kit's tooling changing
  (`scripts/**`, `.agents/rules/**`, `.github/workflows/**`) — detected in one step because GitHub has no
  native per-job "paths changed" condition — and always run on push to the default branch, so drift
  cannot hide behind the filter. The required `verify` job is unchanged for every PR. (b)
  `check-plan-home.sh` was CI-wired in the template with no canary of its own: the kit was trusting a gate
  nobody had seen fail. New `scripts/check-plan-home.test.sh` (13 checks) asserts both directions — a
  stray root `PLAN.md`, a root `*-plan.md`, and a flat `docs/agents/plan.md` are REFUSED; a plan in the
  doc spine (`docs/agents/<area>/<feature>/plan.md`) PASSES; the canonical `roadmap.md` is not a stray; a
  repo with no roadmap is refused; `PLAN_HOME_ALLOW` scopes one path; `PLAN_HOME_OFF=1` lifts it; and
  `--staged` refuses a newly staged stray but passes an edit to an already-tracked one. It is added to
  the scripts `panoply.sh apply` installs, so adopters get the canary their CI template now runs.
  Mutation-tested: neutering `is_plan_shaped` turns 7 checks red, making `is_allowed` block everything
  turns 3 red.
- PATCH — **`AGENTS.md` stops shipping a second copy of the ruleset.** `sync-agents.sh` inlined the
  full text of every `.agents/rules/*.md` module (~157KB) between the `PANOPLY:RULES` markers, so the
  rule corpus was shipped twice — once canonical under `.agents/rules/`, once re-rendered in
  `AGENTS.md` — and `AGENTS.md` grew to 170,809 bytes. Beyond contradicting the kit's own "one fact,
  one home" doctrine, the inlining did not achieve its stated goal for the tools it named: a runtime
  that loads `AGENTS.md` and truncates it (~20K chars here) silently drops the middle, so the tool got
  neither the whole ruleset nor a working pointer. `AGENTS.md` now carries a generated **index** — module
  → one-line description → path to read — between the markers (`AGENTS.md` is now 15,546 bytes, under
  the 20K cap, so nothing is truncated). The **tool-native mirrors are unchanged and stay
  self-contained**: `sync-agents.sh` still inlines the complete bodies into each `CLAUDE.md` /
  `GEMINI.md` / `.cursor/rules/*.mdc` / etc., so a single-file tool still gets the whole ruleset. The
  MIRROR block is unchanged and still verbatim in every mirror. The canonical text stays
  `.agents/rules/*.md`. `sync-agents.sh --check` is unchanged in shape (still CI-wired, still fails on a
  stale index block).
- MAJOR — **the kit had two queues for one fact; it now has one.** `.agents/rules/documentation.md`
  named `docs/agents/in-progress.d/` (one file per task) as the tactical queue and `in-progress.md`
  as its "generated view" — but the kit repo has no `in-progress.d/` at all, so the flagship repo did
  not use half the spine it mandates, and the rule told every agent to write a Next step into a
  fragment that does not exist here. `in-progress.md` is the queue: it is the file the onboarding
  contract in `AGENTS.md`, `docs/agents/README.md`, `scripts/panoply.sh`'s scaffold, the
  `panoply` skill, and `scripts/check-plan-home.sh`'s allowlist all reference, and the only one that
  can be dogfooded today. Every reference to the directory is removed from `documentation.md`,
  `workflow.md`, `AGENTS.md` (mirrors regenerated) and `docs/agents/README.md`. Archived completed
  plans and released changelog entries keep their historical wording — an archive records what
  shipped, so it is not rewritten.

- PATCH — **the spec gate no longer demands a spec for wiring.** `CODE_RE` matched any `.yml`, so
  `.github/workflows/*.yml` — a CI workflow, a pre-commit hook, a tool config — counted as structural.
  Adding a gate step would have demanded a spec *for the wiring that runs gates*, which is the same
  ceremony the rule's scope test forbids, and it mis-classified the kit's own adoption of the gate.
  New `CONFIG_RE` exempts `.github/**`, `.agents/**`, `.pre-commit` and tool configs before the suffix
  rule is consulted. Canary cases 13 + 14 prove both directions: a workflow edit passes, and a `src/`
  change is still refused, so the exemption cannot quietly swallow real code.

- PATCH — **the kit repo now dogfoods the spec gate, and CI proves it detects.** PR #21 wired
  `check-spec.sh` into the shipped CI *template* but never into this repo's own `.github/workflows/verify.yml`,
  so the rung shipped unexercised: no runner had ever invoked it. Adds the `Spec` step (PR context, beside
  the Algorithm gate) and a `Spec gate self-test` step (`check-spec.test.sh`, beside the other gate
  self-tests) so the gate's own ability to go red is proven on a runner, not just locally.

- MINOR — **a spec now precedes the plan, and the kit checks it** (PR #21). The kit had a strong plan rung
  and no spec rung: `docs/agents/_templates/plan.md` opened at `## Goal` and went straight to layers and
  milestones, so requirements survived only as prose and nothing asked *what a user can do after this
  ships* or *how we will know it worked*. Measured in this repo's own artifacts: three governance plans,
  zero acceptance scenarios. `.agents/rules/spec.md` is the new rule; `docs/agents/_templates/spec.md` the
  artifact (prioritized stories each with an **independent test**, Given/When/Then scenarios, numbered
  `MUST` requirements, measurable success criteria); `plan.md` gains a `Spec:` link row.
  `scripts/check-spec.sh` refuses a structural change with no spec beside its plan **or** a spec still
  carrying `[NEEDS CLARIFICATION: …]` — legal in a draft spec, forbidden toward a plan, because an
  ambiguity that reaches implementation has already become an unreviewed guess. Canary
  `scripts/check-spec.test.sh` (14 checks) proves both directions, the exemptions, the escape hatch, the
  refuse→remedy→allow round trip, and that the gate does not match its own convention metasyntax;
  mutation-tested (removing either detection path, or the metasyntax filter, turns checks red). Wired into
  `scripts/templates/ci-verify.yml` + `pre-commit`. **Adopting repos:** the gate is additive and ships in
  the template CI; a repo with a backlog and no specs sets `SPEC_OFF=1` temporarily (stated, reviewed)
  while it folds the rung in. **Shipped** in PR #21 (squash-merged `0eca293`); the initiative is in
  `roadmap.md` -> Shipped and the plan is archived at `governance/completed/spec-before-plan/`.
- PATCH — **this repo now keeps ONE running log.** `docs/agents/worklog.md` was still the kit's own
  template stub, which says in its own body to **delete the file** when the repo keeps a
  `CHANGELOG`/`HISTORY` `[Unreleased]` section — and this repo does. Two parallel running logs is the one
  thing the doc contract forbids, and it had already cost drift: the spec-artifact line above was written
  to the stub, where `check-docs.sh` does not look (it resolves `CHANGELOG.md` first), so the landing gate
  failed the PR. The stub is deleted and its lines folded here.
- PATCH — **version resolution asks one question, in every tree.** `scripts/panoply.sh version` disagreed with
  itself: the kit source reported `unreleased` for a checkout 14 commits past its last tag, while the doctor
  `apply` copies into an adopted repo reported that tag (`v1.4.0`) because it read a canonical clone's
  *nearest ancestor* tag instead. `apply` stamped one value and the copy reported another, so `panoply.test.sh`
  failed on any machine holding a canonical clone and passed on a clean CI runner — a local-only false red in
  the one gate adopters are told to run. A version now comes from a tag only when HEAD is exactly at it
  (`describe --tags --exact-match`), so an untagged checkout is `unreleased` everywhere, and a copied doctor
  reads its own stamp instead of consulting tags at all. Tagged releases are unaffected. The canary gains a
  case that stages a canonical clone and asserts the copy agrees with the source; it is mutation-tested (the
  divergence was reintroduced and the case went red). 18/18 checks.

- MINOR — **Rejections are first-class in the step-2 list.** The plan doc's *Deletion candidates* section
  is now also the **rejections ledger**: a proposal considered and turned down is recorded there, at the
  moment the decision is made, with **what we do instead** — the one thing that stops the same idea being
  re-proposed every month, because a rejection left in a chat thread leaves no artifact to find.
  `.agents/rules/algorithm.md` step 2 states it (a rejection and a deletion are one act — both leave
  absence), the step-2 row of its step table names rejected items, and `_templates/plan.md` gains the
  "What we do instead" column. **No gate changed**: the section and its heading are already required by
  `check-algorithm.sh`, so this widens what the artifact must contain, not what the checker looks for.

- PATCH — finish the agent-agnostic neutralization pass: four prose clauses that a
  prior exact-string replacement had mangled (`README.md`, `.agents/rules/documentation.md`,
  `.agents/commands/audit-agents-setup.md`, `docs/agents/worklog.md`) now read as plain
  agent-agnostic text. No rule, command, or gate behavior changed.

- MINOR — **The Algorithm pass added as a rule module** (`.agents/rules/algorithm.md`): question every
  requirement (and make it come with a name), **delete** what you can, simplify, accelerate, automate
  last — in that order, on anything structural, code and non-code. Every plan now owes a **Deletion
  candidates** section, because deletion is the only step whose output is absence and therefore the only
  one that gets silently skipped. Wired into `workflow.md` (pre-flight), `quality-bar.md` (the prior
  question), the MIRROR preamble + read-order in `AGENTS.md`, and `_templates/plan.md`.

- MINOR — **Algorithm gate** (`scripts/check-algorithm.sh` + `scripts/check-algorithm.test.sh`): fails a
  structural change whose plan carries no step-2 artifact, passes a compliant one, exempts docs-only
  changes, and can be lifted by `ALGORITHM_OFF=1`. Six-case canary asserts both directions including the
  deny → apply-the-remedy → allow round trip. Wired into `verify.yml` (gate + self-test) and installed by
  `panoply.sh apply`, whose checklist now names the CI/pre-commit wiring.

- PATCH — `panoply.test.sh` skips loudly instead of false-redding when run outside the kit
  template (it derives its kit root from `$0`, so an adopter became its own 'kit').

- PATCH — `apply` installs a script only when absent, KEEPS and reports a repo's own edited copy
  instead of overwriting it, and replaces one only under an explicit `--force-scripts`.

- PATCH — `apply` seeds `AGENTS.md` (template only, never clobbering the repo's own hub) and installs
  `panoply.sh` + `panoply.test.sh` into the adopted repo so it can self-check; the copied doctor
  resolves the kit version from the canonical clone rather than the adopter's unrelated tags — and
  falls back to the stamp, never the adopter's tags, when no canonical clone exists (a CI runner).

- MINOR — **first-touch rule added to the MIRROR preamble** (`AGENTS.md`): an agent that finds a repo without the kit is told to adopt it as its first batch, with the `panoply.sh check` exit-code table and the apply/verify sequence. Living in the MIRROR block means every generated tool mirror carries it. Fixes the placeholder scan matching the kit's own convention metasyntax and flagging correctly-adopted repos as unadapted.

- MINOR — **the kit gains a machine surface** (`scripts/panoply.sh` + `scripts/panoply.test.sh`):
  `check` reports current / absent / partial / stale / unadapted / mirrors-drifted with distinct exit
  codes (0/10/11/12/13/14) so ANY harness — Hermes, Codex, Cursor, CI, a pre-commit hook — can gate on
  it, and `apply` seeds the deterministic half idempotently and writes a `.panoply-version` stamp
  recording which kit version the repo received. `.panoply-version` is new: previously the kit stamped
  nothing into an adapted repo, so a stale adoption was indistinguishable from a current one. The
  canary asserts all six states plus the `PANOPLY_OFF` escape hatch and the not-a-git-tree passthrough.

- MINOR — **locked dev-workflow policy encoded in the rules** (`.agents/rules/git-workflow.md`,
  `.agents/rules/workflow.md`, `.agents/rules/quality-bar.md` + regenerated mirrors): the 2026-09-29
  owner-locked flow is now doctrine every agent and every mirror carries — pre-flight before any
  work or planning; plan presented to the owner before code; the `docs/agents/` spine as the single
  plan home (one lightweight `docs/PLAN.md` allowed in small non-kit repos; root `PLAN.md` and
  GitHub Issues never); one branch per batch off fresh main, parallel writers one worktree each;
  push each batch as it completes; the STANDARD gate before merge (tests + typecheck + lint + arch
  check unfiltered in the same session, independent re-review of non-trivial work, CI green — a
  subagent self-report is not evidence); squash-merge only with delete-branch-on-merge; one open PR
  per repo at a time with owner exceptions recorded in the plan doc; code + worklog in the same
  commit; owner decisions presented as two tappable options plus a recommendation. Mirrors were
  regenerated with `scripts/sync-agents.sh`, not hand-edited.

## [1.4.0] — 2026-09-26

Agent-readiness doctrine (MINOR — additive; safe to adopt). Pruned automatically by
`/adapt-agents-setup` where the repo has no agent consumer.

- MINOR — **agent-readiness module** (`.agents/rules/agent-readiness.md`, `MODULE:agent`): dual-mode
  doctrine for apps that must work under a human UI *and* an AI agent — the three required surfaces
  (HTTP API with idempotency keys, MCP server with generated schemas, A2A agent card), BYO-LLM-key
  config via `LLM_BASE_URL`/`LLM_API_KEY`/`LLM_MODEL`, scoped non-human principals, and the trust
  rule that agent writes are attributable in the UI and reversible. Enforced by
  `scripts/check-agent-readiness.sh` (warn mode for mid-adoption) with a canary self-test
  (`scripts/check-agent-readiness.test.sh`) wired into the kit's own CI — the gate must be seen to
  fail a defective fixture before it is trusted to pass a real repo. `adapt-agents-setup.md` detects
  agent consumption and prunes the module where none exists; `ci-verify.yml` carries the step
  adopting repos get. Plan (archived): `docs/agents/governance/completed/agent-readiness-module.md`.
- PATCH — canary hardening: removed the SC2015 `A && B || C` shape from the canary so it passes
  shellcheck on both 0.11 and the older version CI runs (local silence is not CI silence); canary 3
  now asserts warn mode still *reports* rather than only that it stops blocking.
- PATCH — coverage wording: OpenCode named as an AGENTS.md-native tool in `README.md` and the
  `scripts/sync-agents.sh` header. No behavioral change and no new mirror: OpenCode reads the
  refilled `AGENTS.md` hub natively (verified in the field — the koforje consolidation audit ran
  under OpenCode bound by workspace AGENTS.md). A proposed `OPENCODE.md` mirror was evaluated and
  rejected: OpenCode does not load that filename, so the mirror would bind nothing.

### Added
- `.agents/rules/agent-readiness.md` (`MODULE:agent`) — the doctrine. Premise: **the UI is a client
  of the API, never the owner of a capability**, so a screen-only action is a capability the app does
  not have. Three required surfaces, all Interface Adapters holding zero business rules: HTTP API
  (idempotency keys, retry/fix/give-up error codes, cursor pagination, published schemas), MCP server
  (thin adapter over the same use cases, schemas generated from the API's validation schemas), A2A
  agent card (`/.well-known/agent-card.json`, stateful tasks, human-in-the-loop pauses). Plus BYO-key
  LLM config, scoped non-human principals, the visibility+reversibility trust rule, and a
  prompt-injection guardrail at the boundary.
- `scripts/check-agent-readiness.sh` — the mechanical floor: card present *and actually served*,
  idempotency on mutations, generated MCP schemas, no vendor endpoint/SDK outside its adapter,
  scoped non-human principal, and a `--since` surface-drift check. POSIX sh; `AGENT_READINESS_ENFORCE=warn`
  for mid-adoption; JSON checks SKIP loudly without jq/python3/node rather than passing silently.
- `scripts/check-agent-readiness.test.sh` — canary self-test, wired into the kit's own CI. Builds a
  fixture carrying every defect the gate claims to catch plus a compliant one; asserts fail-then-pass,
  plus warn and `--since` modes.

### Note for adopters
The kit's `verify.yml` runs the **self-test**, not the gate — panoply is a shell/doc template with no
agent surface of its own, so the gate would fail every kit PR. Adopting repos get the real step via
`scripts/templates/ci-verify.yml`. Static detection proves *presence*, not correctness: that an
idempotency mechanism exists, not that it dedupes. The judgement parts stay in the module's review
checklist and the agent-perspective smoke test it requires.

## [1.3.0] — 2026-09-02

- MINOR — queue hygiene: a task's `in-progress.d` fragment is deleted in the same PR that ships
  the code, and leftovers are retired from PR state with `phalanx-docs-reconcile.sh` (Phalanx
  ≥ 1.7.30) instead of by hand. Stated in AGENTS.md (mirrors regenerated), `docs/agents/README.md`
  and `.agents/rules/documentation.md`.

Provider-agnostic governance layer (MINOR — additive; safe to adopt).

### Added
- `scripts/check-docs.sh` — the docs landing gate: fails any commit that changes a non-markdown file
  (source, config, schema, scripts, CI) but not the worklog target in the same commit. Enforces the
  same-change update contract mechanically, provider-neutrally (runs in required CI + pre-commit), so
  no agent in any tool can land a code change without its doc update. Worklog target auto-detected
  (`CHANGELOG.md`/`HISTORY.md`, else `docs/agents/worklog.md`), overridable via `DOCS_WORKLOG`.
  Wired into `scripts/templates/pre-commit` and `scripts/templates/ci-verify.yml` (`--since origin/main`).
- `scripts/init-repo-protection.sh` — interactive branch protection setup via `gh` CLI: configures
  default branch to require PR, require `verify` check, forbid force-push, forbid direct push. Prompts
  for confirmation; falls back to manual instructions if `gh` unavailable. Wired into adapt command
  Phase 10.
- `scripts/check-expert-review.sh` — CI gate verifying expert review evidence for non-trivial PRs:
  plan.md exists, checklist.md has pending items, adr.md has new section since base, PR description
  has ≥2 persona sign-offs (Security, Performance, Maintainability, UX, or domain-specific). Trivial
  escape: PR label "trivial", commit prefix "trivial:", or 1-file ≤15-line no-schema change.
- Expert-review policy in `.agents/rules/workflow.md` and `AGENTS.md`: non-trivial changes require
  structured review with 4 default personas; evidence checked by `check-expert-review.sh` in CI.
  Conflict escalation to operator via ADR.
- Provider mirrors regenerated via `sync-agents.sh` — all mirrors in sync with updated workflow.md.

### Fixed
- **The expert-review gate's own conditions, before it enforces them for the first time.** Because the
  gate had never run (see below), its checks had never been tested against a real repo — and two of the
  four were wrong. (a) It demanded a `checklist.md` containing an **unchecked** item; surveyed across
  nine kit repos, five had no `checklist.md` at all (they keep the checklist inside `plan.md`) and would
  have been blocked from committing the moment the gate started working, one of them through a live
  local pre-commit hook. It now accepts a checklist item — checked or unchecked — anywhere under
  `docs/agents/**`, which is what "review evidence exists" actually means; requiring an OPEN item
  rewarded unfinished work. (b) The ADR check tested `[ "${1:-}" = "--since" ]` *inside* the function,
  where `$1` is the label argument, so it could never fire — removed rather than left implying
  enforcement that does not exist. (c) The persona sign-off check armed itself whenever `gh` happened to
  be authenticated, so adding a `GH_TOKEN` to any workflow would silently start requiring sign-offs
  across every kit repo at once; it now requires an explicit `EXPERT_REVIEW_REQUIRE_SIGNOFFS=1`.

- **The `verify` workflow's `Lint (shellcheck)` step had never once passed.** It ran
  `shellcheck scripts/*.sh .claude/commands/*.md` — linting markdown prose as shell, which produced
  SC2148 / SC1036 / SC2215 errors on every run, so the kit's own required check was permanently red and
  therefore useless as a merge signal. It now lints `scripts/*.sh` only, and the six real findings
  underneath are fixed: `check-plan-home.sh` dropped two `case` patterns that `*-plan.md` already
  covers (SC2221/SC2222, one of which could never match); `sync-agents.sh` replaced an
  `A && B || C` marker check with an explicit `if` (SC2015, where C can run even when A succeeds);
  `check-expert-review.sh` now prints the `reason` it had been computing and discarding (SC2034) and
  documents why `grep … | wc -l` is deliberate over `grep -c` (SC2126 — `grep -c` exits 1 on a zero
  count, which under `set -e` would abort the gate on the ordinary "no schema files" case).
- `scripts/check-expert-review.sh` called `verify_review_evidence` at lines 56 and 69 but defined it at
  line 86 — after the script's own `exit "$fail"`. A shell reads definitions in execution order, so the
  function did not exist at either call site and the definition was unreachable dead code: every
  non-trivial commit died with `verify_review_evidence: not found` and exited 1, in bash exactly as in
  dash. The definition now sits above its first use (moved verbatim, no logic change). **Every repo
  already adapted with the kit carries the broken copy and needs this file re-synced** — the gate has
  never actually run anywhere, so expect it to start enforcing the plan/checklist evidence requirement
  the first time it does.

### Changed
- **The queue is one file per task, and the only backlog.** `.agents/rules/documentation.md` now names
  `docs/agents/in-progress.d/<slug>.md` as the tactical queue — one committed fragment per task —
  instead of the shared `in-progress.md` table two open PRs collide on (the same reason the worklog
  moved to per-change fragments). `in-progress.md` becomes a generated view: read it, never edit it,
  never commit it. The fragment is also written to be DRIVEN: `status` / `order` / `req` / `risk`
  frontmatter plus a `Next step:` line, so an autonomous driver can dispatch it and a cold session can
  resume it. This closes the gap where a project carried two backlogs that could not see each other —
  this kit never mentioned `TASKS.md`, and Phalanx's loop never looked at `in-progress.md`. Phalanx
  ADR-0004 adopts the same files and the same keys. Mirrors regenerated.

- Provider mirrors are now **self-contained**: `sync-agents.sh` inlines the full `.agents/rules/*.md`
  bodies into every tool file and into `AGENTS.md`'s `PANOPLY:RULES` block (was: a header + `MIRROR`
  block + a pointer to `.agents/rules/` no non-Claude tool could follow). `AGENTS.md` carries the
  `PANOPLY:RULES` markers; `ci-verify.yml` runs `sync-agents.sh --check` so drift fails CI for every tool;
  `adapt-agents-setup.md` runs the inlining generator last (after rules are pruned) and verifies no
  mirror is a bare pointer.
- `.agents/rules/clean-architecture.md` — new module-fenced **Enforcement** gate: names the per-stack
  boundary linter (dependency-cruiser / import-linter / ArchUnit / …), the report-only→blocking ramp,
  and "CI is the binding plane"; review-checklist item 1 now points at `{{ARCH_CHECK_CMD}}`.
- `.agents/rules/documentation.md` — the four-altitude anti-redundancy table (roadmap / in-progress /
  worklog / completed-features) and the same-change update contract binding every provider.
- `.agents/rules/git-workflow.md` — module-fenced arch-boundary pre-commit gate, and the
  enforcement-plane note (the `settings.json` deny binds only Claude; server-side CI binds all tools).
- `.claude/commands/adapt-agents-setup.md` — detects the running log + provider files + arch linter,
  scaffolds roadmap/worklog, emits `AGENTS.md` + runs `sync-agents.sh`, copies the CI/pre-commit
  templates, extends the porcelain allowlist, and reports the worklog target + mirrors + manual step.
- `.claude/commands/audit-agents-setup.md` — Check 4 worklog/roadmap-currency, Check 5 AGENTS.md
  presence + deny↔guardrails sync, Check 6 "wired, not just installed", and new Check 7 (provider hub
  read-order + mirror-drift + inline-doctrine).
- `CLAUDE.md` — `@AGENTS.md` bridge, module-fenced arch-boundary command row, roadmap + worklog in
  Project Knowledge.
- `docs/agents/_templates/plan.md` — a Roadmap-initiative field, a forced **Architecture** section
  (layers/ports/DTOs/direction/swap-test), and worklog/roadmap moves in the On-ship step.
- `docs/agents/in-progress.md` — an Initiative column and the tactical→strategic roll-up note.
- `docs/agents/README.md` — read order, layout, and doc lifecycle now name roadmap + worklog.
- docs: describe the install as provider-agnostic (AGENTS.md hub + mirrors + CI), not Claude-only.

## [1.0.0] — 2026-08-19

Initial published release of the Panoply kit (`dustin-olenslager/panoply`), fetched with
`npx degit dustin-olenslager/panoply` and wired in by `/adapt-agents-setup`.

### Added
- Initial kit: `CLAUDE.md` spine, `.agents/rules/*`, `.claude/agents/*`,
  `.claude/commands/{adapt,audit,assess}-*.md`, `settings.json`, and the `docs/agents/` scaffold.
- `documentation.md` → "When to write": handoff-on-pause rule (write the exact next action where the
  next session looks first) and the "shipped-but-unlogged counts as not done" enforcement framing.
  Lifts the Frame Forge work-logging doctrine to template altitude so every repo inherits it.
- `git-workflow.md` → "Before you ship, merge, or delete a branch: prove it carries unmerged work" —
  the `git cherry` proof for squash-merged branches, delete-don't-re-merge, record-tip-SHA rollback,
  and the `git branch -d`-refuses-a-squash-merged-branch gotcha.
- `git-workflow.md` → "Repo hygiene & credentials" — verify commit identity before the first commit
  in a fresh clone; never a credential in the remote URL, never commit a secret, rotate on exposure.
- `settings.json` deny: block `git remote add/set-url` with an embedded `https://…@` credential;
  allow `git cherry` (read-only) so the new branch-verification doctrine runs without a prompt.
- `audit-agents-setup.md` → Check 4: shipped-but-unlogged detector (diff merges since the newest
  completed-log entry against the log + `in-progress.md`; flag active items with no Next step).
- `docs/agents/_templates/plan.md`: a `Next step` handoff field.
- `docs/agents/in-progress.md`: the Notes cell reframed as the active row's handoff.
- This `CHANGELOG.md` and the versioned GitHub repo it lives in.
