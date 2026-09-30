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
- 2026-09-29 · **apply can now reach a state an agent can finish** — running the adoption runbook end to end on a scratch repo exposed two defects that made it a dead end. (1) `apply` seeded the spine and rule modules but never `AGENTS.md`, so every adoption stalled at exit 11 ("half-applied — missing AGENTS.md") with no hub file to fill; it now seeds the kit template when the repo has no hub of its own, and stays out of the way when it does. (2) `apply` did not install `panoply.sh` itself, so the runbook's final `sh scripts/panoply.sh check` could not run in the adopted repo at all. Copying the doctor in turn exposed a third: from there `$0` resolves to the ADOPTER, so `_kit_version` read that repo's own unrelated tag — a compliant repo with a product tag reported "stale" on every run, permanently. Version resolution now detects a copied doctor and resolves from the canonical clone, falling back to the stamp. Canary gained 5 checks (10 → 14) covering all three, each mutation-tested.
- 2026-09-29 · **the first-touch rule, in the one place every tool reads** — the MIRROR preamble in `AGENTS.md` now carries an explicit "adopt the kit before you modify anything" section with the `panoply.sh check` exit-code table, so it propagates automatically to every generated mirror (Codex/OpenCode via AGENTS.md, Cursor/Copilot/Windsurf/Cline/aider/Gemini via theirs) instead of living only in a Claude Code slash-command. Also fixes a gate bug the canary caught: the placeholder scan matched ANY `{{CAPS}}` run, so it flagged the kit's own convention metasyntax (`{{TOKEN}}`, `{{DOUBLE_BRACES}}`) and reported every correctly adopted repo as unadapted — it now matches only real adapt tokens.
- 2026-09-29 · add the kit's machine surface — `scripts/panoply.sh` (check/apply/stamp/version) + `scripts/panoply.test.sh` canary: the kit could only be applied by a Claude Code slash-command prompt and never recorded which version a repo received, so 'not applied' and 'applied in July' were indistinguishable to any non-Claude agent; check exits 0/10/11/12/13/14 (current/absent/partial/stale/placeholders/drifted) and the canary proves all six plus the escape hatch and the non-git passthrough · `scripts/panoply.sh` · Always-on kit adoption
- 2026-09-30 · **the canary no longer false-reds inside an adopter** — an independent review reported the canary failing `16 ok / 1 failed` from an adopted repo. The reviewer's stated cause (mirror drift checked before placeholders) was **wrong**; the real mechanism is hermeticity. The canary derives its kit root from `$0` and builds fixtures by copying *the kit's* `AGENTS.md`, rule modules and `sync-agents.sh`. Run from an adopter, that adopter becomes the 'kit' — its modules are already token-free, so `apply` seeds a repo with no placeholders, case 10's 'post-apply is unadapted (13)' can never hold and the repo reports drift (14) instead. A false red in the one gate adopters are told to run is worse than no gate: it teaches people to ignore a failure. It now detects a non-template root and **skips loudly** (exit 0, names the real verify commands), with `PANOPLY_KIT_ROOT` to point at a real checkout. Mutation-tested: remove the guard and the false `FAIL` returns.
- 2026-09-30 · **`apply` no longer silently clobbers a locally-edited script** — an independent review of the a pilot repo refresh found that `apply` copied `sync-agents.sh`, `check-docs.sh` and `check-plan-home.sh` over the repo's own copies with no note at all, while rule modules already reported divergence. a pilot repo's `check-docs.sh` carries a conflict-marker sweep the kit template lacks, so the next `apply` there would have deleted a capability and said nothing. Scripts now follow the same contract as modules: install when absent, **KEEP and report** when the repo's copy differs, and replace only under an explicit `apply --force-scripts` (documented in the checklist). Canary 14 → 17 checks, mutation-tested.
