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

### Panoply Optimization — Mandatory PR gates, expert review, docs enforcement — 2026-08-21
- **What shipped:** Full enforcement plane for any project adopting the kit: (1) `scripts/init-repo-protection.sh` — interactive branch protection via `gh` CLI (require PR, require `verify` check, forbid force-push, forbid direct push); (2) `scripts/check-expert-review.sh` — CI gate verifying expert review evidence (plan.md, checklist.md, adr.md new section, ≥2 persona sign-offs) with trivial escape hatches (label "trivial", commit prefix "trivial:", 1-file ≤15-line no-schema); (3) Expert-review policy in `.claude/rules/workflow.md` and `AGENTS.md` (4 default personas: Security, Performance, Maintainability, UX); (4) Updated CI/pre-commit templates with expert-review + docs gates; (5) Kit repo dogfood: `.github/workflows/verify.yml` with all gates; (6) Adapt command Phase 10 updated to wire expert-review gate and report branch protection outcome.
- **Area:** `governance`
- **Archived plan:** `governance/completed/plan.md` (master plan), `governance/completed/checklist.md`, `governance/completed/brief.md`, `governance/completed/adr.md` (ADR-0001)
- **Notable decisions:** Interactive `gh` CLI for branch protection (not auto-API, not CI-fail); grep-based evidence check for expert review (not artifact check); trivial escape hatch prevents ceremony overload; policy in use-case layer (workflow.md), gate in framework layer (CI script) — Clean Architecture honored.
- **Known gaps:** Branch protection requires `gh` auth (falls back to manual instructions); expert-review evidence can be boilerplate (mitigated by review culture + adversary-review skill); no hosted platform/MCP/self-updating docs.

---

### Docs-gate — Mechanical landing gate enforcing worklog currency — 2026-08-21
- **What shipped:** `scripts/check-docs.sh` fails any commit that changes non-markdown files (source, config, schema, scripts, CI) without also updating the worklog target (`CHANGELOG.md`/`HISTORY.md` `[Unreleased]` or `docs/claude/worklog.md`) in the same commit. Runs in required CI and pre-commit hook — provider-neutral, POSIX sh, no runtime deps.
- **Area:** `governance`
- **Archived plan:** `governance/completed/docs-gate.md`
- **Notable decisions:** Enforces presence, not correctness — a garbage worklog line passes; correctness is a review problem. Worklog target auto-detected, overridable via `DOCS_WORKLOG`. Doc files exempt by default (ext `md`).
- **Known gaps:** No agent-authored self-updating docs; no hosted platform/MCP; no Claude-only PreToolUse precondition.

---

<!-- New entries go directly below this line, newest first. -->
