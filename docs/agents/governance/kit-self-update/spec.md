# Spec: Make the kit updateable — a stale doctor that admits it, a truthful apply, and a recoverable refresh

- **Area:** `governance`  ·  **Started:** 2026-10-03  ·  **Status:** Resolved
- **Owner:** the owner (owner-verified problem statement) / Hermes (drafting)
- **Plan:** `plan.md` in this folder — written only after every `[NEEDS CLARIFICATION: …]` below is resolved.

## Goal

An adopted repository must be able to pull in kit fixes **deliberately and observably**. Today a repo
that adopted the kit keeps its own frozen copy of the kit's scripts and rule modules, and there is no
supported way to bring it forward. Worse, the copy it does run gives a false bill of health: it reports
`OK — kit applied and current` on a repo the current kit calls half-applied, and re-running it silently
re-writes the version stamp even when it changed nothing. After this ships, a person or agent can ask a
kit copy whether *it* is the stale party, get a truthful per-file answer about what differs from the
kit, and refresh an adopted copy through a path that never destroys local work without leaving a
recoverable backup.

## User stories

### US-1 — A stale doctor stops reporting a clean bill of health (P1)

A maintainer in an old-layout adopter runs the repository's own `scripts/panoply.sh check`. Today it
prints `OK — kit v1.4.0 applied and current` and exits 0, while the current kit calls the same repo
half-applied. The maintainer gets opposite answers from the same repo depending only on which copy ran.
After this story, the old copy detects that its own embedded expectation disagrees with the kit it can
reach, and reports that *it* is stale (a distinct non-zero state) with a message naming the fix, rather
than reporting OK.

- **Why this priority:** the false green is the whole reason the kit is unsafe to adopt. A gate that
  says OK on a repo the kit rejects is worse than no gate — it is trusted, and it is wrong. Everything
  else here is recovery from that; this is the detection.
- **Independent test:** in an adopter fixture whose copy expects the old layout, seed a reachable kit
  source whose doctor expects the new layout; assert the adopter's own `check` exits with the
  self-stale code and does NOT print `OK`, and that a compliant copy on the matching kit still exits 0.
- **Acceptance scenarios:**
  1. **Given** an adopter whose embedded layout expectation (old paths) disagrees with the reachable
     kit's doctor, **when** the adopter runs its own `check`, **then** it exits non-zero with the
     self-stale code and prints a message naming the kit source and version.
  2. **Given** an adopter whose embedded expectation MATCHES the reachable kit, **when** it runs
     `check`, **then** its verdict is unchanged and a genuinely compliant repo still exits 0.
  3. **Given** no reachable kit source (a CI runner, a fresh machine), **when** the adopter runs
     `check`, **then** it does NOT fake a clean bill of health: it reports that it cannot verify and
     says so, rather than exiting 0 on the strength of its own unverifiable assumptions.

### US-2 — `apply` tells the truth about what it did (P2)

A maintainer runs `apply` to refresh an adopted repo. Today, on a repo whose managed scripts have
drifted, `apply` can change zero managed files, print no drift line, and still rewrite the stamp to
the kit's current version — so the stamp certifies code that is not installed. After this story,
`apply` prints a per-file disposition (`ADDED`, `KEPT`, `DRIFTED`), and does NOT stamp the repo current
unless it actually brought it current; a repo left drifted keeps/gets a stamp that says so.

- **Why this priority:** the stamp is what every downstream reader trusts. A stamp that certifies the
  attempt instead of the state is the second false green, and it is produced by the tool that exists
  to remove false greens.
- **Independent test:** in a drifted adopter fixture, run `apply`; assert the output contains a
  `DRIFTED`/`KEPT` line naming the drifted file, and assert the stamp is NOT advanced to the kit's
  version (it carries a non-current marker / the repo still reports a drifted state).
- **Acceptance scenarios:**
  1. **Given** an adopted repo whose managed script differs from the kit, **when** `apply` runs without
     `--force-scripts`, **then** it prints a per-file line naming that script and its disposition and
     leaves the local file untouched.
  2. **Given** that same drifted repo, **when** `apply` finishes, **then** the stamp does NOT claim the
     kit's current version for a repo the applier left drifted.
  3. **Given** a repo `apply` genuinely brings current, **when** it finishes, **then** the stamp is
     written as current (the honest case must still succeed).

### US-3 — Overwriting local work is always recoverable (P3)

A maintainer runs `apply --force-scripts`, the explicit opt-in that replaces locally edited scripts
with the kit's copies. Today the overwrite is destructive with no backup: a repo-local capability (a
conflict-marker sweep the kit template lacks) is gone with no `.bak` and recovery only through git.
After this story, every forced overwrite writes a recoverable backup beside the original and the
command says where it went.

- **Why this priority:** the destructive path exists and is documented; the only defect is that it is
  unrecoverable. This is the smallest of the three fixes and the most mechanical.
- **Independent test:** edit an installed script, run `apply --force-scripts`; assert a backup file
  exists containing the pre-overwrite bytes and that the command's output names the backup path.
- **Acceptance scenarios:**
  1. **Given** a managed script edited locally, **when** `apply --force-scripts` runs, **then** the
     pre-overwrite bytes exist in a recoverable backup file beside the script.
  2. **Given** that run, **when** it prints, **then** the output names where the backup was written.
  3. **Given** a script that matches the kit (nothing to overwrite), **when** `apply --force-scripts`
     runs, **then** no backup is written (no spurious files).

### US-4 — A deliberate refresh path exists and is documented (P4)

A maintainer on an old-layout adopter wants to bring the repo to the current kit. There is no supported
command for it. After this story there is one documented path — a `migrate` flow or a documented
`apply` refresh — that an agent runs and a human reviews, which never pulls or overwrites silently and
which prints exactly what it will change before it changes it.

- **Why this priority:** detection (US-1) and honesty (US-2) are useless without a way to act on them.
  This is the smallest shape that lets an adopter pull kit fixes deliberately; it is P4 only because it
  depends on the first three being truthful first.
- **Independent test:** in an old-layout adopter-shaped fixture, run the refresh path; assert it
  reports the layout translation it would perform and the files it would touch, and that without the
  explicit flag/first step it makes no destructive change.
- **Acceptance scenarios:**
  1. **Given** an old-layout adopter, **when** the refresh path runs, **then** it reports the
     from-layout and to-layout and the files it will seed, before doing so.
  2. **Given** the refresh path, **when** it runs, **then** it never overwrites a repo-local file
     without the explicit opt-in, and any overwrite is recoverable per US-3.
  3. **Given** the refresh path has run, **when** the repo is checked, **then** it is no longer
     self-stale and reports the reachable kit's layout expectation.

## Edge cases

- What happens when the adopter has NO reachable kit source at all (a fresh CI runner, a machine with
  no clone)? The doctor must not fabricate a green; it reports that it could not verify.
- What happens when the reachable kit source is the adopter itself (the kit repo checking itself)? The
  self-detection must recognise the template repo and not report itself stale.
- What happens when the stamp is absent but the layout matches? Unchanged: still the existing
  no-stamp stale state.
- What happens when two backups would collide (a second forced overwrite)? The backup path must not
  destroy the first backup.
- What happens when the kit source is reachable but its doctor has been locally edited? Comparison is
  on the embedded expectation marker, not on byte-equality of the whole file, so a cosmetic local edit
  to the source doctor does not flip the verdict.

## Requirements

- **FR-001**: The doctor MUST embed a marker identifying the layout/expectation generation it was
  built for, so two kit generations can be told apart without byte-comparing whole scripts.
- **FR-002**: When a copy of the doctor can reach a kit source, `check` MUST compare its own embedded
  expectation against that source's and, on disagreement, exit with a dedicated non-zero code
  (self-stale) and print a message naming the source and the two generations.
- **FR-003**: When a copy of the doctor CANNOT reach a kit source, `check` MUST NOT report a clean bill
  of health on the strength of its own unverifiable assumptions; it MUST report that it could not
  verify (unless explicitly told the repo is mid-migration via the existing off-switch).
- **FR-004**: `apply` MUST print a per-file disposition for every managed file it considers:
  `ADDED` when installed, `KEPT` when a local file differs and is left alone, `DRIFTED` as the summary
  state when any managed file remains different from the kit after the run.
- **FR-005**: `apply` MUST NOT write a stamp claiming the kit's current version when it leaves the repo
  drifted; the stamp MUST certify the state, not the attempt.
- **FR-006**: `apply --force-scripts` MUST write a recoverable backup of each file it overwrites, in a
  path that does not collide across repeated runs, and MUST print the backup path.
- **FR-007**: A documented refresh/migrate path MUST exist that reports the layout translation it
  intends and the files it will touch before making a destructive change, and MUST NOT pull or
  overwrite silently.
- **FR-008**: Every behaviour above MUST have an adversarial canary that fails when the behaviour is
  removed (mutation-proven), not merely a happy-path test.

## Key entities

- **Kit generation marker** — a stable identifier of the layout expectation a doctor copy was built
  for; the thing compared to detect a stale copy.
- **Stamp** — `.panoply-version`: the recorded kit version/sha applied to a repo. Its integrity
  (does it claim current when current is not installed?) is the core concern.
- **Managed file** — a script or rule module the kit installs and `apply` maintains; the unit of the
  per-file disposition report.
- **Backup** — the recoverable copy written before a forced overwrite.

## Success criteria

- **SC-001**: The stale-doctor reproduction flips: on a pilot repo-shaped old-layout fixtures, the
  adopter's own doctor reports self-stale (non-zero) and never `OK` — measured as 0 OK verdicts across
  3 old-layout fixtures, where it was 3 OK verdicts before.
- **SC-002**: `apply` on a drifted repo reports ≥1 per-file disposition line and advances the stamp 0
  times (was: 0 disposition lines, 1 dishonest stamp).
- **SC-003**: `apply --force-scripts` leaves ≥1 recoverable backup per overwritten file (was: 0), and
  the pre-overwrite bytes are byte-identical to the backup.
- **SC-004**: The full kit gate suite and every canary pass, and the new canary cases go red under
  mutation of the code they exercise.

## Assumptions

- The "kit source" a copy can reach is exactly the existing `_canonical_kit_root` search
  (`.panoply`, `.cache/panoply`, `~/panoply`, `$PANOPLY_KIT_ROOT`) — no new
  network access, no auto-pull. The owner's doctrine is that a rule change is reviewed, not silently
  overwritten.
- The new self-stale state gets a NEW exit code so existing tooling that keys on 10–14 is unaffected.
- The refresh path is a `migrate` subcommand rather than a documented `apply` flag, because a layout
  translation (old paths → new paths) is a distinct, reviewable operation and `apply` already carries
  the no-clobber contract.
- Detection is by embedded marker, not by version string, because the version is `unreleased` between
  releases and two generations can share it.

## User interviews (simulated, 4 personas)

n/a — no user-facing surface, so no personas to interview. This change is to the kit's own shell
tooling (`scripts/panoply.sh`) consumed by maintainers, not by end users: there is no screen, flow, or
interaction to design. The personas who WOULD be interviewed if this had a UI are the maintainers
running `apply`/`check`, and their input is captured as the reproduced before/after in §Goal.

## Open questions

_(none — all resolved before planning)_
