# Plan: the docs gate checks a PR once, not every commit

- **Area:** `governance` · **Started:** 2026-11-09 · **Status:** In review
- **Owner:** Dustin (ruling 2026-11-09, "Once per PR (Recommended)"); built by Claude
- **Next step:** merge once `verify` is green; adopting repos pick it up on their next `panoply.sh apply`.
- **Roadmap initiative:** none (kit gate tuning)
- **Spec:** n/a — routine. One CI gate's scope changes; behaviour is fixed by its canary tests.
- **Domain & experts:** CI and repository governance; the evidence is lanes failing "Docs in sync" on an intermediate commit of PRs that did carry their CHANGELOG line.

## Goal

A PR that changes code passes "Docs in sync" when its CHANGELOG line sits anywhere in the PR's diff against its base, not in every commit. What lands on the default branch stays strict: every commit pushed to the default branch must carry its own line.

**Out of scope:** what counts as code (`DOCS_EXEMPT`, `docs/audit/`), the worklog target, the content of the line.

## Architecture

- **Layers touched:** kit scripts and rules only. `scripts/check-docs.sh`, `.github/workflows/verify.yml`, `scripts/templates/ci-verify.yml`, the rule text in `AGENTS.md`, `.agents/rules/documentation.md`, `.agents/rules/git-workflow.md`.
- **Modes:** `--since REF` (pull requests) diffs `merge-base(REF, HEAD)..HEAD` once, so the default branch merged into the PR is not charged to it. `--each-commit REF` (pushes to the default branch, new CI step on `github.event.before`) walks every non-merge commit; forty zeros (a new branch) means HEAD alone. No flag (pre-commit) checks the staged change plus what the branch already changed since `origin/HEAD` / `origin/main` (`DOCS_BASE` overrides).

## Milestones

- [x] Build, with tests — `scripts/check-docs.test.sh` cases 6–11 (per-PR pass and refuse, merged-main not charged, each-commit strict and pass, all-zero before, pre-commit on a branch)
- [x] Built first in Backlot (10-ton-productions/backlot#220), ported here without Backlot's `docs/audit/` exemption
- [ ] Merged and deployed

## Risks

- A failing `Docs in sync (default branch, every commit)` makes the default branch red (and holds any deploy gated on it). That is the intended strictness: with squash merges every PR leaves one commit carrying its own line, so it only fires on a direct push without one.
- A force-push to the default branch can leave `before` outside the clone; the gate then fails loudly rather than passing silently.
