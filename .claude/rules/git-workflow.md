# Git Workflow: Commits, PRs, Branching

> **Applies when:** the project is version-controlled with git and changes land through pull requests.
> **Delete this file (and its `@` import in CLAUDE.md) if:** the project is not in git, or has no PR/review process at all.

## Commits

- Use conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `test:`, `chore:`, `docs:`. They make the history greppable and let release tooling derive changelogs without human curation.
- **Keep commits atomic — one logical change per commit.** A commit that does two things cannot be reverted, cherry-picked, or bisected without dragging the other one along.
- **Do not mix a domain change and an infrastructure change in one commit.** A commit that alters a business rule *and* swaps an adapter, ORM call, or vendor client leaves the reviewer no way to tell which half changed the behaviour — and if it has to be reverted, both halves go. Split them along the layer boundary (see `clean-architecture.md`); the domain commit is the one that needs real scrutiny.
- **Never push directly to `{{DEFAULT_BRANCH}}`.** All work lands via a branch and a PR, so every change has a reviewable diff and a revert point.
- **Remind the user to commit at the end of each feature or milestone** — they forget, and uncommitted work is the one kind of work that a crashed machine or a bad `git checkout` can delete outright.

## Pre-commit gates (both, every time)

- **Run the FULL typecheck before committing: `{{TYPECHECK_CMD}}`.** Every package, unfiltered — do not grep the output, and do not spot-check only the files you changed. A type error in an untouched package that your change broke through a shared type is exactly the failure this catches, and partial checks have shipped broken CI more than once.
- **Run the full test suite before committing: `{{TEST_CMD}}`.** All tests must pass. Do not skip, `.only`, or comment out a failing test to get a commit through — fix the code, or stop and report the failure.
- If a change alters query structure, response shapes, or call ordering, update the corresponding test fixtures and mocks in the same commit — see "Sequentially-consumed mocks go stale" in `testing.md` for the failure mode and how to spot it.
- Both gates run before the commit, not before the push. A local commit you have not verified is a commit you will push at 6pm without rechecking.

## Branching

- **Always branch from an up-to-date `{{DEFAULT_BRANCH}}`.** Fetch first: `git fetch origin && git switch -c <branch> origin/{{DEFAULT_BRANCH}}`. Branching from a stale local copy imports every conflict that landed since you last pulled.
- **Do not branch from another feature branch or an open PR's branch (no stacked PRs) — the default with exactly one exception, below.** PRs are squash-merged, which rewrites the base PR's commits into a single new SHA. The stacked branch still carries the *original* commits, so after the base merges, your branch will conflict with its own already-merged changes — a conflict that looks impossible and wastes an afternoon.
- If new work depends on an unmerged PR, the rule is: wait for it to merge, then branch fresh from `{{DEFAULT_BRANCH}}`. The one exception: you are truly blocked and waiting is not an option — then stack, flag it prominently in the PR description so the reviewer knows the base is moving, and expect to run the recovery below after the base squash-merges.

### Recovery: already stacked on a squash-merged branch

Do not run a plain `git rebase {{DEFAULT_BRANCH}}` — it replays the duplicated commits and recreates every conflict. Drop the old base's commits instead:

```
git fetch origin
git rebase --onto origin/{{DEFAULT_BRANCH}} <old-base-branch-tip>
```

`<old-base-branch-tip>` is the last commit that belonged to the base branch (its SHA before the squash-merge, or `origin/<old-base>` if the ref still exists). Everything after that point replays cleanly onto the new base.

### Before you ship, merge, or delete a branch: prove it carries unmerged work

A branch showing commits "ahead" of `{{DEFAULT_BRANCH}}` is *not* proof it holds unmerged work. A squash-merge collapses the branch's commits into one new SHA on `{{DEFAULT_BRANCH}}` and leaves the original branch behind with its old commits, so `git log` and `git status` keep calling it "ahead" long after every line it changed has landed — the same rewrite behind the stacked-branch trap above. Trust the diff, not the ahead count.

- **Run `git cherry -v {{DEFAULT_BRANCH}} <branch>` before you open a PR, merge, or ship a branch.** A line prefixed `-` is a commit whose change is already present on `{{DEFAULT_BRANCH}}` (an equivalent patch merged); a line prefixed `+` is genuinely unmerged. All `-` means the branch carries nothing new — do not merge it, and do not "resolve" the phantom conflicts a re-merge invents against already-merged code. `git diff {{DEFAULT_BRANCH}}...<branch>` (three dots) is the same verdict from the other side: an empty diff means nothing to ship.
- **Only a branch with `+` lines is work.** Everything else is cleanup, not a merge.
- **Delete a verified-merged branch, but record its tip SHA first so the delete is reversible.** `git rev-parse <branch>` and note the branch name + SHA in the PR or `HISTORY.md`/`CHANGELOG` before deleting — deleting a merged branch loses nothing but the ref, and the ref is the only way back if the check was wrong (`git branch <name> <sha>` restores it). Then delete both ends and prune: `git push origin --delete <branch>`, then `git fetch --prune` so every checkout drops its dead remote-tracking ref.
- **`git branch -d` is a weaker check than `git cherry`, not a stronger one.** For a squash-merged branch `-d` *refuses* ("not fully merged") because git never sees the collapsed SHA as an ancestor. When `git cherry` has already proved the branch is fully merged but `-d` still refuses, re-read the cherry output once, then delete with `git branch -D` — the cherry check is the authority here, not `-d`.

## Keeping branches fresh

- **Rebase open PR branches onto `{{DEFAULT_BRANCH}}` every 1–2 days.** Small, frequent rebases produce one or two trivial conflicts; a week of drift produces a wall of them, and a wall of conflicts is where correct code gets resolved away by accident.
- Rebase before requesting review, so the reviewer reads the diff that will actually merge.
- After rebasing a pushed branch, force-push with `git push --force-with-lease` — never a bare `--force`, which will silently discard a collaborator's commits pushed since your last fetch.

## Repo hygiene & credentials

- **Verify commit identity before the first commit in a fresh clone.** A freshly reset or provisioned machine has empty git identity, so the first commit lands under the wrong author. Before committing in any new clone, confirm `git config user.name` and `git config user.email` match the identity this repo declares it commits under (in `CLAUDE.md`/`AGENTS.md`); set them **repo-locally** (`git config user.email …`, never `--global`) if they do not. The check is portable even though the value is per-project — the author the repo commits under is declared in-repo.
- **Never put a credential in the remote URL, and never commit a secret.** Keep secrets in env or a secret store; keep git auth in a credential helper (`git config credential.helper`, `~/.git-credentials`, or the OS keychain) so the remote stays `https://github.com/<owner>/<repo>.git` — never `https://<user>:<token>@github.com/...`. A token in the URL leaks through `git remote -v`, shell history, CI logs, and the reflog, and removing it does not un-expose it: if one was ever embedded, **rotate it.**

## Pull requests

- The PR description states what changed and why, and links the plan doc under `docs/claude/` when there is one.
- Keep the PR scoped to the approved change. Unrelated drive-by fixes belong in their own PR, where they can be reviewed on their own merits.
- Never merge your own PR past a failing CI job by re-running it until it goes green — a flaky test is a bug report, not an obstacle.
