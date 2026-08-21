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

Provider-agnostic governance layer (MINOR — additive; safe to adopt).

### Added
- `scripts/check-docs.sh` — the docs landing gate: fails any commit that changes a non-markdown file
  (source, config, schema, scripts, CI) but not the worklog target in the same commit. Enforces the
  same-change update contract mechanically, provider-neutrally (runs in required CI + pre-commit), so
  no agent in any tool can land a code change without its doc update. Worklog target auto-detected
  (`CHANGELOG.md`/`HISTORY.md`, else `docs/claude/worklog.md`), overridable via `DOCS_WORKLOG`.
  Wired into `scripts/templates/pre-commit` and `scripts/templates/ci-verify.yml` (`--since origin/main`).
- `scripts/init-repo-protection.sh` — interactive branch protection setup via `gh` CLI: configures
  default branch to require PR, require `verify` check, forbid force-push, forbid direct push. Prompts
  for confirmation; falls back to manual instructions if `gh` unavailable. Wired into adapt command
  Phase 10.
- `scripts/check-expert-review.sh` — CI gate verifying expert review evidence for non-trivial PRs:
  plan.md exists, checklist.md has pending items, adr.md has new section since base, PR description
  has ≥2 persona sign-offs (Security, Performance, Maintainability, UX, or domain-specific). Trivial
  escape: PR label "trivial", commit prefix "trivial:", or 1-file ≤15-line no-schema change.
- Expert-review policy in `.claude/rules/workflow.md` and `AGENTS.md`: non-trivial changes require
  structured review with 4 default personas; evidence checked by `check-expert-review.sh` in CI.
  Conflict escalation to operator via ADR.
- Provider mirrors regenerated via `sync-agents.sh` — all mirrors in sync with updated workflow.md.

### Changed
- Provider mirrors are now **self-contained**: `sync-agents.sh` inlines the full `.claude/rules/*.md`
  bodies into every tool file and into `AGENTS.md`'s `PANOPLY:RULES` block (was: a header + `MIRROR`
  block + a pointer to `.claude/rules/` no non-Claude tool could follow). `AGENTS.md` carries the
  `PANOPLY:RULES` markers; `ci-verify.yml` runs `sync-agents.sh --check` so drift fails CI for every tool;
  `adapt-claude-setup.md` runs the inlining generator last (after rules are pruned) and verifies no
  mirror is a bare pointer.
- `.claude/rules/clean-architecture.md` — new module-fenced **Enforcement** gate: names the per-stack
  boundary linter (dependency-cruiser / import-linter / ArchUnit / …), the report-only→blocking ramp,
  and "CI is the binding plane"; review-checklist item 1 now points at `{{ARCH_CHECK_CMD}}`.
- `.claude/rules/documentation.md` — the four-altitude anti-redundancy table (roadmap / in-progress /
  worklog / completed-features) and the same-change update contract binding every provider.
- `.claude/rules/git-workflow.md` — module-fenced arch-boundary pre-commit gate, and the
  enforcement-plane note (the `settings.json` deny binds only Claude; server-side CI binds all tools).
- `.claude/commands/adapt-claude-setup.md` — detects the running log + provider files + arch linter,
  scaffolds roadmap/worklog, emits `AGENTS.md` + runs `sync-agents.sh`, copies the CI/pre-commit
  templates, extends the porcelain allowlist, and reports the worklog target + mirrors + manual step.
- `.claude/commands/audit-claude-setup.md` — Check 4 worklog/roadmap-currency, Check 5 AGENTS.md
  presence + deny↔guardrails sync, Check 6 "wired, not just installed", and new Check 7 (provider hub
  read-order + mirror-drift + inline-doctrine).
- `CLAUDE.md` — `@AGENTS.md` bridge, module-fenced arch-boundary command row, roadmap + worklog in
  Project Knowledge.
- `docs/claude/_templates/plan.md` — a Roadmap-initiative field, a forced **Architecture** section
  (layers/ports/DTOs/direction/swap-test), and worklog/roadmap moves in the On-ship step.
- `docs/claude/in-progress.md` — an Initiative column and the tactical→strategic roll-up note.
- `docs/claude/README.md` — read order, layout, and doc lifecycle now name roadmap + worklog.
- docs: describe the install as provider-agnostic (AGENTS.md hub + mirrors + CI), not Claude-only.

## [1.0.0] — 2026-08-19

Initial published release of the Panoply kit (`dustin-olenslager/panoply`), fetched with
`npx degit dustin-olenslager/panoply` and wired in by `/adapt-claude-setup`.

### Added
- Initial kit: `CLAUDE.md` spine, `.claude/rules/*`, `.claude/agents/*`,
  `.claude/commands/{adapt,audit,assess}-*.md`, `settings.json`, and the `docs/claude/` scaffold.
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
- `audit-claude-setup.md` → Check 4: shipped-but-unlogged detector (diff merges since the newest
  completed-log entry against the log + `in-progress.md`; flag active items with no Next step).
- `docs/claude/_templates/plan.md`: a `Next step` handoff field.
- `docs/claude/in-progress.md`: the Notes cell reframed as the active row's handoff.
- This `CHANGELOG.md` and the versioned GitHub repo it lives in.
