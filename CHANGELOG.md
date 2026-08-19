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
- `AGENTS.md` — the provider-neutral hub for ANY coding agent (Claude, Codex, Cursor, Gemini, Copilot,
  Windsurf, Cline, aider): the ordered onboarding contract (roadmap → in-progress → worklog → CLAUDE.md
  → rules), the non-negotiables, a first-class Architecture section, a `MIRROR` block (the "if you read
  nothing else" essentials), and an honest enforcement note. `CLAUDE.md` bridges to it via `@AGENTS.md`.
- `scripts/sync-agents.sh` — POSIX-sh DRY mirror generator that emits **self-contained** tool-native
  files: each mirror inlines the `AGENTS.md` `MIRROR` preamble followed by the full body of every
  `.claude/rules/*.md` module, so Cursor/Copilot/Windsurf/Cline/Gemini/aider/Codex get the COMPLETE
  ruleset from their own file — never a `.claude/rules/` pointer they cannot follow. `.cursor/rules/`
  gets one `alwaysApply` `.mdc` per module (+ a preamble file); `.github/copilot-instructions.md`,
  `GEMINI.md`, `CONVENTIONS.md`, `.clinerules/`, `.windsurf/rules/` each get one concatenated file. The
  generator also refills `AGENTS.md`'s `<!-- PANOPLY:RULES:BEGIN/END -->` block with the same bodies so
  AGENTS.md is self-contained without `@`-imports. `--check` is the drift gate (wired into
  `ci-verify.yml`) for pre-commit/CI. The kit ships the script, not the per-repo mirrors (they carry an
  unfilled `{{PROJECT_NAME}}` until `/adapt`).
- `scripts/templates/ci-verify.yml` + `scripts/templates/pre-commit` — the honest backstop: the one
  server-side plane (required CI) that binds every tool regardless of vendor, plus a convenience
  pre-commit hook. `<CMD>` slots filled by `/adapt`; branch-protection remains the one manual human step.
- `docs/claude/roadmap.md` — the single canonical strategic plan (initiatives in Now/Next/Later),
  step 2 of the onboarding contract.
- `docs/claude/worklog.md` — the running per-change history, created only when the repo keeps no
  `CHANGELOG`/`HISTORY` `[Unreleased]` log (never two parallel logs).
- docs: ship the /panoply skill + install instructions in README — `skills/panoply/SKILL.md` (the
  natural-language applier skill, now shipped inside the kit) plus a README section covering the
  trigger phrases and the one-time global install to `~/.claude/skills/panoply/SKILL.md`.

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
