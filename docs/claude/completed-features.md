# Completed Features

The shipped log. One entry per feature, newest first. Read this before proposing work — it is the
cheapest way to avoid rebuilding something that already exists.

Add an entry when a feature is tested and signed off, at the same time you move its folder into
`<area>/completed/`.

## Entry format

```markdown
### <Feature name> — YYYY-MM-DD
- **What shipped:** one or two sentences, in terms of what a user or caller can now do.
- **Area:** `<area>`
- **Archived plan:** `<area>/completed/<feature>/<renamed-file>.md`
- **Notable decisions:** anything that constrains future work; link the ADR in `architecture.md`.
- **Known gaps:** what was deliberately left out, so the next person does not read it as a bug.
```

---

### EXAMPLE — Paginated records list — 2026-01-15
- **What shipped:** the records table loads a page at a time with server-side filtering and sort,
  replacing the load-everything fetch.
- **Area:** `ui`
- **Archived plan:** `ui/completed/records-list/server-side-pagination.md`
- **Notable decisions:** cursor-based paging over offset — see ADR-0004 in `architecture.md`.
- **Known gaps:** no saved filter presets; deferred, tracked in `in-progress.md` under Parked.

_Delete the example entry once the first real feature ships._

---

### Docs-gate — Mechanical landing gate enforcing worklog currency — 2026-08-21
- **What shipped:** `scripts/check-docs.sh` fails any commit that changes non-markdown files (source, config, schema, scripts, CI) without also updating the worklog target (`CHANGELOG.md`/`HISTORY.md` `[Unreleased]` or `docs/claude/worklog.md`) in the same commit. Runs in required CI and pre-commit hook — provider-neutral, POSIX sh, no runtime deps.
- **Area:** `governance`
- **Archived plan:** `governance/completed/docs-gate.md`
- **Notable decisions:** Enforces presence, not correctness — a garbage worklog line passes; correctness is a review problem. Worklog target auto-detected, overridable via `DOCS_WORKLOG`. Doc files exempt by default (ext `md`).
- **Known gaps:** No agent-authored self-updating docs; no hosted platform/MCP; no Claude-only PreToolUse precondition.

---

<!-- New entries go directly below this line, newest first. -->
