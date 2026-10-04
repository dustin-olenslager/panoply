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

- MINOR — **the wireframe gate (M4)**: `scripts/check-wireframe.sh` + 12 canaries, wired into CI and the
  adopter template. Presence only — a user-facing change must have `wireframe/index.html` and
  `interviews.md`, or a reasoned `n/a`. It cannot judge whether the screen is good, which stays a review
  question. A bare `n/a` is refused (the reason distinguishes a deliberate opt-out from an accidental
  skip), and the spec's own reasoned `n/a` wins over keyword vocabulary, so "internal CLI, no screen" is
  not read as requiring one. Proven on real artifacts: the actual factory spec is refused without its
  wireframe and passes with the real pair. Escape hatch `WIREFRAME_OFF=1`.

- MINOR — **the wireframe rung (M3)**: `.agents/rules/wireframe-first.md` (the fixed sequence, the
  path contract, the one-sentence skip test, and the interview protocol with the mandatory refuter and
  the "changed what" column), plus `wireframe/index.html` and `interviews.md` templates. Proven with a
  real wireframe and a real interview against the factory's own US-1 — 4 design changes and 3 recorded
  non-changes. Figma was tested and removed on evidence: its REST API cannot author a design, so an
  agent could not produce the artifact. Also: the detector's O6 metasyntax rule and BACKFILL flag, and
  `check-rule-fork.sh` separating "drift found" from "could not audit".

- MINOR — **the factory phase model and detector (M2)**: `scripts/factory-phases.tsv` (the seven phases
  as data) + `scripts/factory-detect.sh` (the 12 observations and a fixed precedence rule, reporting the
  phase, the evidence, and the next step) + `.agents/rules/factory-phases.md`. Detection only — acting on
  a phase is a later milestone, so a wrong answer cannot silently drive the wrong work. 16 canaries, 4
  mutation-tested. Escape hatch `FACTORY_PHASE_OFF=1`. Cannot see: whether an artifact is any good, or
  the difference between "milestones ticked" and "actually shipped".

- DOCS — plan doc for the coverage rivet (`docs/agents/governance/spec-plan-coverage/`), with the review
  checklist the expert-review gate requires of a structural change.

- FIX — a CI step cannot carry two `run:` keys. Inserting the coverage canary inline after a `run:` line
  with no trailing newline produced a duplicate key; GitHub rejected the whole workflow and reported a
  failure with ZERO jobs in 0s (invalid YAML, not a failing test). Same defect was in the adopter
  template. Guard: validate a workflow parses before pushing — zero jobs means the file, not the code.

- MINOR — **the spec→plan coverage rivet** (`scripts/check-coverage.sh` + `scripts/check-coverage.test.sh`,
  11 canaries). The spec rung and the plan rung were each sound and each blind to the other: nothing
  verified that a plan covers what its spec requires, so a plan could look thorough and omit a third of
  the requirements with every gate green. The gate enforces BOTH directions — a requirement claimed by no
  milestone fails, and a plan citing a requirement the spec never declared fails — which is what makes
  the pair agree rather than merely look complete. Wire into CI beside the spec gate; plan doc gains the
  `## Spec coverage` table (template + `.agents/rules/spec.md` doctrine). Escape hatch `COVERAGE_OFF=1`.
  Cannot see: whether a cited milestone genuinely delivers the requirement — that stays a review question.

- MINOR — **the software factory: spec + plan for consolidating panoply and the archived harness into
  one phase-aware factory, with wireframe-first design.** Written under the method it describes (expert
  debate -> persona interviews -> wireframe -> plan), per the owner's instruction to build it with the
  methodology being built. Adds the two rungs the process never had: requirement-level spec->plan
  coverage (the seam a planning audit proved is missing and evidenced with real drift in this repo),
  and a wireframe rung with simulated interviews that run BEFORE backend work. Design decisions from
  three practitioner debates are carried into the requirements rather than smoothed away, including
  the architect's position that the phase model stays data+doctrine and no Node runtime enters the
  zero-dependency shell kit. Plan: `docs/agents/governance/software-factory/{spec,plan}.md`, M1-M6.

- PATCH — the kit's own `panoply.test.sh` no longer builds its "old doctor" fixture out of
  `origin/main`. Main now carries `_PANOPLY_GENERATION`, so a fixture sourced from it stopped being an
  old copy the moment #35 merged — the case passed on its branch and went red on main. A fixture built
  from a moving ref tests the ref, not the behaviour; it now strips the marker from the current doctor,
  which is state-independent. Found by running the suite on merged main, not by CI.

- PATCH — the `n/a — no user-facing surface` form is stated to cover internal tooling, CI, a script or
  documentation, not only a library. Found when the new interview check (correctly) refused the kit's
  own `kit-self-update` spec: the rule said what the `n/a` form accepts but did not say that a
  maintainer-only change qualifies, so the escape read as library-specific.

- PATCH — **the doctrine told agents five agent-readiness checks the gate does not run, and never
  mentioned a required gate that does.** Same defect class as the expert-review lie (#31), swept
  across all eight gates. `agent-readiness.md` claimed the gate runs a "smoke test with only
  `LLM_BASE_URL`/`LLM_API_KEY`/`LLM_MODEL` set" (there is no smoke test; the gate never runs the app),
  that MCP schemas are generated "**and in sync with the API schemas**" (only generation is checked),
  and that "no vendor LLM endpoint **or model identifier**" is hardcoded (the pattern matches
  endpoints/SDK imports only — a hardcoded `gpt-4o` passes; reproduced). The same module never named
  two checks the gate DOES run (non-human scoped principal, `--since` surface drift) nor its
  `AGENT_READINESS_ENFORCE=warn` opt-in. `workflow.md` said `check-plan-home.sh` "enforces this" where
  the gate checks plan-file *location*, not "a plan is a roadmap row"; `documentation.md` framed the
  same-change contract as "never a tool-only permission gate" while `check-docs.sh` does enforce its
  worklog core; `git-workflow.md` said `check-docs.sh --since` "walks every commit" (it skips merges)
  and never told agents `check-conflict-markers.sh` exists — a required per-PR gate with a
  `CONFLICTS_OFF=1` hatch named nowhere they read. `spec.md` gained the gate's wiring exemption and the
  `docs/PLAN.md`-has-no-spec-home limit; `algorithm.md` gained the real structural predicate, its
  overrides and its exit-2 ref guard; `documentation.md` gained `DOCS_OFF`/`DOCS_EXEMPT` and the
  rule-fork audit it never mentioned. Every claim was checked against the script and behavioural
  reproductions; the full 30-row table is `AUDIT-promises.md`. Two behavioural defects are REPORTED,
  not fixed (owner's call): `check-docs.sh`'s ref guard exits 1 where the other four gates exit 2, and
  the conflict gate's `--since` path list can silently narrow. **No gate behaviour changed.**
- PATCH — the interview check is scoped to specs THIS CHANGE touched. Found by simulation: requiring
  the section of every spec in the tree failed a change over a pre-existing spec it had nothing to do
  with — including the kit's own governance specs, which are about the kit rather than a product with
  users. Same change-scoping rule the expert-review gate needed.

- MINOR — **planning now interviews four user personas (simulated) before any UI/UX or functional
  decision, and `check-spec.sh` enforces the section exists.** The spec names the project's OWN user
  personas — domain roles (a producer, a gaffer, an edit assistant, a post supervisor), never software
  roles — and planning simulates an interview with four of them, recording what each surfaced and
  **which screen, flow, field or rule it changed**: the interviews are the input to design, not a
  write-up after it. The artefact states plainly they are SIMULATED role-plays and is never written as
  a real quote from a real person; a genuinely-interviewed real user supersedes the simulation and is
  named. `docs/agents/_templates/spec.md` carries the section and a four-row table; `.agents/rules/spec.md`
  (item 7 + the pass) makes it binding; `scripts/check-spec.sh` refuses a spec that omits it, loosely
  matching the heading (either word order) and accepting the explicit `n/a — no user-facing surface`
  form for a repo with no UI. Escape hatch `SPEC_INTERVIEWS_OFF=1`. The canary grew 16 → **21** checks,
  including the adversarial case and three mutations (detection disabled, heading widened, off-switch
  dead) proven to go red.

- MAJOR — **the plan never brought in the industry the software is FOR, and 13 persona files were
  invoked by nothing.** Two connected defects, one change. (1) The spec rung asked for software-role
  input only; the spec template now carries a **`## Domain & outside experts`** section naming the
  industry/domain (`{{DOMAIN}}`) and recording each consulted outside practitioner's role and what they
  said (`<expert role>` / `<what they said>`) — placeholders only, never a fabricated quote — and
  `.agents/rules/spec.md` (item 6 + the pass + honest limits) and `workflow.md` (Planning Workflow)
  make it binding. (2) `.agents/personas/` held 12 personas + a README; **no gate, command, or rule
  invoked any of them**, and `.agents/rules/workflow.md`'s "four default personas" (Security,
  Performance, Maintainability, UX) mapped to zero files. **10 were deleted**, each mapped to the rule
  module that already does its job (`ui-designer` restated `design-system.md` almost section for
  section; `security-engineer`/`code-reviewer` → the Expert Review dimensions; `backend-architect`/
  `database-optimizer`/`frontend-developer`/`software-architect` → their rule modules; `cto-review` →
  `quality-bar.md`); **2 were kept and wired into planning** — `ux-designer` and `ux-researcher` are
  now the spec-time consultations the `## Domain & outside experts` section names, so UI/UX is a
  *planning* input, not a post-plan review. `workflow.md` now says plainly that its list is four review
  *dimensions*, not personas. Adapted repos: the persona deletions and the plan/spec template changes
  need attention; wire the domain section into your spec authoring. **No new gate** — whether a named
  expert is real is unjudgeable by a section-presence check, which would pass on a fabricated expert
  and block no real mistake (the honest residue is stated in `spec.md`, not automated). Persona count
  12 → 2, a counted number.
- PATCH — **the new canary and simulator carried two shellcheck findings the CI ShellCheck flags and
  the dev box's older one does not.** `scripts/panoply.test.sh` captured output with an `A && B || C`
  chain (SC2015) and `scripts/simulate-adopters.sh` used a useless `cat` in a pipe (SC2002); both are
  info/advisory locally but fail the `Lint (shellcheck)` step on CI. Replaced the capture with an
  explicit redirect and dropped the `cat`. No behaviour change.

- MINOR — **an adopted repo can now pull kit fixes deliberately, and a stale copy of the kit can no
  longer report a clean bill of health.** The kit is adopted by ~11 repos that each keep their OWN copy
  of `scripts/panoply.sh`, `sync-agents.sh` and the rule modules, and nothing brought a fix forward.
  Four owner-verified consequences, each now fixed and canary-proven: (1) **a false green** — an old
  adopter's own doctor reported `OK — kit v1.4.0 applied and current` (exit 0) on a repo the current
  doctor calls `HALF-APPLIED` (exit 11); measured on a copy of a pilot repo, own-doctor 0 vs
  current-doctor 11. The doctor now embeds a GENERATION marker (`_PANOPLY_GENERATION`) and reports a new
  state `SELF-STALE` (exit 15) with three tells — the running copy carries no marker, a reachable kit
  source disagrees, or the repo's own committed `scripts/panoply.sh` is an older generation — and never
  claims OK over an obsolete layout. A version-string comparison was rejected: between releases both
  copies report `unreleased`, so it detects nothing in the exact case the false green appears.
  (2) **a lying stamp** — `apply` on a drifted repo kept every local file, changed nothing, and still
  rewrote `kit_sha`, certifying code that was not installed; reproduced on a copy of a pilot repo.
  `apply` now prints a per-file disposition (`ADDED`/`KEPT`/`DRIFTED`/`FORCED`), sets a `_drifted` flag,
  stamps `<version>+drifted` instead of claiming current, and exits 12 — the stamp certifies the STATE,
  not the attempt. (3) **an unrecoverable destructive path** — `--force-scripts` overwrote a
  locally-edited script with no `.bak` (the kit's own source named a pilot repo's `check-docs.sh` work as
  what it would destroy); it now writes `scripts/<file>.panoply-bak` before overwriting and prints the
  path, collision-safe across repeated runs, and writes no backup for a file it did not overwrite.
  (4) **no update path** — new `migrate` subcommand translates an OLD-layout adopter (`docs/claude/` +
  `.claude/rules/`, 9 of 11 adopters) onto the current layout (`docs/agents/` + `.agents/rules/`),
  reporting the translation BEFORE performing it, copying the adopter's own adapted content forward,
  never deleting the old tree, and refreshing the doctor itself (with a backup). No auto-pull: doctrine
  is that a rule change is reviewed, not silently overwritten. Canary 18 → 36 checks; each new
  behaviour mutation-tested (neutering self-stale detection turns 4 red; removing the drift stamp guard
  1 red; removing the drift exit 1 red; removing the backup 1 red; removing the migrate translation
  report 1 red). Simulated against three throwaway adopter repos (old-layout, current-with-local-edits,
  lying-stamp) — see `scripts/simulate-adopters.sh`.

- MINOR — **the expert-review gate was a file-presence check wearing a review gate's name.** Its two
  required checks were TREE-GLOBAL: `find docs/agents -name plan.md` matched a plan for ANY feature,
  and `grep -rlE '^[[:space:]]*- \[[ xX]\]' docs/agents` matched any checklist line anywhere. Once a
  repo held one finished plan, both were satisfied for every later PR, so a 200-line structural change
  with no plan and no review passed — the gate could not distinguish "this PR was reviewed" from "this
  repo has ever contained a plan". Review evidence must now be a plan doc the change itself ADDED or
  MODIFIED (`git diff --name-only <base>...HEAD`, the same scaffold `check-spec.sh` /
  `check-algorithm.sh` use), and the checklist must live in that touched file. The canary gains the
  adversarial case (plan for feature A in the tree, large feature-B change with no plan → REFUSED) plus
  its positive control, and both halves of the old rule were mutation-tested: reverting either one
  turns the canary red (4 checks and 1 check respectively). Also replaced `git show --stat | tail -1`
  (a TOTAL row in some git versions, a filename in others) with a summed `git diff --numstat`.
- PATCH — **`workflow.md` promised four expert-review checks the gate does not run.** The rule module
  (one of the three that may never be deleted) claimed `check-expert-review.sh` verified a
  `checklist.md` with ≥1 *unchecked* item, a new `adr.md` section since the base branch, and
  unconditional ≥2-persona sign-off. The gate had deliberately dropped the unchecked-item rule (it
  blocked a repo that had *finished* its work — the definition of done — until someone added a fake
  open task), has no ADR logic at all, and checks sign-off only behind the opt-in
  `EXPERT_REVIEW_REQUIRE_SIGNOFFS=1`. The doctrine now states the gate's real contract — review
  evidence that EXISTS for this change, a plan doc and a checklist item (checked or unchecked), with
  sign-off as a review obligation unless a repo opts in — and says plainly what it does not check. A
  doubled phrase in `AGENTS.md` ("the architecture-boundary check in the architecture-boundary check
  fails the build") is fixed. Untruths in an always-on rule module teach every agent to trust a
  control that is not there; that is the doc-bug class this fixes. No scripts changed.

- MINOR — **`apply` installed 3 fewer gates than the CI template invokes, so a freshly-adopted repo's
  first PR died.** The install list was a hand-kept literal; `check-spec.sh`, `check-expert-review.sh`
  and `check-agent-readiness.sh` were missing from it while `scripts/templates/ci-verify.yml` ran all
  three, so `apply` deterministically produced the kit's own exit-11 half-applied state (reproduced:
  adoption into a throwaway repo → 10 files, no `check-spec.sh`). The list is now DERIVED from the
  template's own `run:` lines plus each script's canary, so the applier and CI cannot drift apart again.
  Verified: 0 template dependencies missing after adoption, was 3.

- MINOR — **the rule-fork gate guarded 4 of 9 always-applicable modules, and reported a dropped module
  as soft.** `check-rule-fork.sh` covered only `workflow quality-bar git-workflow documentation`, so a
  fork with `algorithm.md` and `spec.md` deleted returned rc=0 "no policy drift" — the exact failure its
  own header cites. Anchors now cover all nine always-applicable modules (13 anchors), and absence of an
  ALWAYS module is HARD drift while a conditional module (`database`, `frontend`, …) stays soft, since
  only the latter is a legitimate adaptation. Canary 18/18 and it now asserts anchor-list COVERAGE —
  mutation-testing found that reverting 13 anchors to 7 left the whole canary green.

- MINOR — **two canaries existed, passed, and ran in no CI.** `check-docs.test.sh` and
  `check-expert-review.test.sh` were wired nowhere, so the two widest-blast-radius gates (both blocking
  on every PR) were the two with no way to prove they still detect. Both are now steps in `verify.yml`
  and in the shipped template.

- PATCH — **`check-agent-readiness.sh` used the pre-fix ref guard.** Its `--since` validation was a bare
  `git rev-parse --verify` where the other four gates use `-q --verify` + exit 2; the same question must
  get the same answer in every gate or the divergence is the bug. Now matches the house pattern.

- MINOR — **a generated file can no longer reach main carrying an unresolved merge conflict.** `AGENTS.md`
  did exactly that: a hand-resolved conflict kept BOTH sides, so the file shipped a literal `<<<<<<< HEAD`
  and a doubled, empty `PANOPLY:RULES` block — and every gate passed, because `sync-agents.sh --check`
  validates only its own generated block and no other gate reads the bytes. An agent reading that file
  received two contradictory instruction sets with no signal anything was wrong. Adds
  `scripts/check-conflict-markers.sh`, CI-wired as a required per-PR step. The design is `a pilot repo`'s
  conflict sweep promoted out of its `check-docs.sh` into a gate of its own; a `git grep -nE` single pass
  measured 16 ms against 431 ms for a file-by-file loop (27x), and the pattern is a regex so the script
  cannot match itself. One upstream defect fixed: `git grep` exits 1 both for "no match" and for some
  failures, so a search that never ran read as clean — a fatal exit now refuses with exit 2. A lone
  `=======` line is reported but does NOT fail, since a Markdown heading underline is legal and an
  always-red gate is worse than none. Canary 15/15, and it pins the blind spot (case 6: `sync-agents
  --check` passes on the file this gate rejects) so the reason for the gate is re-argument-proof.

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
