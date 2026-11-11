# Plan: a warn-only PR size check

- **Area:** `governance` · **Started:** 2026-11-11 · **Status:** In review
- **Owner:** a dev-kit session upstreaming dev-kit's two 2026-11-10 checks (dev-kit #53/#54/#55)
- **Next step:** merge this PR once green. A rule module that names the size limits is a separate PR, held for Dustin's ratification.
- **Spec:** none. One new warn-only script; nothing existing changes behaviour.

## What

Large PRs are where review stops reading. dev-kit added `scripts/check-pr-size.sh` (dev-kit #55):
past 300 changed lines or 10 files it prints a CI warning and labels the PR `big`, and it never fails
the build. This brings it to the kit, with dev-kit's stack-specific excludes (BMAD paths) dropped.

## Design

- Counts `git diff --numstat <base>...HEAD`, skipping binaries and excluded globs: `docs/*`, `*.md`,
  `*.mdc`, `.clinerules/*`, `.windsurf/*` (generated mirrors), `*.lock`, `package-lock.json`,
  `pnpm-lock.yaml`, `go.sum`. `SIZE_EXCLUDE` adds globs; `SIZE_MAX_LINES` / `SIZE_MAX_FILES` tune the limits.
- Writes `big=true|false` to `$GITHUB_OUTPUT`; a separate `size` job adds the label, so the
  `pull-requests: write` permission stays out of the required `verify` job.
- Fix over the dev-kit copy: the exclude list was word-split with pathname expansion on, so `docs/*`
  expanded to the tree's top-level entries and `docs/area/x.md` was counted. `set -f` stops that.

## Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| Failing the build on a big PR | **rejected** | Some changes cannot split (a generated migration, a vendored file); a hard gate would teach people to reach for an escape hatch. |
| The `big` label | **kept** | It is what makes the warning visible in the PR list; the step tolerates a repo without the label. |
| dev-kit's BMAD and plugin-asset excludes | **removed** | Stack-specific; an adopter adds its own through `SIZE_EXCLUDE`. |
| Porting dev-kit's progress-board gate (`check-progress-board.sh`) | **not ported** | It validates `.agents/progress-board.json`, a file only 10 Ton's VPS board engine reads. Upstream there is no engine, so an opt-in gate would check a config nothing consumes. Revisit if the engine itself is ever offered to the kit. |

## Milestones

- [x] Script and canary, 8 cases, two of which fail against the dev-kit copy — `scripts/check-pr-size.test.sh`
- [x] Wired into the kit's CI: a `size` job on PRs and a step in the self-tests job — `.github/workflows/verify.yml`
- [x] Shipped to adopters: the same job and step in the template, so `panoply.sh apply` installs the script and its canary — `scripts/templates/ci-verify.yml`
- [ ] Rule text naming the limits and the split-or-explain duty (separate PR, `hold`, needs Dustin's ratification)
