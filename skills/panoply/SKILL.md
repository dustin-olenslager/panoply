---
name: panoply
description: Apply the Panoply project kit to a new or existing repo — fetch it and adapt it (stack detection, fill/prune/merge, seed roadmap+worklog, provider mirrors, CI+pre-commit). Use when the user says "use panoply", "apply panoply", "set this project up with panoply", or "panoply this". Accepts an optional target path (default: cwd).
---

# Panoply

Thin trigger. Fetch the Panoply kit, then hand off ALL adaptation to the kit's
own adapt command. This skill stays dumb; the kit is smart. Do not reimplement
or second-guess the adapt logic here — read the kit's file and execute it.

## Steps

1. **Resolve TARGET.** Use the path argument if given, else the current working
   directory. Decide whether TARGET is a *new* project (empty or near-empty — no
   real source, maybe only a README/LICENSE) or an *existing* one (has source,
   git history, manifests). This new-vs-existing read is context the adapt step
   uses; note it and pass it along.

2. **Fetch the kit into `<TARGET>/.claude-kit-tmp`.** The repo is public, so use
   `degit` (lighter, no upstream git history to entangle with yours):

   ```sh
   npx degit dustin-olenslager/panoply "<TARGET>/.claude-kit-tmp"
   ```

   (If `degit` is unavailable, an authenticated clone works too:
   `git clone --depth 1 https://github.com/dustin-olenslager/panoply "<TARGET>/.claude-kit-tmp"`
   then `rm -rf "<TARGET>/.claude-kit-tmp/.git"`.)

3. **Read and EXECUTE the kit's adapt command against TARGET.** Open
   `<TARGET>/.claude-kit-tmp/.claude/commands/adapt-claude-setup.md` and follow its
   instructions to the letter, treating `.claude-kit-tmp` as the staged kit and
   TARGET as the real project. The adapt command owns the whole job:

   - detects the stack (package manager, commands, frameworks, layers, data layer,
     tests, CI, default branch) from the real project;
   - fills every `{{PLACEHOLDER}}` with a verified value, and prunes modules,
     rules, and agents that do not apply;
   - MERGES into any pre-existing `CLAUDE.md` / `AGENTS.md` / history — the
     project's own files win and are never overwritten;
   - seeds `docs/claude/roadmap.md` and the worklog (fresh `worklog.md`, or an
     existing `CHANGELOG`/`HISTORY` `[Unreleased]` section);
   - generates the provider mirrors via `scripts/sync-agents.sh` (Copilot, Cursor,
     Cline, Windsurf, Gemini, aider) from the single-source `AGENTS.md`;
   - installs the CI + pre-commit enforcement plane from `scripts/templates/`,
     including the docs landing gate (`scripts/check-docs.sh`) that fails any
     commit changing code but not the worklog in the same commit.

   Follow the adapt command's own question budget (it asks at most five, or none
   with `--yes`). Do not add or skip its steps.

4. **Clean up.** The adapt step removes `.claude-kit-tmp` when it finishes. If it
   is still there, delete it: `rm -rf "<TARGET>/.claude-kit-tmp"`.

5. **Report** what was filled / pruned / seeded / installed (the adapt command's
   Phase 5 report), plus the onboarding read-order the kit establishes: start at
   `AGENTS.md`, then `docs/claude/roadmap.md` + `docs/claude/in-progress.md`, then
   the deep rules under `.claude/rules/`.
