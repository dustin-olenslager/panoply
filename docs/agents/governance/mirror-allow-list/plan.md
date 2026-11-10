# Plan: a mirror allow-list for `sync-agents.sh`

- **Area:** `governance` · **Started:** 2026-11-10 · **Status:** In review
- **Owner:** a dev-kit builder session, for dev-kit's plugin-gaps plan (milestone M3)
- **Next step:** merge this PR (it carries the `hold` label, so it waits for Dustin). dev-kit then re-applies the kit and sets `.agents/mirrors` to `none`.
- **Spec:** none. This adds one optional input to an existing script and changes nothing for a repo that does not use it.

## What

`scripts/sync-agents.sh` writes every tool-native mirror in every repo: six single-file copies of the
rules index (`CLAUDE.md`, `GEMINI.md`, `CONVENTIONS.md`, `.github/copilot-instructions.md`,
`.clinerules/`, `.windsurf/`) and two sets of per-rule `.mdc` files (`.cursor/rules/`,
`.agents/rules/`). A repo cannot choose. dev-kit commits its mirrors, uses none of those tools except
Claude Code, and wants one instruction source: `AGENTS.md` plus a one-line `CLAUDE.md` that imports it
(Dustin's answer to Q1 of dev-kit's plugin-gaps plan, 2026-11-09). Because `sync-agents.sh` is a kit
file, changing it only in dev-kit would make `panoply.sh check` report drift, so the choice has to
exist in the kit.

After this ships, a repo lists the mirrors it wants in `.agents/mirrors`. A repo with no such file
gets exactly what it gets today.

## Design

- `.agents/mirrors`: one name per line, `#` comments. Names: `claude`, `copilot`, `gemini`,
  `conventions`, `cline`, `windsurf`, `cursor`, `agents-mdc`.
- No file: every mirror, as before. An empty file or the word `none`: no mirror, only the
  `AGENTS.md` index block.
- An unknown name stops the script with exit 1, so a typo cannot silently switch a mirror off.
- A mirror that is switched off and carries the GENERATED marker is removed on write. `--check`
  fails while one is still on disk, so it cannot linger and go stale.
- A file without the GENERATED marker is hand-written and is never touched. That is what lets a
  repo keep its own one-line `CLAUDE.md`.

## Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| The mirrors themselves, for every adopter | **kept** | Other adopters may use those tools; the default stays "all". |
| A config key per mirror in a new kit config format | **rejected** | The kit has no config file today; one plain list is the smallest input. |
| An environment variable instead of a file | **rejected** | CI and every contributor's shell would have to set it the same way; a committed file cannot disagree with itself. |
| Leaving switched-off mirrors on disk | **rejected** | A leftover generated file is read by its tool and goes stale without any check noticing. |
| The whole request | **not removed** | Without it the only way to drop a mirror is to fork a kit script, which the doctor reports as drift. |

## Acceptance

- With no `.agents/mirrors`, the script's output is unchanged and `panoply.test.sh` stays green.
- With a list, only the named mirrors exist after a write, and `--check` fails before that write.
- A hand-written `CLAUDE.md` survives `none`.
- `--check` still fails on a stale `AGENTS.md` index block when no mirror is generated.

## Milestones

- [x] The allow-list in the generator — `scripts/sync-agents.sh`
- [x] A canary for it, run in the self-tests job and installed by `panoply.sh apply` — `scripts/sync-agents.test.sh`
- [x] README and CHANGELOG say how to use it — `README.md`
- [x] Follow-up found applying it to dev-kit: the doc-map canary grades only a generated mirror, so a hand-written `CLAUDE.md` passes — `scripts/doc-map.test.sh`

## Review

- Adversarial pass on the diff, 2026-11-10. Checked: default path unchanged (no file means the old full set; `panoply.test.sh` 38 green); a typo in the list is refused, not ignored; removal is limited to files carrying the GENERATED marker, so canonical `.agents/rules/*.md` and hand-written files cannot be deleted; `--check` never writes or removes; empty directories left by a removal are cleaned only when empty.
- Known limit: a repo that switches `claude` off and has no `CLAUDE.md` of its own leaves Claude Code reading `AGENTS.md` natively, which works, but a hand-written one-line `CLAUDE.md` holding `@AGENTS.md` is the documented way.
