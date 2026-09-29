# Worklog

Running record of what actually happened — **one line per meaningful change, written in the SAME
commit as the change.** Continuous / chronological view (`in-progress.md` is current *state*; this is
*history*). Newest first.

> **This file exists only when the repo has no running changelog.** If the repo keeps a `CHANGELOG.md`
> or `HISTORY.md` with an `## [Unreleased]` section, THAT is the worklog — append there and delete this
> file. Never keep two parallel running logs. `/adapt-claude-setup` picks the target and reports which
> one it chose.

A change earns a line when it lands source, config, schema, or shipped docs. Trivial typo / format-only
commits need none. The line is part of the diff, not a follow-up — **shipped-but-unlogged counts as not
done** (`.claude/rules/documentation.md`).

## Format

`- YYYY-MM-DD · <what changed, imperative> · \`<where: file or area>\` · <initiative / queue-row, if any>`

Append-only, never pruned. On ship: promote the durable entry to `completed-features.md` and move the
`roadmap.md` initiative, in the same commit.

<!-- new lines below, newest first -->

- 2026-01-01 · _EXAMPLE — delete this line_ — wire server-side paging into the records query · `ui/records-list` · Records UX overhaul
- 2026-09-29 · **the first-touch rule, in the one place every tool reads** — the MIRROR preamble in `AGENTS.md` now carries an explicit "adopt the kit before you modify anything" section with the `panoply.sh check` exit-code table, so it propagates automatically to every generated mirror (Codex/OpenCode via AGENTS.md, Cursor/Copilot/Windsurf/Cline/aider/Gemini via theirs) instead of living only in a Claude Code slash-command. Also fixes a gate bug the canary caught: the placeholder scan matched ANY `{{CAPS}}` run, so it flagged the kit's own convention metasyntax (`{{TOKEN}}`, `{{DOUBLE_BRACES}}`) and reported every correctly adopted repo as unadapted — it now matches only real adapt tokens.
- 2026-09-29 · add the kit's machine surface — `scripts/panoply.sh` (check/apply/stamp/version) + `scripts/panoply.test.sh` canary: the kit could only be applied by a Claude Code slash-command prompt and never recorded which version a repo received, so 'not applied' and 'applied in July' were indistinguishable to any non-Claude agent; check exits 0/10/11/12/13/14 (current/absent/partial/stale/placeholders/drifted) and the canary proves all six plus the escape hatch and the non-git passthrough · `scripts/panoply.sh` · Always-on kit adoption
