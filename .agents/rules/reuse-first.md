# Reuse first: search the sibling repos before building

> **Applies when:** a change builds a feature, screen, helper or automation, in any 10 Ton repo.
> **Delete this file (and its `@` import in the generated agent hub) if:** the repos share one package for
> every pattern in the reuse catalog.

Dustin, 2026-11-20: "I want to make sure that DevKit utilizes all of the code that we've written for each
platform ... I just want to make sure that the agents always know all of the code bases that we've written
out so that we don't have to rewrite code, that we can utilize already written code."

1. **Check the catalog.** dev-kit `docs/agents/reuse-catalog.md` (mirrored to gbrain
   `10ton/standards/reuse-catalog`) lists each shared pattern with its files in dev-kit, frameforge,
   backlot and production-toolkit. DevKit dispatch puts the matching entries in a job's brief.
2. **Search the sibling repos.** Before writing new code, search the other 10 Ton repos (on the VPS:
   `~/src/dev-kit`, `~/src/frameforge`, `~/src/backlot`, `~/src/production-toolkit`; `git -C <repo> grep`)
   for an existing implementation of the same behaviour, even when the catalog has no entry.
3. **Port or extract it.** Port the existing behaviour into this repo's layers (Clean Architecture still
   holds: the ported logic goes in the right layer, its I/O behind this repo's ports). When a third copy
   would appear, extract a shared piece instead and say so in the plan.
4. **Name the source in the PR.** The PR body's `## Patterns reused` section names the repo and path you
   started from, or says `none found` after the search. Write the words; a missing section is a review
   finding.
5. **Keep the catalog current.** A PR that creates a new reusable pattern, or moves a listed file, updates
   its catalog entry in dev-kit in a follow-up PR the same day.
