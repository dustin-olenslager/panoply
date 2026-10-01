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

2. **Fetch the kit into `<TARGET>/.agents-kit-tmp`.** The repo is public, so use
   `degit` (lighter, no upstream git history to entangle with yours):

   ```sh
   npx degit dustin-olenslager/panoply "<TARGET>/.agents-kit-tmp"
   ```

   (If `degit` is unavailable, an authenticated clone works too:
   `git clone --depth 1 https://github.com/dustin-olenslager/panoply "<TARGET>/.agents-kit-tmp"`
   then `rm -rf "<TARGET>/.agents-kit-tmp/.git"`.)

3. **Read and EXECUTE the kit's adapt command against TARGET.** Open
   `<TARGET>/.agents-kit-tmp/.agents/commands/adapt-agents-setup.md` and follow its
   instructions to the letter, treating `.agents-kit-tmp` as the staged kit and
   TARGET as the real project. The adapt command owns the whole job:

   - detects the stack (package manager, commands, frameworks, layers, data layer,
     tests, CI, default branch) from the real project;
   - fills every `{{PLACEHOLDER}}` with a verified value, and prunes modules,
     rules, and personas that do not apply;
   - MERGES into any pre-existing `AGENTS.md` / history — the
     project's own files win and are never overwritten;
   - seeds `docs/agents/roadmap.md` and the worklog (fresh `worklog.md`, or an
     existing `CHANGELOG`/`HISTORY` `[Unreleased]` section);
   - generates the provider-neutral mirrors via `scripts/sync-agents.sh` from the
     single-source `AGENTS.md` + `.agents/rules/*.md`;
   - installs the CI + pre-commit enforcement plane from `scripts/templates/`,
     including the docs landing gate (`scripts/check-docs.sh`) that fails any
     commit changing code but not the worklog in the same commit.

   Follow the adapt command's own question budget (it asks at most five, or none
   with `--yes`). Do not add or skip its steps.

4. **Clean up.** The adapt step removes `.agents-kit-tmp` when it finishes. If it
   is still there, delete it: `rm -rf "<TARGET>/.agents-kit-tmp"`.

5. **Report** what was filled / pruned / seeded / installed (the adapt command's
   Phase 5 report), plus the onboarding read-order the kit establishes: start at
   `AGENTS.md`, then `docs/agents/roadmap.md` + `docs/agents/in-progress.md`, then
   the deep rules under `.agents/rules/`.
