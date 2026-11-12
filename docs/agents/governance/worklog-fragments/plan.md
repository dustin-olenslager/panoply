# Plan: worklog fragments, one file per change

- **Area:** `governance` · **Started:** 2026-11-12 · **Status:** In review
- **Owner:** a 10 Ton session rolling the decision out to Panoply, dev-kit, backlot and ff-assets
- **Next step:** merge this PR when green, then each adopter repo syncs `scripts/check-docs.sh` and migrates (first fragment, frozen `worklog.md`).
- **Spec:** none. One gate changes behaviour behind an opt-in directory; no new feature surface.

## What

One shared worklog file means every merge to the default branch puts every other open PR into a
conflict on that file, and each fix costs a CI re-run. Dustin decided on 2026-11-12: all repos, via
Panoply, one small file per entry. The precedent is ADR-0006, which moved the backlog to one file per
task for the same reason.

## Design

- Entries live in `docs/agents/worklog.d/<YYYY-MM-DD>-<slug>.md`, same content style as a log line.
- `scripts/check-docs.sh` passes a code change that ADDS a file under the fragment dir (`git diff
  --name-status`, status `A`, no rename detection). Modified or deleted fragments, dotfiles and
  `README.md` do not count. `DOCS_WORKLOG_DIR` moves the dir; `DOCS_WORKLOG` still works.
- A repo is migrated when the fragment dir exists. Then only fragments (or an explicit `DOCS_WORKLOG`)
  satisfy the gate, so the frozen `worklog.md` cannot quietly become the shared file again. Without
  the dir the legacy target (`CHANGELOG.md` / `HISTORY.md` / `worklog.md`) behaves exactly as before.
- Migration is opt-in: `panoply.sh apply` does not create the dir, so an external adopter keeps its
  current log until it chooses to move.

## Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| Merge-driver or `union` gitattribute on `worklog.md` | **rejected** | It hides the conflict locally but needs per-clone config, does nothing for GitHub's merge button, and leaves entries interleaved out of order. One file per change removes the shared path instead. |
| Appending to the frozen `worklog.md` still passing the gate | **removed** | Allowing it would let the shared file return. Migrated repos accept fragments only. |
| Requiring a strict filename pattern | **removed** | Presence is what the gate enforces; a name check adds a failure mode for no gain. Names are by convention. |
| A generated rollup file of all fragments | **not built** | `ls` already sorts by date. A committed rollup would be a shared file again. |

## Milestones

- [x] Gate and canary, cases 9-16 — `scripts/check-docs.sh`, `scripts/check-docs.test.sh`
- [x] Rule text, hub, templates and commands say fragments — `.agents/rules/documentation.md`, `AGENTS.md`, `scripts/templates/`
- [ ] Roll out to dev-kit, backlot and ff-assets through each repo's own sync path, with `hold` on the PRs

## Launch

- **Launched** by merging this PR; adopters get the gate on their next sync and migrate by creating `worklog.d/`.
- **Rollback:** revert the PR, or in an adopter delete `worklog.d/`, which returns it to the legacy target.
