# Plan: <feature name>

- **Area:** `<area>`  ·  **Started:** YYYY-MM-DD  ·  **Status:** In progress
- **Owner:** <who is driving this>
- **Parent plan:** _(link if this is a sub-milestone; otherwise delete)_

## Goal

One paragraph. What is true after this ships that is not true now, stated in terms of what a user or
caller can do. Include how we will know it worked.

**Out of scope:** what this deliberately does not do. Naming this prevents scope creep mid-build.

## Context

What a fresh session needs to know to pick this up cold: the current behavior, the files and modules
involved, relevant decisions already made (link the ADR in `../../architecture.md`), and any
constraint that rules out the obvious approach.

## Milestones

Each milestone is independently reviewable and leaves the system working. Re-read this section at
the start of each one.

- [ ] **M1 — <name>** — <what changes, which files>
- [ ] **M2 — <name>** — <what changes, which files>
- [ ] **M3 — <name>** — tests, docs, and cleanup of anything the change orphaned

If a milestone splits into sub-milestones, nest them below their parent or create a sibling file in
this folder and link it here. **Do not overwrite this file** — the parent plan must stay readable as
a high-level overview.

## Open questions

Blocking decisions for the user, not for you to resolve unilaterally. Delete each one once answered,
recording the answer in Context.

- [ ] <question> — _blocks M2_

## Build notes

Record deviations and discoveries **at the moment you find them**, inline next to the milestone they
affect or appended here. Written later, they are written wrong.

> **Build note:** YYYY-MM-DD — what we expected, what was actually true, and what changed as a result.

## On ship

Move this whole folder into `<area>/completed/`, rename this file to describe what shipped, add an
entry to `../../completed-features.md`, remove the item from `../../in-progress.md`, and promote any
durable lesson into `architecture.md` or `key-patterns.md`.
