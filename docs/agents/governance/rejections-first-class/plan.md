# Plan: Rejections are first-class — the step-2 list is also the rejections ledger

- **Area:** `governance`  ·  **Started:** 2026-10-01  ·  **Status:** In progress
- **Owner:** the owner (asked whether to adopt a decision-retrieval tool; directed "draft/plan a solution and build it") / Hermes (building)
- **Next step:** run the local gate suite (`sync-agents.sh`, `check-docs.sh --since`, `check-expert-review.sh`,
  `check-algorithm.sh` + `.test.sh`, `check-plan-home.sh`, `panoply.test.sh`), then open exactly ONE PR on
  `feat/rejections-in-deletion-candidates` and squash-merge.
- **Roadmap initiative:** Rejections are first-class — a decision that was turned down survives where the next agent asks.

## Goal

After this ships, a decision that was **considered and turned down** is recorded in a place the next agent
actually reads — the plan doc's *Deletion candidates* section — carrying what the rejected thing was, why it
lost, and **what we do instead**. Someone about to re-propose a dead end finds the answer at the moment they
ask the question, instead of re-litigating it in a chat thread nobody can retrieve.

How we know it worked: a fresh reader finds the requirement in `.agents/rules/algorithm.md` step 2, the plan
template's table has a column that cannot be filled without naming the replacement, and the existing
`check-algorithm.sh` continues to pass a compliant plan without any change to its logic.

**Out of scope:** any embeddings/retrieval index, any new decisions store or directory, any change to
`check-algorithm.sh`'s matching, and any edit to the Phalanx repo (its `in-progress.d/` fragments already
carry the handoff line; rejections belong with the plan, and a second repo is a separate decision).

## Context

The question that started this: *are there better alternatives to `nicklecoder/requiem`, and should we adopt
one?* Requiem is a Go CLI holding a git-tracked corpus of statements with semantic search, deliberately
un-enforced ("labels are a shortcut, not an obligation"). Its one genuinely un-duplicated idea in the kit's
context is that **rejections are first-class** — `requiem reject --see-instead <id>` records an option that
lost and points at the decision that replaced it.

The kit has no equivalent: decisions that were turned down live in chat and PR threads — which is the exact
failure requiem's README names ("the rejection was a conversation and conversations evaporate"). The kit
*does* already require, per structural change, a **Deletion candidates** section in the plan doc, enforced by
`check-algorithm.sh`. A rejected approach and a deleted part are the same artifact — "we considered this and
are not doing it, because X" — so the section that already exists and is already gated is the ledger. This
change writes that down.

Constraint that shapes the design: the kit's premise is **POSIX sh, zero runtime deps, provider-neutral**
(`.agents/policy.md`, README). A retrieval index, an embedder endpoint, or a new gate would break it; widening
an artifact's *content* while leaving the checker alone does not.

## Architecture

- **Layers touched:** none in the Clean-Architecture sense — markdown rules + one template. No source code,
  no ports, no dependency-direction change.
- **New ports (interfaces):** none.
- **Boundary data:** none.
- **Dependency direction:** unchanged. No script, no runtime dependency, no new command.
- **Swap test:** n/a (no vendor code). The only generation contract touched is `sync-agents.sh`, which
  regenerates the `AGENTS.md` rules block from `.agents/rules/*.md`.

## The Algorithm pass

- **Question:** *who asked, and which constraint does it serve?* the owner, 2026-10-01, having surfaced
  `nicklecoder/requiem` and asked whether its approach belongs in these workflows. Constraint it serves: the
  kit's own stated gap — an idea already turned down must be retrievable at the moment someone proposes it
  again, or it gets re-proposed. Named requester, named constraint.
- **Delete:** the two things I recommended in the analysis — a new `.agents/rules/decisions.md` module and a
  new `check-rejections.sh` gate — are both **removed** below. The artifact I wanted to record already has a
  required, gated home, so inventing a second one was the mistake the pass exists to catch.
- **Simplify:** one rule-module bullet pair, one template column, one CHANGELOG line. Three files, no script.
  The least shape that satisfies "a rejection is findable where the next agent asks" is a sentence in a
  section that is already mandatory.
- **Accelerate:** the bottleneck is **retrieval at the moment of proposal**, not authoring — an agent already
  reads the plan doc of the area it is about to touch (read-order step 3–4 of the onboarding contract), so a
  row there is read at zero additional cost. Baseline that motivated it: today a rejection is recorded
  nowhere in a kit repo (zero artifacts), so every re-proposal costs a full re-derivation. No count is
  claimed for the *after* state: this is a doctrine change, and I have no corpus to measure a rate on — the
  number would be invented.
- **Automate:** **nothing.** Step 5 is deliberately empty here. The section and its heading are already
  checked by `check-algorithm.sh`; adding a column check would be automating a rule that has no evidence it
  cannot be followed by prose alone, and the rule says automate last. Widening prose costs one line and is
  reversible; a gate change is not.

### Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| Adopting `nicklecoder/requiem` (or a fork) as a vendored tool | **removed** | One author, 0 stars, no long-run evidence even by its own README; it would add a second decisions corpus, an embedder endpoint, a SQLite index, and git hooks beside `docs/agents/`, in a repo whose premise is POSIX sh with zero runtime deps. Cost is a permanent dependency; benefit is retrieval a required plan-doc row already approximates. |
| A new `.agents/rules/decisions.md` module for rejected approaches | **removed** | Recommended in the analysis, then deleted on running the pass: the artifact already has a required, gated home. A second module means a second read-order entry and a second place the same fact can be missing. |
| A new `check-rejections.sh` gate (+ canary) | **removed** | Same reason: there is no gap for it to close. It would also be step-5 automation of a brand-new convention with no runs behind it. |
| A new `docs/agents/decisions/` directory or ledger file | **removed** | The plan-home gate forbids a second plan-shaped home, and the point of the change is that the answer lives where the question is asked — the area's own plan doc. |
| A semantic index / embedding store for prior decisions | **removed** | The expensive half of requiem, with a measured caveat in its own README that nearest-neighbour search missed genuine conflicts that shared an identifier and no wording. Corpora per repo are small; the plan doc is the retrieval path. Cross-project duplication is a `gbrain` question, not this one. |
| Widening `check-algorithm.sh` to require the "What we do instead" column | **removed** | Its one-remedy-one-message property is load-bearing (`.agents/rules/algorithm.md` → "Automate last"; its canary asserts the remedy round trip). A column check adds a second refusal reason to one gate and buys judgment it cannot make anyway — whether the *instead* names something real stays a review question, now stated explicitly in the module. |
| Editing the `a pilot repo` repo to mirror this | **removed** | Phalanx `in-progress.d/` fragments already carry a `Next step` handoff and read the same plan-doc contract; a matching edit there is a second repo and a second PR for a change the Panoply kit already carries. Raised as an option, not done — the owner can ask for it. |
| The three-column candidate table | **kept** | Structured enough to be read at a glance, and the heading is already what the gate matches — restructuring it would invalidate every existing plan doc's section. |
| Rejections recorded in the plan doc rather than a dedicated store | **kept** | This is the change. The plan doc is read before work in its area; a separate store is a thing to remember to check. |

## Milestones

- [x] **M1 — Rule module**: `.agents/rules/algorithm.md` step 2 — rejections and deletions are one act; a
  rejection owes what it was, why it lost, and what we do instead; record it in the plan doc's list, never a
  second store. Step-2 row of the step table names rejected items; the applied-pass line 2 and the
  Enforcement honesty paragraph updated (the stale "an automation introduced in the change names the step it
  automates" bullet is removed — the gate never checked it).
- [x] **M2 — Template**: `docs/agents/_templates/plan.md` — the *Deletion candidates* section gains the
  "This list is also the rejections ledger" paragraph and the **What we do instead** column.
- [x] **M3 — Docs + declaration**: this plan doc, the `roadmap.md` initiative, the `in-progress.md` row, the
  `CHANGELOG.md` MINOR entry. Mirrors regenerated by `sync-agents.sh` (the `AGENTS.md` rules block is
  generated, never hand-edited).

## Exit criteria

- `.agents/rules/algorithm.md` step 2, the template, and the CHANGELOG all state the rejection requirement.
- `sh scripts/sync-agents.sh --check` green (the generated rules block matches the modules).
- `sh scripts/check-algorithm.sh --since <base>` green; `sh scripts/check-algorithm.test.sh` still 6/6 (the
  gate's behavior must be unchanged by this PR — that is the point).
- `sh scripts/check-docs.sh --since <base>`, `check-expert-review.sh --since <base>`, `check-plan-home.sh`,
  `sh scripts/panoply.test.sh` green locally and in PR CI.
- Exactly one PR open against `main`.

## Open questions

_None — the shape (extend the existing required section, change no gate, one repo) follows from the kit's own
premise and the Algorithm pass. The Phalanx mirror is explicitly out of scope, recorded above._

## Build notes

> **Build note:** 2026-10-01 — on running the pass, both components recommended in the preceding analysis (a
> `decisions.md` module, a `check-rejections.sh` gate) were deleted rather than built. The requirement was
> "a rejection must be findable where the next agent asks"; the kit already requires and gates exactly the
> artifact that satisfies it. Recorded because the recommendation is already in a chat thread — which is the
> failure mode this change exists to fix, so it belongs in this list rather than only there.

> **Build note:** 2026-10-01 — the Enforcement section's third bullet ("an automation introduced in the
> change names the step it automates") described a check `check-algorithm.sh` does not perform. It was
> removed rather than implemented: implementing it would be a new refusal reason on a gate whose single-remedy
> property is load-bearing, and no run has shown prose insufficient. Removing a false claim about the gate is
> cheaper than widening the gate to make the claim true.

## On ship

Move this folder to `governance/completed/`, add the `completed-features.md` entry, append the final worklog
line, remove the `in-progress.md` row, move the roadmap initiative to Shipped, and promote the durable lesson
(a rejection left in a chat thread leaves no artifact — record it in the list that already exists, and do not
build a second store for it) into `key-patterns.md` — all in the same commit as the ship.
