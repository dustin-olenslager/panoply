# Plan: Scope the expert-review gate to the change, not the tree

- **Area:** `governance`  ·  **Started:** 2026-10-03  ·  **Status:** In progress
- **Owner:** the owner (reported the defect, approved the scope) / Hermes (implementing)
- **Next step:** land this PR (`fix/expert-review-gate`), then move the folder into
  `governance/completed/` and add a `completed-features.md` row.
- **Roadmap initiative:** Mechanical enforcement of the governance rules — a green gate must mean the
  rule was followed, not that the rule's shape was ever seen.
- **Spec:** n/a — routine. This is a bug fix whose acceptance criterion is the gate's stated contract
  ("was THIS change reviewed"), not a new capability.

## Goal

After this ships, `sh scripts/check-expert-review.sh --since <base>` answers the question it claims to
answer: **was the change under test reviewed?** Today it answers a different question — *has this repo
ever contained a plan?* — and those coincide only before the repo's first plan lands.

How we know it worked: a repo holding a finished plan + checklist for feature A, followed by a large
structural change to feature B with no plan of its own, is REFUSED (canary case 4), and passes the
moment feature B's own plan is part of the change (canary case 5). Both directions are pinned, and
mutating either half of the old tree-global rule turns the canary red.

**Out of scope:** judging whether a plan is *good* (that is review, not automation); changing the
persona-signoff opt-in; the doctrine text in `.agents/rules/workflow.md` (another agent owns the docs
pass).

## Context

The gate's two required checks were TREE-GLOBAL:

- `find docs/agents -name plan.md -type f` — matched a plan for any feature, anywhere.
- `grep -rlE '^[[:space:]]*- \[[ xX]\]' docs/agents` — matched any checkbox, anywhere.

Once a repo held one finished plan, both were satisfied for every subsequent PR — so a 200-line
structural change with no plan and no review went green. The gate could not distinguish "this PR was
reviewed" from "this repo has ever contained a plan".

The kit already had the missing idea in two sibling gates: `check-spec.sh` and `check-algorithm.sh`
compute the changed files (`git diff --name-only --diff-filter=ACMR <base>...HEAD`) and scope their
evidence to that set. This gate was written before that convention and never adopted it.

## Architecture

- **Layers touched:** none — this is CI tooling, not application code.
- **New ports (interfaces):** none.
- **Boundary data:** none.
- **Dependency direction:** n/a.
- **Swap test:** n/a.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — who asked, and which constraint does it serve? The repo owner (the owner) reported the
  defect after reproducing it. It serves the kit's core promise: a green gate means the rule was
  followed. A gate that is green regardless is worse than no gate, because it launders an unreviewed
  change as a reviewed one.
- **Delete** — what can be removed instead? See the table below. The two tree-global checks ARE the
  defect, so deleting them is the fix, not a simplification of it.
- **Simplify** — the least shape that satisfies the requirement: one rule, *evidence must be a file
  the change touched*, implemented by reusing the `diff_files()` scaffold both sibling gates already
  use. No new concepts, no new config beyond what the house pattern has.
- **Accelerate** — the old gate ran `find docs/agents -name plan.md` plus a recursive `grep -rl` over
  the whole `docs/agents` tree; the new one runs a single `git diff --name-only`. Measured on the kit
  repo (110 plan/checklist files under `docs/agents`): tree-wide scan ≈ 14 ms vs scoped diff ≈ 3 ms.
  The bottleneck was never speed — it was correctness — so this is noted, not optimized for.
- **Automate** — nothing new is automated. The existing canary gains the adversarial cases; that is
  the whole automation footprint.

### Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| `find docs/agents -name plan.md` (tree-global plan check) | **yes** | This IS the defect: it matches a plan for any feature, so it cannot speak to this change. |
| `grep -rlE '^[[:space:]]*- \[[ xX]\]' docs/agents` (tree-global checklist grep) | **yes** | Same defect, second half: any checkbox anywhere satisfied it. Replaced by a grep of the evidence file. |
| `verify_review_evidence()` function + per-commit loop | **yes** | The per-commit loop verified the SAME tree-wide facts once per commit — N redundant scans producing one answer. The change-scoped facts are a property of the diff, so the check moved to a single post-loop evaluation. |
| `git show --stat | tail -1` line count | **yes** | It read a TOTAL row in some git versions and a filename in others — not a count at all. Replaced by `git diff --numstat` summed. |
| Requiring an UNCHECKED checklist item | **no** (already gone) | Deleted in a prior change; a finished plan is the definition of done. Do not resurrect. |
| Opt-in persona-signoff path | **no** | Orthogonal and explicitly retained; see Out of scope. |
| The whole gate (leave it as advisory) | **no** | The kit's doctrine is mechanical enforcement, and a soft advisory is exactly what let a 200-line change ship unreviewed. |

## Milestones

- [x] Reproduce the defect against a fixture repo (plan for A, big change to B → old gate green).
- [x] Scope evidence to `git diff --name-only <base>...HEAD`, reusing the `check-spec.sh` scaffold.
- [x] Scope the checklist grep to the touched plan file.
- [x] Extend `check-expert-review.test.sh` with the adversarial cases + positive controls.
- [x] Mutation-test both halves of the old rule; confirm the canary goes red under each.
- [x] Run the full gate suite, plain shellcheck, and `check-docs.sh --since`; open the PR.

## Build notes

- The canary's `mk_repo` had to commit the gate script itself before any base is taken, or the copied
  `scripts/check-expert-review.sh` appears as an added source file in every fixture and every change
  reads as structural. Found because case 8 (docs-only) failed for a reason that was not the gate.
- Mutation testing found a real gap: reverting ONLY the checklist half to tree-global left the canary
  fully green, because no fixture had an unrelated checklist present. Case 7b was added to close it,
  and now that mutation fails the canary. A canary that survives a mutation is the mutation's finding,
  not a pass.
