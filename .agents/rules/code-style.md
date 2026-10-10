# Code Style & Patterns

> **Applies when:** always — any project in which an agent reads, writes, or edits source code.
> **Delete this file (and its `@` import in the generated agent hub) if:** never. Trim individual rules instead.

## Before you write code

- Read the existing code in the area you are about to change, before changing it. The patterns already in use beat the ones you would pick fresh, and matching them keeps review cheap.
- Prefer editing an existing file over creating a new one. Create a file only when the code carries a genuinely new responsibility — otherwise you fragment what a reader has to hold in their head.
- **Where a new file goes is a layer question before it is a folder question.** Decide first whether the code is a domain rule, a use case, an adapter, or framework wiring (see `clean-architecture.md`); the folder follows from that answer. Picking the folder by resemblance is how business rules end up living inside a controller.
- Do not add features, refactors, renames, or "improvements" beyond what was requested. Unrequested changes bury the requested one in the diff and force the reviewer to re-review working code.
- When adding a new entity, endpoint, screen, or job, follow the structure of the closest existing one — same folder, same layering, same naming. "It matches the neighbouring code" is a checkable standard; "it's cleaner" is not.

## Structure

- **One responsibility per file.** A file that renders a view *and* fetches data *and* formats currency has three reasons to change and cannot be tested or reused in pieces. Split it.
- **Three similar lines beat a premature abstraction.** Duplicate until the shape of the variation is actually known; an abstraction built from one example encodes an accident as a rule and is harder to unwind than the duplication was.
- Keep call depth shallow. If a change requires editing four files to add one field, the layering is the bug — say so rather than adding a fifth.

## Comments

A comment earns its place by saying **why** — the reason, the constraint, the gotcha, the thing a
reader cannot see in the code. Everything else in a comment is decoration, and decoration costs the
next reader attention it never gets back.

- **No comment that restates the line below it.** `// Initialize the variable` above `let count = 0`,
  `// User class` above `class User {}`, `/** @param price The price. */`. The code already says it;
  the comment doubles the reading load and adds nothing. This is the most common slop of all.
- **No decorative separators or banners.** A run of punctuation around a section name
  (`// ================ Authentication ================`, `# ---- ROUTES ----`, `/* --- helpers --- */`),
  a box drawn with line characters, or an ALL-CAPS label wrapped in one. The decoration IS the message:
  the label should be a plain line at most, and a file that needs visual sections usually needs
  splitting instead. A single plain line naming what follows is fine; four equals signs are not.
- **No emoji in a comment.** `// ✅ Validation`, `# 🚀 Performance`. Emoji is not information, and the
  set that shows up first (checkmark, rocket, lock, sparkle) is the same set every model reaches for.
- **No workflow narration.** `// Step 1: validate the input`, `// First…`, `// Next…`, `// Finally…`.
  The control flow is visible in the code itself; numbering it reads as a checklist rather than an
  explanation. If the flow is genuinely hard to follow, that is a structure problem, not a missing
  comment.
- **No end markers.** `} // end if`, `# End of function`, `// end processOrder`. The closing brace
  already ends the block.
- **No empty labels.** `// Main logic`, `// Business logic`, `// Helper function`, `// Note: this is
  important`. A label that names a category instead of a fact tells the reader nothing they could not
  infer. `// Note: retries happen only on 5xx` earns its place; `// Note: this is important` does not.
- **Keep the comments that carry information:** why this exists, why not the obvious alternative, the
  invariant that must hold, the upstream quirk, the ticket or ADR that explains it, and a TODO that
  names a specific task ("retire once the v1 client is gone") rather than a feeling ("improve this").
- **Never commit commented-out code.** Version control is the archive; a commented block is read as
  live context by everyone who comes after. Delete it — the history keeps it.

`scripts/check-comments.sh` enforces the mechanical half — banners, emoji, narration, end markers,
empty labels — over **the lines a change adds**, with `COMMENTS_OFF=1` as the declared exception. Two
things it deliberately does not do: it cannot judge whether a comment is *worth* keeping (a restating
comment passes it), and it does not read a trailing `#` or `--` comment. Both are review questions, and
they stay review questions rather than becoming a gate that measures the easy half and reports coverage.

## Import direction

- **An import that points outward is a style violation, and it is visible in the diff.** Source-code dependencies point inward only (see `clean-architecture.md`), so a domain or use-case file importing an ORM, HTTP framework, UI library, or vendor SDK is wrong on sight — a reviewer can catch it from the import block alone, with no test run and no debate.
- When inner code needs something outer code owns, the inner layer declares the interface (the port) and the outer layer implements it (the adapter). Do not add the outward import "for now": that is the import that never gets removed, and it silently makes the inner layer unusable without the outer one.

## Constants and typed values

- **No magic strings or magic numbers.** Any value compared, switched on, or stored (statuses, roles, event names, kinds, feature keys) comes from the project's shared enum/constant module — see the table below. Inline literals drift between producer and consumer, and the compiler/linter cannot catch the drift.
- When you need a new status or kind, add it to the shared module first, then use it. Never introduce it as a literal "just for now."
- Shared types and constants are declared once and imported. Two definitions of the same union will diverge.

## Use the project's own wrappers

Those wrappers are the adapters that sit between your code and the Details it depends on. Call the adapter; never reach past it to the thing behind it — reaching past is exactly how a Detail escapes its layer.

- **Never make a raw HTTP call from feature code.** Use the project's existing client/API wrapper — it centralizes base URLs, auth headers, error shaping, and retries, and a raw call silently opts out of all four.
- Same rule for data access: go through the project's query builder / repository / ORM layer rather than raw query strings in handler code, so that escaping, typing, and connection handling stay in one place.
- If the wrapper genuinely cannot express what you need, extend the wrapper and say so — do not bypass it locally.

<!-- MODULE:project-conventions — the adapt command fills this table from repo inspection. KEEP always; replace every {{TOKEN}} with the project's real answer, or delete the row if the project has no such convention. -->

## Project conventions (filled in by `/adapt-agents-setup`)

| Convention | This project's rule |
| --- | --- |
| Export style | `{{EXPORT_STYLE}}` (e.g. named exports only, no default exports) |
| Import alias / module path for internal imports | `{{IMPORT_ALIAS}}` |
| Shared enums, constants, and cross-boundary types live in | `{{SHARED_CONSTANTS_PATH}}` |
| File and symbol naming | `{{FILE_NAMING}}` (e.g. kebab-case files, PascalCase components, camelCase functions) |
| The API/HTTP wrapper all feature code must call | `{{API_WRAPPER}}` |
| The data-access layer all persistence must go through | `{{DATA_ACCESS_LAYER}}` |
| Formatter / linter that decides mechanical style | `{{FORMAT_CMD}}` |

Mechanical style (quotes, semicolons, line width, import order) is whatever the formatter emits. Do not hand-argue formatting; run `{{FORMAT_CMD}}`.

<!-- /MODULE:project-conventions -->

## Dead code cleanup

Removing a caller is only half the change. When your edit removes the **last** reference to something, remove the thing too, in the same change:

- Removed the last navigation into a view/route/screen? Delete the route entry, the view component, and its state branch. An unreachable view still costs bundle size, test time, and reader attention, and it rots into a broken page nobody notices.
- Removed the last call site of an endpoint? Delete the endpoint, its handler, and its test.
- Removed the last import of an exported function, type, or constant? Delete the export.
- Removed the last consumer of a feature flag, config key, or environment variable? Delete it from the config and the deployment docs.

Before deleting, search the whole repo for the symbol (including string references and dynamic lookups) to confirm it is truly the last one. If a reference exists only in a test that tests nothing else, the test goes too. If you are unsure whether something is reachable, say so and ask — do not leave it silently orphaned.
