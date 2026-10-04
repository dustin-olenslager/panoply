# Plan: the context-file cap, stated truthfully

- **Area:** `governance` · **Started:** 2026-10-04 · **Status:** In progress
- **Owner:** Hermes
- **Next step:** merge this PR; the adopter repo (frame-forge) carries the same correction.

## What

The kit tells adopters how large `AGENTS.md` may be. Two of those statements are false, and both
were verified false against the code that actually enforces the limit — not against prose.

## Deletion candidates

| Candidate | Removed? | Why |
|---|---|---|
| The claim that the cap is "a ~20,000 char cap" | **removed** | It is a floor, not a ceiling, per `prompt_builder.py`. |
| The claim that truncation is "silent" (5 sites) | **removed** | The loader reports it and points at `read_file`. |
| The `cap=20000` constant in `doc-map.sh` | **kept** | The number is a real, useful floor to budget against; only its framing was wrong. |
| The doctrine "trim the file, do not raise the floor" | **kept** | Correct and unaffected — it needs no change. |
| The whole request | **not removed** | A false statement inside the artifact is the defect class this kit exists to remove; leaving it is not cheaper than fixing it. |

## Evidence — traced to the enforcing code

`Agent/prompt_builder.py`:

- `CONTEXT_FILE_MAX_CHARS = 20_000` — the **floor**.
- `CHARS_PER_TOKEN = 4`, `_CONTEXT_FILE_WINDOW_FRACTION = 0.06`, `_CONTEXT_FILE_DYNAMIC_CEILING = 500_000`.
- `cap = max(20_000, min(int(window * 4 * 0.06), 500_000))`.

Measured caps: 8K window → 20,000 · 128K → 30,720 · 200K → 48,000 · 1M → 240,000.

Truncation: `_truncate_content` keeps head 70% + tail 20% (`CONTEXT_TRUNCATE_HEAD_RATIO` /
`TAIL_RATIO`), logs `Context file <name> TRUNCATED: N chars exceeds limit of M`, and names the
`read_file` path to the full text.

## Acceptance

- No site in the kit calls the cap flat or the truncation silent.
- The doctrine keeps its remedy (trim the file), now with the mechanism stated.
- `sh scripts/check-docs.sh` passes.

## Milestones

- [x] The real cap and the truncation path, established in the enforcing source — `scripts/doc-map.sh`
- [x] The budget comment and the failure message corrected — `scripts/doc-map.sh`
- [x] The five "silently truncated" claims corrected — `scripts/sync-agents.sh`
- [x] The doc gate green — `scripts/check-docs.sh`
