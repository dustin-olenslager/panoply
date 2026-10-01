# Plan: The Algorithm — question, delete, simplify, accelerate, automate

- **Area:** `governance`  ·  **Started:** 2026-10-01  ·  **Status:** In progress
- **Owner:** the owner (approved the scope) / Hermes (drafting)
- **Next step:** run the local gate suite (`sync-agents.sh --check`, `check-docs.sh --since <base>`,
  `check-expert-review.sh`, `check-algorithm.test.sh`, `panoply.test.sh`, `check-plan-home.sh`), open
  exactly ONE PR on `feat/execution-algorithm`, then land the Hermes-side plugin in the same batch.
- **Roadmap initiative:** The Algorithm — one question/delete/simplify/accelerate/automate pass for
  every effort, code and non-code.

## Goal

After this ships, every agent working in any repo that adopts this kit — and every Hermes agent and
subagent, including outside any repo — runs one ordered five-step pass on anything structural:

1. **Question** every requirement, and make it come with a **name** (who asked, which constraint it serves).
2. **Delete** any part or process it can — with a written **deletion candidate list**, because deletion
   is the only step whose output is absence and therefore the only one that silently gets skipped.
3. **Simplify** the least shape that satisfies the named requirement — never before deleting.
4. **Accelerate** cycle time with a **measured number** and an identified bottleneck — never before 1–3.
5. **Automate** last, and only what survived 1–4.

How we know it worked: a fresh reader can find all five steps in the rule module; the mechanical gate
refuses a structural change whose plan carries no step-2 artifact and allows it once the remedy is
applied (proven by canary, both directions); and a Hermes subagent with no repo context still receives
the pass.

**Out of scope:** changing Panoply's existing chapter structure or re-litigating the locked dev-workflow
policy; auto-deleting anything (step 2 is surfaced as a candidate list, never executed by a machine);
rebuilding any existing skill or gate.

## Context

- The system already covered three of the five steps well and the other two almost not at all.
  Question ↔ `first-principles` + the `quality-bar` self-check + plan-first. Simplify ↔ `simplify-code`,
  `maintain-mode`. Automate ↔ 37 scheduled jobs, 3 plugins, and the kit's gates. **Delete had no
  process anywhere** — nothing systematically removes, so cost accumulates unpriced — and **Accelerate
  had no measured number outside repos**.
- The framing and its ordering come from Elon Musk's "algorithm" as quoted in Isaacson's *Elon Musk*
  (summarized by Jeff Haden, Inc., 2023-09-27): question each requirement and make it come with a name
  ("requirements from smart people are the most dangerous"); delete any part or process you can ("the
  most common error is deleting too little"); simplify and optimize only after deleting; accelerate
  cycle time only after the first three; automate last, because automating a step you should have
  deleted multiplies the waste.
- Constraint that shapes the design: in Hermes, `skills.auto_load` never reaches a `delegate_task`
  subagent, `AGENTS.md` is cwd-only and truncated at 20,000 chars, and `SOUL.md` is deliberately skipped
  for children. So the pass cannot be delivered by a doc alone — it needs an injection channel. That is
  the same ladder the `hermes-policy-enforcement` doctrine measured, and it is why the Hermes side is a
  plugin rather than a memory line or a skill.

## Architecture

- **Layers touched:** none in the Clean-Architecture sense for the kit half — it is shell scripts plus
  markdown, with no source code, ports, or dependency-direction changes. The Hermes half is a plugin:
  a Frameworks & Drivers adapter at the host boundary; it holds no business rule and implements no port.
- **New ports (interfaces):** none.
- **Boundary data:** none crossing a domain boundary. The plugin renders a constant string into the
  host's prompt channels.
- **Dependency direction:** unchanged — the kit's scripts stay POSIX sh with no runtime deps; the plugin
  imports only host-provided contracts (`ctx.register_hook`, `ctx.register_system_prompt_section`).
- **Swap test:** n/a (no vendor code). The only mechanism touched is the kit's own generated-mirror
  contract, via `sync-agents.sh` (write + `--check`).

## The Algorithm pass

- **Question:** *Who asked for this, and which constraint does it serve?* Requested by the owner
  (2026-10-01): our coding governance covers panoply/phalanx, and he wants the same discipline applied
  to **all** efforts, not just coding. Constraint served: rules currently live where they can be read
  but not where they *bind*, so a rule that is not enforced drifts.
- **Delete:** see the candidate list below — the pass found real weight to remove, which is the point.
- **Simplify:** no new competing system. The pass lives in the existing rule-module + mirror machinery
  (one new module, one new gate) and reuses the existing Hermes enforcement ladder instead of inventing
  a second one.
- **Accelerate:** the bottleneck is **discovery**, not action — an agent cannot skip a step it can see
  in its prompt, and today the non-code steps are not in anyone's prompt at all. Measured baseline for
  the non-code loop: 37 scheduled jobs, no artifact check on any of them; after this change the weekly
  cadence report surfaces artifacts-per-job weekly (a number, not a claim).
- **Automate:** last, and only the checkable half — the gate checks that the step-2 artifact *exists*,
  never that it is good. Deliberately not automated: judging whether a deletion list is honest, whether
  a requester is real, or whether a measured number is true. Those stay review questions.

### Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| A new top-level "algorithm" doc in `docs/` | **removed** | The plan-home rule forbids stray plan-shaped docs; this is a rule module, not a fourth plan home. |
| New `MODULE:` markers and a pruned-by-default block | **removed** | The pass applies universally; a prunable block would let a repo opt out of the step that exists to prevent silent skipping. |
| Rebuilding the enforcement ladder (a second hook/Gatewright plugin) | **removed** | `hermes-policy-enforcement` already measured it; reuse, do not re-derive. |
| A new cron watcher for the cadence report | **removed** | It rides the existing weekly digest — a new watcher would be step-5 automation of an unexamined process. |
| `check-plan-home.sh`'s location-only stance | **kept** | Widening it to check plan *content* would make it the algorithm gate; the separator stays clean. |
| `check-expert-review.sh` extended to ask the algorithm's judgment questions | **kept** | Existing gate, existing purpose — overloading it makes its failure message ambiguous. The judgment questions are documentation in the rule + the Hermes plugin, not a second pass in that script. |

## Milestones

- [x] **M1 — Kit rule module + wiring**: `.claude/rules/algorithm.md` (the five steps, per-step
  artifacts, scope test, honest enforcement section); `workflow.md` pre-flight gains the pass;
  `quality-bar.md` gains the prior question ("should this exist at all?"); `AGENTS.md` preamble +
  read-order + index; `_templates/plan.md` gains the Algorithm pass + **Deletion candidates** sections.
- [x] **M2 — Mechanical half**: `scripts/check-algorithm.sh` (git / `--since` / `--staged`, docs-only
  exemption, escape hatch) + `scripts/check-algorithm.test.sh` (6-case canary: fail-without-section,
  positive control, exemption, escape hatch, no-plan, deny→remedy→allow round trip);
  `scripts/sync-agents.sh` ORDER gains `algorithm`; `panoply.sh` installs the two new scripts and its
  checklist names the CI/pre-commit wiring; `verify.yml` runs the gate and its self-test.
- [x] **M3 — Mirrors + docs spine**: all 5 concatenated mirrors + 3 edited Cursor `.mdc` + the AGENTS.md
  rules block regenerated (never hand-edited); this plan doc, roadmap row, queue row, CHANGELOG entry.
- [ ] **M4 — Hermes injection plugin** (`execution-algorithm`): the pass in the system prompt AND on the
  `pre_llm_call` context channel (the only channel that reaches subagents), plus the opt-in
  `pre_tool_call` gate for kit-governed repos. Enabled for kit-governed repos from the start, per the
  owner's decision. Shipped with a canary and a `hermes plugins doctor` proof.
- [ ] **M5 — Non-code cadence report**: weekly artifact/demand numbers for recurring jobs, riding the
  existing digest; output is a deletion candidate list, never an automatic removal.

## Exit criteria

- All five steps and their artifacts findable in `.claude/rules/algorithm.md` by a fresh reader.
- `sh scripts/sync-agents.sh --check` green; `sh scripts/check-algorithm.test.sh` green (6/6);
  `sh scripts/panoply.test.sh`, `check-plan-home.sh`, `check-docs.sh --since`, `check-expert-review.sh`
  green locally and in PR CI.
- Exactly one PR open against `main`.
- Hermes: `hermes plugins doctor execution-algorithm --ci` reports the expected hooks, and a live
  subagent run shows the pass in a child's context.

## Open questions

_None — scope and the gate's default (on for kit-governed repos) were decided by the owner, 2026-10-01._

## Build notes

> **Build note:** 2026-10-01 — the canary's fourth case (escape hatch) failed on first run because the
> hatch check ran inside a subshell whose `||` swallowed the exit status; restructured so each case's
> status is captured explicitly. A gate whose own canary passes for the wrong reason is the failure mode
> this suite exists to prevent.

> **Build note:** 2026-10-01 — the gate deliberately checks only that the step-2 artifact *exists*. It
> cannot judge a deletion list's quality, and saying so in the script header is cheaper than a later
> reader trusting a green check for more than it proves.

## On ship

Move this folder to `governance/completed/`, add the `completed-features.md` entry, append the final
worklog line, remove the `in-progress.md` row, move the roadmap initiative, and promote the durable
lesson (deletion leaves no artifact, so the artifact must be required) into `key-patterns.md` — all in
the same commit as the ship.
