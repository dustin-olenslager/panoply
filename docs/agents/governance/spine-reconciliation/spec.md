# Spec: the spine tells the truth — the queue, the archive, and the two gates that lied

- **Area:** `governance`  ·  **Started:** 2026-10-10  ·  **Status:** Resolved
- **Owner:** the owner (asked for the reconcile, 2026-10-10) / Hermes (implementing)
- **Plan:** `plan.md` in this folder — written after this spec was resolved.

## Goal

An agent that reads the plan spine must be able to believe it. Today `in-progress.md` says seven
initiatives are in review with a pull request open; no pull request exists for any of them — every one of
those branches was squashed into `main` weeks ago. A queue that describes finished work as in flight
sends the next session to "merge" something that no longer exists, and hides the one thing that *is*
open. After this ships, a row means a row: what is left, with a next step someone can execute, and an
archive that records what actually landed.

The change that fixes it also has to survive the kit's own gates — and in doing so it exposed two of
them refusing legitimate work, which is the second thing this spec is about.

## User stories

### US-1 — a row that says "PR open" means a pull request is open (P1)

**Independent test:** `gh pr list --state open` against the rows of `in-progress.md` — every row that
claims an open branch must have one, and every merged branch must be folded.

- **Given** a queue row whose branch was squashed into `main`,
  **when** the queue is read,
  **then** the row is gone, its folder is under `<area>/completed/`, and `completed-features.md` carries
  its entry.

### US-2 — an archived plan is not read as a claim it never made (P2)

**Independent test:** move a plan written before the launch and wireframe rungs existed into
`<area>/completed/` and run the gates over the move: they must not refuse it for vocabulary alone.

- **Given** a plan whose docs milestone names the CHANGELOG's `[Unreleased]` heading,
  **when** `check-launch.sh` classifies it,
  **then** it is not treated as a claim that something went out.
- **Given** a spec that states its wireframe opt-out as "n/a — no user-facing surface",
  **when** `check-wireframe.sh` reads it,
  **then** the reasoned opt-out is honoured.

### US-3 — a false-positive class is a canary case (P2)

**Independent test:** revert the classifier to a bare substring match and the canary must go red.

- **Given** the fixed classifier,
  **when** the canary runs,
  **then** both directions are asserted: `[Unreleased]`/relationship must NOT fire, and an inflected
  claim with no launch record must still be refused.

## Edge cases

- A plan whose milestones **genuinely name the gate they built** (the launch gate's own plan): ticking
  them makes the rung demand a launch record from the plan that built the rung. The honest answer is to
  leave the boxes unticked and write down why, not to reword the milestone's subject away.
- A milestone whose evidence lives **outside this repo** (the `execution-algorithm` Hermes plugin): no
  in-repo path resolves, so the milestone cannot be ticked in this tree.
- A docs milestone that names the CHANGELOG heading `[Unreleased]`, which contains the letters
  `released` and is not a claim.
- A spec written before the wireframe rung, whose opt-out uses the words in the other order.
- A Shipped row needs a date; the merge date is not recorded anywhere in the plan doc.

## Requirements

- **FR-001**: MUST reconcile every queue row against the open pull requests and the merged history, by
  asking the remote rather than trusting the row.
- **FR-002**: MUST fold a finished initiative as one act: status and next step rewritten, folder moved to
  `<area>/completed/`, one `completed-features.md` entry, one `roadmap.md` Shipped row, queue row removed.
- **FR-003**: MUST tick a milestone only where the artifact is verifiable on `main`, and name a path that
  resolves in the milestone line.
- **FR-004**: MUST leave a milestone unticked, with the reason written into the plan, where ticking would
  misrepresent completion or trip a classifier the plan's own subject provokes.
- **FR-005**: MUST make `check-launch.sh`'s ship classifier require word boundaries, so `[Unreleased]` and
  "relationship" no longer read as claims.
- **FR-006**: MUST add canary cases for both directions of FR-005 — the false positive and the inflected
  true positive.
- **FR-007**: MUST state the wireframe opt-out in the form `check-wireframe.sh` reads, for any archived
  spec that carried it in another word order.
- **FR-009**: MUST exempt an archived artifact (`docs/agents/<area>/completed/**`) from the rungs
  that grade plans and specs — an archive move makes old files "changed" without making a new claim —
  and MUST carry a canary case per rung proving the exemption is behaviour, not accident.
- **FR-008**: MUST keep every spine gate green over the change: plan-home, docs currency, algorithm,
  milestone evidence, launch, wireframe, spec, coverage, comments, mirrors and the doctor.

## Key entities

Not applicable — the change carries no data model; the entities are markdown files and two shell
classifiers.

## Success criteria

- The open-PR list and `in-progress.md` agree: one live row, no dead branch names.
- `check-launch.sh` exits 0 over the archive move, and its canary is **14 passed, 0 failed** including
  the two new cases.
- `check-wireframe.sh` exits 0 over the moved specs.
- Every other spine gate exits 0 over the change, with all sixteen canary suites green and `shellcheck`
  clean.

## Assumptions

- The plan's last change on `main` is a fair date for a Shipped row. The merge date is not recorded in
  the plan itself, so the last commit touching it is the closest honest proxy, and the entry says so.

## Domain & outside experts

The domain is **developer tooling and agent governance** — a kit of POSIX shell gates and markdown
doctrine. No outside practitioner was consulted, and that is stated rather than filled with an invented
name. The input is the kit's own record: `git log`, the remote's open-PR list, and the gates' output.

## Wireframe

Wireframe: n/a — no user-facing surface. The deliverable is markdown spine files and two shell
classifiers; a person reads a terminal report, and there is no screen, flow or form to decide before
fitting anything to it.

## User interviews (simulated, 4 personas)

n/a — no user-facing surface, so no personas to interview. The consumers are the agents that read the
spine, and their requirements are the ones quoted in the kit's own documentation rules.

## Open questions

_(none — the direction was given by the owner, and both gate defects reproduce on the first run)_

## On resolve

Every requirement above is implemented in `plan.md`; the spec is archived beside it once the change lands.
