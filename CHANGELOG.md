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

_Nothing yet._

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
