# Spec before Plan

> **Applies when:** any **structural** change — a new feature, a new requirement, a change to observable
> behavior, or anything whose wrong shape would be expensive to undo. Runs after the Algorithm pass
> (`.agents/rules/algorithm.md`) and before `plan.md` is written.
> **Delete this file (and its `@` import in the generated agent hub) if:** never. If the project keeps
> requirements somewhere else, retarget this module at that place rather than dropping the rung.

## Why this rung exists

The kit has a strong **plan** rung and had no **spec** rung. A plan answers *how*: layers, ports,
milestones, dependencies. Nothing in the chain asked *what a user can do after this ships* and *how we
will know it worked*, in a form anything checks. So requirements survived only as prose inside a plan's
`## Goal`, where they are neither prioritized, nor testable, nor enumerable — and an ambiguity lived
comfortably all the way into implementation, where it silently became a guess nobody reviewed.

A spec is small on purpose. It is the cheapest possible place to discover that a requirement is
undefined, and the only place where "we have not decided this yet" is legal.

## Where a spec lives

`docs/agents/<area>/<feature>/spec.md` — a **sibling of the plan it belongs to**, in the same folder.

Not a `specs/` tree, and not a second plan home: `check-plan-home.sh` permits exactly
`docs/agents/<area>/<feature>/plan.md`, and both it and `check-algorithm.sh` glob `docs/agents/*/*/`.
A spec beside its plan needs no new allowance in either, and cannot become a competing plan doc.
Copy the shape from `docs/agents/_templates/spec.md`.

One feature has one spec and one plan, in one folder, linked from one `roadmap.md` row.

**Wiring is exempt.** CI workflows (`.github/`), the pre-commit hook, tsconfig/eslint/vite/jest config,
docker-compose, and `.agents/` are treated as **non-structural** by the gate: a change that alters
*when a gate runs* is not a change to what a user can do, so it needs no spec — the same reason a typo
fix does not. The exemption lives in `check-spec.sh`'s `CONFIG_RE` so it is auditable rather than buried
in the code rule.

**The lightweight plan home has no spec sibling.** A project too small for the `docs/agents/` spine may
keep one `docs/PLAN.md` (`workflow.md` → Planning Workflow), and `check-algorithm.sh` /
`check-expert-review.sh` accept it — but `check-spec.sh` searches only `docs/agents/*/*/spec.md`, so a
`docs/PLAN.md` repo has no path the spec gate recognises. If such a repo adopts this rung, either grow
the spine or set `SPEC_GLOB` to the sibling it does keep.

## What a spec owes

1. **User stories, prioritized (P1, P2, …), each independently testable.** Implementing P1 alone must
   leave a viable increment. If a story can only be tested once the others exist, it is not a story —
   split it, or state the one check that proves it alone.
2. **Acceptance scenarios per story, in Given / When / Then form.** These are what a test is later
   written from, so they must be concrete enough to be one.
3. **Numbered functional requirements**, each `MUST`-phrased and testable, stating behavior and never
   implementation.
4. **Measurable success criteria**, technology-agnostic. A number, not an adjective.
5. **Assumptions**, named explicitly, so a reviewer can challenge a default nobody stated.

## The marker rule — the one hard part

A requirement whose answer is unknown is written with a marker, never with an invented answer:

    - **FR-005**: The system MUST retain records for [NEEDS CLARIFICATION: how long, and who decides?]

`[NEEDS CLARIFICATION: <question>]` is **legal anywhere in a draft spec and nowhere else**. It is a
debt with two legal settlements: **answer it**, or **delete the requirement**. Never resolve one by
choosing a plausible value — that is the fabrication this kit forbids everywhere else, wearing a
spec-shaped costume.

**An unresolved marker must not survive into a plan.** The plan is where implementation begins, and an
ambiguity that reaches it has already become a guess. This is what `scripts/check-spec.sh` enforces,
which is why it is a gate rather than advice: an advisory "please clarify first" is exactly the rule
that drifts, and the whole reason this kit exists is that unchecked rules drift.

## The pass, in order

1. **Algorithm first** (`.agents/rules/algorithm.md`). Question each requirement and name its
   requester; delete what can be deleted; the spec then describes the *surviving* requirement. Writing a
   spec for something step 2 would have deleted is wasted ceremony.
2. **Write the spec** from `docs/agents/_templates/spec.md`. Stories and acceptance scenarios first —
   they expose gaps that a requirements list hides.
3. **Resolve every marker.** Answer it, or delete the requirement. Ask the owner when the answer is
   genuinely theirs (see `.agents/rules/quality-bar.md` → two options plus a recommendation).
4. **Then the plan.** `plan.md` in the same folder, linked from the roadmap row, with its `Spec:` field
   pointing at this file — in the same change.

## What counts as routine (no spec needed)

Proceed directly, and say what you did, when the change is:

- A typo, comment, or string fix with no behavioral effect.
- A one-line change the owner explicitly described and asked for.
- Formatting, import ordering, or lint autofixes.
- A bug fix inside an existing pattern, where the acceptance criterion is the existing behavior.
- A refactor that changes no observable behavior — the existing tests already state the contract.

Everything else is structural. A change that alters what a caller can observe needs a stated criterion
for the new behavior, and the cheap moment to write it is before the code exists. **When in doubt, treat
it as structural** — the ceremony is one small file, and a wrong shape that reaches code is far more
expensive than a spec written in five minutes.

## Honest limits — read before trusting a green gate

`scripts/check-spec.sh` checks **presence and resolution**, and nothing more. It can tell that a spec
exists for a structural change and that no `[NEEDS CLARIFICATION: …]` survives in it. It **cannot** tell
whether:

- the stories are genuinely independently testable,
- the acceptance scenarios are concrete enough to be tests,
- the success criteria are measurable, or
- the requirements are worth what they cost.

Those stay review questions and belong in the plan doc's review — the `check-expert-review.sh` gate and
an SME read. **A gate that passes while a requirement went unexamined is a gate measuring the wrong
thing**, and this one says so in its own source, the same way `check-algorithm.sh` does.

## Enforcement — the honest version

Consistent with the kit everywhere else: prose is a suggestion, and the binding plane is required CI.

- **The rule is here.** This module is inlined into every tool-native mirror by `sync-agents.sh`, so
  every agent in every tool reads it.
- **The gate is `scripts/check-spec.sh`**, wired into `scripts/templates/ci-verify.yml` for the PR
  context and `scripts/templates/pre-commit` for the local one. It fires on a structural change with no
  spec, and on a spec carrying an unresolved marker, and it refuses in a message that names the remedy.
- **A gate must observe its own remedy.** The spec IS the remedy, so the gate exempts `docs/**` and
  `*.md` and can never block the write that satisfies it; the canary
  (`scripts/check-spec.test.sh`) asserts the refuse → apply the remedy → allow round trip closes.
- **`SPEC_OFF=1`** is the stated escape hatch for a deliberate exception. Say plainly that you used it,
  so the choice is reviewed rather than assumed.
- **The honest floor:** a client-side hook is convenience, never enforcement — any agent can bypass it
  with `git commit --no-verify`. Only a required CI status check actually holds.
