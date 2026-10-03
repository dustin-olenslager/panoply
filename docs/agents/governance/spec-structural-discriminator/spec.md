# Spec: spec gate — the structural discriminator

- **Area:** `governance`  ·  **Started:** 2026-10-03  ·  **Status:** Resolved
- **Owner:** the owner
- **Plan:** `plan.md` in this folder — written only AFTER every `[NEEDS CLARIFICATION: …]` below is
  resolved. _(The spec says what and why; the plan says how.)_

## Goal

A maintainer can wire a gate into CI without being asked for a product spec, while a change to
application code is still refused until a spec exists. The gate distinguishes **wiring** — the
configuration that decides *when* checks run — from **system** — the code that decides *what the
product does* — and it does so without a list of file suffixes standing in for that judgement.

The user-visible outcome: a repo adopting the kit can point a new CI step at a gate and merge it in
one change, instead of the gate blocking the very wiring that makes it run.

## User stories

### US-1 — Adding a CI step does not demand a spec (P1)

A maintainer adds a step to `.github/workflows/verify.yml` that runs an existing kit gate. They commit
and open a PR. The gate passes, because they changed when checks run, not what the product does.

- **Why this priority:** without it the gate is self-defeating — it refuses the change that turns it
  on, and the workaround (exempting the whole repo, or `SPEC_OFF=1`) removes the gate entirely.
- **Independent test:** stage a change that touches only `.github/workflows/verify.yml`; the gate
  reports `OK (docs-only / no structural change)`.
- **Acceptance scenarios:**
  1. **Given** a repo with the kit applied and a clean main, **when** a commit adds
     `.github/workflows/verify.yml`, **then** `check-spec.sh --since <base>` exits 0 and names the
     change as non-structural.
  2. **Given** the same repo, **when** a commit adds `.pre-commit` or a `tsconfig.json`,
     **then** the gate likewise exits 0.

### US-2 — Real code is still refused (P1)

A maintainer changes application code with no spec. The gate refuses, exactly as before — the new
exemption must not become a hole.

- **Why this priority:** an exemption that exempts too much is worse than no exemption at all: it
  silently permits unspecified application code while reporting a clean run. This is the story that
  makes US-1 safe to ship.
- **Independent test:** stage a change to `src/*.ts` with no `spec.md`; the gate exits 1 and reports
  `has no spec`.
- **Acceptance scenarios:**
  1. **Given** a repo with the kit applied, **when** a commit adds `src/g.ts` and no spec, **then**
     the gate exits 1 naming the missing spec.
  2. **Given** the same commit plus a compliant `docs/agents/<area>/<slug>/spec.md`, **when** the gate
     runs over the same range, **then** it exits 0.

### US-3 — The judgement is auditable, not a suffix rule (P2)

A reviewer can see *why* a path was treated as wiring, in a named pattern they can read and change,
rather than inferring it from a negative lookahead buried in a suffix regex.

- **Why this priority:** the original defect was a suffix rule (`.yml`) silently standing in for a
  judgement about meaning. Leaving the fix as another opaque regex would repeat the mistake one level
  down.
- **Independent test:** a single `CONFIG_RE` constant exists, is consulted before `CODE_RE`, and is
  named in the refusal message's own doctrine.
- **Acceptance scenarios:**
  1. **Given** the gate source, **when** a reader opens the structural test, **then** the wiring
     exemption is a separate named constant with a comment stating what it excludes and why.
  2. **Given** the canary, **when** it runs, **then** both the exempt case and its negative control
     are asserted, so a future widening of the exemption fails the suite.

## Requirements

- **FR-001**: The gate MUST treat `.github/**`, `.agents/**`, `.pre-commit`, and tool configs
  (`tsconfig*.json`, `eslint.config.*`, `vite.config.*`, `playwright.config.*`, `jest.config.*`,
  `vitest.config.*`, `docker-compose*`) as non-structural.
- **FR-002**: The gate MUST continue to treat `src/`, `lib/`, `apps/`, `packages/`, `scripts/`,
  `e2e/`, `infra/`, `migrations/` and code suffixes as structural.
- **FR-003**: The wiring exemption MUST be consulted before the suffix rule.
- **FR-004**: The canary MUST assert both directions — that a workflow edit passes AND that a `src/`
  change is refused — so that widening the exemption cannot pass the suite.
- **FR-005**: The exemption MUST be a named constant distinct from `CODE_RE`, so the judgement is
  auditable and editable without altering the suffix rule.

## Success criteria

- `check-spec.test.sh`: 16/16 green, including the two new cases.
- Mutating the exemption to match everything (`CONFIG_RE='.*'`) MUST turn the canary red.
- Mutating structural detection off MUST turn the canary red.
- `shellcheck -S warning` clean on both scripts.
