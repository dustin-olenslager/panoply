# Plan: Context Budget — a doc map, and mirrors that ship the ruleset once

- **Area:** `governance`  ·  **Started:** 2026-10-04  ·  **Status:** In progress
- **Owner:** the owner
- **Next step:** none — all milestones landed in `fix/verified-sme-findings`; the follow-up is a CI
  run on that branch, then merge. If CI is red, read the failing gate's own message first: every gate
  here names the remedy it wants.
- **Roadmap initiative:** governance hardening — the kit's own trustworthiness as it is applied to repos.
- **Spec:** none — this is a **fix inside an existing pattern**, not a structural change. The kit already
  had a rule index (`AGENTS.md` renders one via `render_index`); this change extends that existing
  mechanism to the generated mirrors that were left behind, adds a read-side tool for document cost,
  and adds a canary. No new requirement, no new layer, no user-facing surface. If it grows one, it earns
  a spec then.
- **Domain & experts:** software governance — no non-software expert applies to a shell tool that
  indexes markdown. Prior art WAS consulted rather than re-derived: aider's tree-sitter/PageRank repo
  map, and the Codebase-Memory paper (83% answer quality vs 92% file-exploration, at 10x fewer tokens).
  That evidence is why the code-map variant is explicitly deferred below rather than dismissed.
- **Parent plan:** none

## Goal

An agent can find out **which document matters and what it costs** before opening anything, and the
generated tool-native mirrors stop re-shipping the entire ruleset in five files.

After this ships: `sh scripts/doc-map.sh` prints every document's declared purpose, size and freshness
in ~2k tokens; a tool reading `CLAUDE.md` gets the preamble plus an index of every rule module instead
of a truncated 184 KB blob; and conditional rules (`api-design`, `database`, `frontend`, …) load only
when the work matches. It worked if the canary passes and the mirrors stay under 10 KB each.

**Out of scope:** a code map (tree-sitter, symbols, PageRank); a committed generated index; any
dashboard measuring whether the map improves outcomes.

## Context

An agent orienting in a repo greps, opens files, and reads whole documents to discover which one
matters. Measured here: **1.82 MB of markdown vs 341 KB of shell** — the docs are 5x the code, so the
token cost is in the docs and a code map would index the small half.

`AGENTS.md` was **already** converted to an index for this reason. Its own comment in
`scripts/sync-agents.sh` records why: inlining the rule bodies there

> "did NOT achieve the self-containment it claimed (the middle was silently dropped), while
> contradicting the kit's own 'one fact, one home' doctrine by shipping every rule body twice."

The mirrors generated 20 lines later kept inlining everything. A file that states the reason inlining
fails, then does it five more times, is the defect class this kit exists to refuse — and it was sitting
in the kit's own generator.

Two hidden costs:
1. **Each mirror inlined all ~184 KB of rule bodies** — ~47,000 tokens at session start — while
   describing itself as self-contained. Harnesses cap the file, so the middle was silently dropped:
   neither small nor complete, and the claim of completeness was false.
2. **Every Cursor `.mdc` was `alwaysApply: true`**, force-loading the whole corpus whatever the task,
   including rules that declare themselves conditional.

## Architecture

- **Layers touched:** none — this is tooling and generated artifacts at the repo edge. No application
  layer is involved; the kit is shell scripts plus markdown.
- **New ports (interfaces):** none. `doc-map.sh`'s CLI (`--json` for machines, table for humans) is a
  command surface, not an architectural port.
- **Boundary data:** the `--json` shape `{docs:[{kind,bytes,lines,mtime,path,title,applies_when,cold}]}`
  — a flat record set, no identity or domain object crossing a layer.
- **Dependency direction:** inward-only by construction: POSIX sh + awk, zero external packages. The
  tool cannot introduce a dependency because none is available to it.
- **Swap test:** not applicable — there is no vendor or framework to replace.

## The Algorithm pass

- **Question** — the owner, mid-session: repos that document their own structure should be folded in so
  that agents use more context and fewer tokens. The constraint it serves: the owner explicitly wants
  **more context and less token spend**, and flagged repo-structure documentation as the mechanism.
- **Delete** — six candidates named below; four removed outright, one narrowed, one rejected with a
  replacement. The most important removal is the **second index of the plan spine**: the kit already
  indexes queued work and gates it, so a map that duplicated it would be a drifting second truth.
- **Simplify** — least shape: one shell script that reads the tree on demand (no cache, so it cannot go
  stale), plus reusing the **existing** `render_index` in `build_mirror` rather than writing a new
  renderer. The mirror change is a 3-line substitution, not a subsystem.
- **Accelerate** — measured, before → after:
  - `CLAUDE.md`: **47,187 → 1,769 tokens** (27x), and now genuinely complete rather than truncated.
  - Cursor tokens forced at session start: **~47,000 → ~20,592** (2.3x), with 12 of 20 rules scoped.
  - Bottleneck named: it was never the shell — it was that the mirrors inlined the corpus and the
    `.mdc`s force-loaded it. The cost was duplicated rule bodies, not computation.
- **Automate** — last, and only what survived: a canary that fails if inlining or force-loading returns.
  Deliberately NOT automated: a committed index, or a metric of whether the map helps (no named number
  → no dashboard).

### Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| A second index of the plan/queue spine | yes | `roadmap.md` + `in-progress.md` + `check-plan-home.sh` already index queued work and gate it; a duplicate would drift, and an agent could not tell which was authoritative | The map carries only what the spine does not: size, freshness, and declared purpose |
| A cached/precomputed map | yes | A cache is the failure mode of every code-map tool — it goes stale, and a stale map is worse than none because you stop looking | Read the tree on demand; ~2k tokens of output, no state to rot |
| A tree-sitter / PageRank code map | rejected | Prior art is proven (Codebase-Memory: 83% quality vs 92% at 10x fewer tokens) but it indexes the **code**, and here the code is the small half | Deferred until a repo's ratio inverts; the technique is unproven *for this shape*, not unproven |
| A committed generated `docs/INDEX.md` | yes | Needs regenerating, drifts silently, and becomes a second copy of constantly-changing truth | `doc-map.sh` prints the same thing on demand |
| Stripping the rule bodies from the mirrors entirely | rejected | A tool that reads only `CLAUDE.md` and cannot follow a path would then get **no rules at all** | Ship the index: a tool with file access loses nothing, one without still gets the preamble and the module list |
| `alwaysApply: false` on ALL modules | yes | Universal rules (`workflow`, `algorithm`, `code-style`) would load only if the tool guessed to ask | The module's own declared `Applies when:` decides — 8 always-on, 12 scoped |

## Milestones

Each milestone is one line carrying its evidence reference — the gate reads the milestone **line**, so
a path on a continuation line is invisible to it. Detail goes in Build notes.

- [x] **M1 — the doc map** — indexes every document (declared purpose, size, freshness, kind), marks history as cold storage, POSIX sh + awk, no cache; verified against `find` on all 85 docs. Evidence: `scripts/doc-map.sh`
- [x] **M2 — mirrors render an index, not the corpus** — the mirror builder calls the existing rule-index renderer; 47,187 → 1,769 tokens, all 19 modules named. Evidence: `scripts/sync-agents.sh`
- [x] **M3 — conditional rules stop force-loading** — the Cursor module builder reads each rule's own declared condition; 8 of 20 always-on, 12 scoped. Evidence: `scripts/sync-agents.sh`
- [x] **M4 — the canary, mutation-tested** — 12 checks; re-inlining the corpus and force-loading every rule are both caught. Evidence: `scripts/doc-map.test.sh`
- [x] **M5 — wired and documented** — canary registered in the kit's CI and the adopter template; cost section in the documentation doctrine. Evidence: `.github/workflows/verify.yml`

## Open questions

None blocking.

## Build notes

> **Build note:** 2026-10-04 — the first cut of `doc-map.sh` called a warm-doc total "the orientation
> budget" (437K tokens). It answered no question an agent has, since nothing loads every warm doc. The
> summary now says what the number is and names the five documents that cost the most to open blind.

> **Build note:** 2026-10-04 — the `Applies when:` extractor stopped at bold markup, so the condition
> rendered as `"** the app is expected to…"` — markup in front of the sentence, subject lost. The rules
> write the condition in bold, so the markup is folded into the class and the words survive.

> **Build note:** 2026-10-04 — **two defects found only by using the tool**, neither predicted, both the
> same class: *a run that looked like it checked and had not.* (a) the flag parser read only `$1`, so
> `--dir X --check` silently ignored `--check` and printed a table — any multi-flag call was quietly
> wrong; (b) the classifier matched relative paths only, so `--dir /abs --check` classified every file
> as an ordinary doc and **passed a repo whose rules were unindexable** — the same failure class as the
> M5 CI-only defect, where a check ran somewhere other than where it believed it was. Both fixed; the
> canary covers the multi-flag form.

> **Build note:** 2026-10-04 — I nearly reported the mirrors as tracked-in-git bloat. They are
> **gitignored**; my byte-count pipeline returned 0 because the files were filtered out, and I started
> to read that as a tooling failure rather than as the answer. The real cost is in the working tree
> (a session reads `CLAUDE.md` at startup), not in clones. Checked before concluding.

> **Build note:** 2026-10-04 — `check-expert-review` refused this change in CI and it was **right**: a
> new script, a new canary and a changed generator is a structural change, and it had no plan doc. I had
> been treating it as a fix because the commit prefix said `feat`/`fix` and the work felt iterative.
> The gate asked for exactly the artifact this file is. Restored with `git checkout HEAD --` while
> mutation-testing, which also reverted the intended edits — visible immediately, but a reminder that
> the restore was scoped wider than the mutation.

## On ship

Move this folder into `governance/completed/`, rename the file to describe what shipped, add the entry
to `completed-features.md`, append the final line to the worklog, remove the item from `in-progress.md`,
and promote the durable lesson — *a generated mirror is an index, never a corpus* — into
`key-patterns.md` in the same commit as the ship.
