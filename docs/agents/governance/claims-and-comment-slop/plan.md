# Plan: claims are evidence, and comments are not decoration

- **Area:** `governance`  ·  **Started:** 2026-10-10  ·  **Status:** In progress
- **Owner:** Hermes (SME-drafted), the owner (approving)
- **Next step:** run the landing suite on this branch (`sh scripts/check-comments.test.sh`, then every `check-*.sh --since $(git rev-parse origin/main)`), squash-merge, move this folder to `governance/completed/`, add the `completed-features.md` row, delete the `in-progress.md` row.
- **Roadmap initiative:** Claims and comment slop — the two gaps worth taking from the public `anti-slop` rulebook
- **Spec:** `spec.md` in this folder — the what and why this plan implements.
- **Domain & experts:** developer tooling; no outside expert consulted, stated rather than fabricated. The published `anti-slop` rulebook (MIT) is the outside input, read in full and cited in the spec's Domain table — its comment skill names the same four shapes, and it ships no mechanical gate, which is why only the comment half is gated here.
- **Parent plan:** none.

## Goal

Two rungs land, one gated and one not, and each is honest about which it is. A change that adds a
banner, an emoji comment, a narration comment, an end marker, or an empty label is refused by
`scripts/check-comments.sh` with the file and line named, and `.agents/rules/code-style.md` says what a
comment is for. A claim a reader sees — an invented statistic, a fake terminal window, a capability the
product does not ship — is forbidden by the new `.agents/rules/claims.md`, with the module stating
plainly that no gate can detect it and naming the review step that asks instead.

We will know it worked when the canary is green in both directions (and red under eight independent
mutations of the gate), when this repo's own CI step passes on the very PR that adds the gate, and when
the rule index lists `claims` in every generated mirror.

**Out of scope:** importing the upstream rulebook's five skill folders, its 38 rules, its installer, or
its per-tool pointer blocks; any gate for the claims half (no script can detect an invented number —
see FR-002); retrofitting this repo's own 177 pre-existing banner comments (measured, recorded below,
deliberately not part of this change); any UI or aesthetic doctrine, which the design-system module and
the design tokens already own.

## Context

The owner asked whether the public `anti-slop` rulebook (`github.com/miqdadbadjuber/anti-slop`, MIT) was
worth integrating into this kit. Read in full — core plus five skills, ~3,300 lines — and compared
module by module against what Panoply already enforces. Most of it is already here: the accessibility
floor and the loading/empty/error trio live in `frontend.md`, the design axes and component conventions
in `design-system.md`, the no-fabrication prohibition in `spec.md` and `wireframe-first.md`. Two things
genuinely were not, and they are what this change adds.

The upstream project is explicit that it is a **filter, not a style guide**, and that it ships no
mechanical gate — everything is prose plus a self-reported PASS/FAIL. That matters because this kit's
own thesis is that a rule with no gate is the rung that never gets used, and that a gate must never
claim more than it checks. So the shape here is: gate the half that is mechanically observable
(comments), and state the honest limit on the half that is not (claims).

Relevant existing machinery this plan must fit:

- `scripts/check-spec.sh`, `check-algorithm.sh`, `check-coverage.sh`, `check-expert-review.sh` all
  classify `scripts/**` as structural, so this change carries a spec and a plan — which it does.
- `scripts/sync-agents.sh` renders the `AGENTS.md` rules index from `.agents/rules/*.md` and generates
  every tool mirror; a new module must be added to its `ORDER` list or it lands outside the read order.
- Every gate in this kit ships a mutation-tested canary and is wired into both `.github/workflows/verify.yml`
  and the shipped adopter template `scripts/templates/ci-verify.yml`.

## Architecture

- **Layers touched:** none of Clean Architecture's four — this repo ships shell gates and markdown
  doctrine, not an application. The relevant boundary is the kit's own: doctrine (`.agents/rules/*.md`),
  the mechanical gate (`scripts/check-comments.sh`), the canary that proves it, and the CI wiring.
- **New ports (interfaces):** none.
- **Boundary data:** none. The gate reads a git diff and a source file; it emits text on stdout/stderr
  and an exit code.
- **Dependency direction:** no new dependency, in any direction. POSIX sh plus `awk`, matching every
  other gate in the kit — an extra runtime would make the gate unusable in another adopter's CI.
- **Swap test:** not applicable; nothing vendor-shaped is touched.

## The Algorithm pass (question · delete · simplify · accelerate · automate)

- **Question** — the owner asked whether the upstream rulebook was worth integrating; the constraint it
  serves is the two real gaps found by reading both artifacts side by side. Recorded in the spec's
  Domain table with the source that shaped each requirement.
- **Delete** — most of the upstream artifact, and one half of the new machinery. Candidates below; the
  deletion list is longer than the build list, which is the point.
- **Simplify** — one new module (claims), one section inside an existing module (comments belong to
  `code-style.md`, not a new file), one gate, one canary. No new directory, no new artifact type, no
  installer, and **no second gate for the claims rule** — a rule that needs a fresh gate is usually in
  the wrong place, and this one cannot be gated at all.
- **Accelerate** — the gate reads the changed files in one `git diff -U0` pass per file and one `awk`
  pass over each, rather than reading whole trees: the measured cost of the whole-tree audit mode is the
  slow path (`--tree` over 177 findings in this repo), and CI runs the change-scoped diff instead. The
  bottleneck was never speed here; it is that nothing read comments at all.
- **Automate** — last, and only the observable half. The claims rule stays a review question on purpose:
  automating it would mean shipping a gate that passes while a claim went unexamined, which reads as
  coverage and is worse than no gate.

### Deletion candidates

| Candidate | Removed? | Why | What we do instead |
|---|---|---|---|
| Importing the upstream rulebook wholesale (5 skill folders, 38 rules, installer, pointer blocks) | rejected | ~90% overlaps this kit; it would add a second mirror mechanism fighting `sync-agents.sh`, 38 advisory rules nothing checks, and the upstream premise ("filter, not direction") is already the kit's design-system doctrine | Extract the two genuine gaps; record the comparison here so the same proposal is not re-argued monthly |
| The upstream copywriting skill (372 lines: headlines, CTAs, tone, an em-dash ban) | rejected | Duplicates the owner's established voice rules and the `humanizer` skill, and bans a punctuation mark the kit itself uses in prose | No new copy module; voice stays where it already lives |
| The upstream accessibility skill (`antislop-human`) | rejected | `frontend.md` already requires the keyboard, focus, contrast, and reduced-motion floor, and `design-system.md` requires the empty/loading/error trio | Nothing; the existing modules stand |
| The upstream mobile/reflow skill | rejected | A near-empty skill against a kit that has no layout doctrine to extend, and no mobile surface in this repo | Nothing |
| The upstream Delivery Gate (a mandatory self-reported PASS/FAIL block) | rejected | A self-report is not evidence: it cannot go red, and `check-expert-review.sh` plus the launch gate already occupy that rung with something checkable | The comment gate, which fails on its own |
| A gate for the claims rule | rejected | No script can tell a real statistic from a plausible invented one without already knowing the truth; a gate here would pass while the claim went unexamined | Doctrine plus the review question, stated in the module and in FR-002 |
| A NEW rule module for comment style | rejected | Comments are a code-style concern, and a new module means a new read-order entry, a new index line, and a new mirror for one section | A Comments section inside the existing `code-style.md` |
| Retrofitting the 177 pre-existing banner comments in this repo's own `scripts/**` | rejected for now | A rule adopted later must not demand evidence for debt that predates it: grading the tree would red every PR for history and teach people to avoid touching those files | The gate grades only added lines; `--tree` measures the debt (177 findings, all banner-class, recorded in the CHANGELOG entry and in Build notes) |
| An emoji class keyed on "any non-ASCII byte" | rejected | Would flag a curly apostrophe, an em dash and a non-English name — an ASCII-only lint by accident | Byte-prefix matching over the actual emoji blocks, asserted in the canary with a typography case |
| The whole request ("there is no value here") | rejected | Two gaps were found by reading both artifacts; the owner chose to take them | This change, one gated rung and one doctrine rung |

## Spec coverage

| Requirement | Milestone |
|---|---|
| FR-001 | M1 |
| FR-002 | M1 |
| FR-003 | M2 |
| FR-004 | M3 |
| FR-005 | M3 |
| FR-006 | M3 |
| FR-007 | M3 |
| FR-008 | M3 |
| FR-009 | M2, M3 |
| FR-010 | M4 |
| FR-011 | M1 |
| FR-012 | M5 |

## Milestones

- [ ] **M1 — the claims module** — add `.agents/rules/claims.md` (claims are evidence, with the honest limit stated), list it in `sync-agents.sh`'s `ORDER`, refill the index, and add a row to the `AGENTS.md` routing table (FR-001, FR-002, FR-011)
- [ ] **M2 — the Comments doctrine** — add the Comments section to `.agents/rules/code-style.md`, naming the banned shapes, what to keep instead, the gate, and `COMMENTS_OFF=1` (FR-003, FR-009)
- [ ] **M3 — the comment gate and its canary** — add `scripts/check-comments.sh` (change-scoped by default, `--since`, `--staged`, `--tree`, docs and self excluded, counts and a distinct zero message, exit 2 on an unresolvable base) and `scripts/check-comments.test.sh` (34 assertions, both directions, mutation-tested) (FR-004 to FR-009)
- [ ] **M4 — CI wiring** — add one step to `.github/workflows/verify.yml` and the same step to `scripts/templates/ci-verify.yml`, plus the canary in both self-tests jobs (FR-010)
- [ ] **M5 — docs and the adopter note** — this spec and plan, the `roadmap.md` row, the `in-progress.md` row, the CHANGELOG `[Unreleased]` entry naming the MINOR class and the adopter impact, and the ship-time move to `governance/completed/` with a `completed-features.md` row (FR-012)

## Open questions

None. The one decision this plan needed — extract the two gaps rather than import the rulebook — was
made by the owner before M1 and is recorded in the deletion candidates above.

## Build notes

> **Build note:** 2026-10-10 — measured before deciding: `--tree` over this repo's own tracked tree
> reports **177 findings**, every one a punctuation banner in `scripts/**`, plus 2 all-caps notes. That
> number is the evidence for change-scoped grading, not a preference: a tree-wide gate would have been
> red on the PR that introduced it, and red on every PR after.

> **Build note:** 2026-10-10 — the first draft of the narration pattern also matched a bare numbered
> list (`1. agent card — …`), which flagged seven legitimate lines in `scripts/check-agent-readiness.sh`.
> Narrowed to the `Step N` and ordinal-word forms; the false-positive class is now recorded in the
> module as a stated limit rather than fixed by widening an exemption.

> **Build note:** 2026-10-10 — the canary is mutation-tested, eight mutations of the gate's own
> detection paths (separator case, emoji prefix list, narration regex, base-resolution guard, the
> nothing-compared path, `SELF_EXCLUDE`, the docs exemption, the note bucket): each turned the suite
> red, and restoring the source returned it green. The mutations were applied by string replacement
> with an assertion that the pattern was found exactly once, so a no-op mutation could not be read as
> a surviving hole.

## On ship

Move this folder into `governance/completed/`, rename the plan file to describe what shipped, add an
entry to `../../completed-features.md`, append the final line to the `CHANGELOG` `[Unreleased]` section,
remove the item from `../../in-progress.md`, move the initiative in `../../roadmap.md` to Shipped, and
promote any durable lesson into `architecture.md` or `key-patterns.md` — all in the same commit as the
ship.
