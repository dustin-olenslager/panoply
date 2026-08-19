# {{PROJECT_NAME}} — Claude Code Guidelines

<!-- Run `/adapt-claude-setup` to fill this file in from the repo. Anything still wrapped in
     {{DOUBLE_BRACES}} is unfilled — fill it or delete the line. An unfilled placeholder is worse
     than a missing rule: it teaches the model that this file is decoration. -->

## Project Overview

{{ONE_LINE_DESCRIPTION}}

**Core pillars**: {{CORE_PILLARS}}
<!-- The 2–4 things that make this project different, and the standard every feature is judged
     against. Be concrete. "Good data, reports, AI-first workflows — data quality is the foundation
     that everything else depends on" beats "high quality and scalable". -->

## Tech Stack

- **Language / runtime**: {{LANGUAGE_RUNTIME}}
- **Package manager**: {{PKG_MANAGER}}
<!-- MODULE:frontend -->
- **Client**: {{CLIENT_STACK}}
<!-- /MODULE:frontend -->
- **Server**: {{SERVER_STACK}}
<!-- MODULE:database -->
- **Data**: {{DATABASE_STACK}}
<!-- /MODULE:database -->
<!-- MODULE:monorepo -->
- **Workspace layout**: {{MONOREPO_LAYOUT}}
<!-- /MODULE:monorepo -->

## Key Commands

| Purpose | Command |
|---|---|
| Install | `{{INSTALL_CMD}}` |
| Dev | `{{DEV_CMD}}` |
| Test | `{{TEST_CMD}}` |
| Typecheck / static analysis | `{{TYPECHECK_CMD}}` |
| Lint | `{{LINT_CMD}}` |
| Build | `{{BUILD_CMD}}` |
<!-- MODULE:arch -->
| Architecture boundary check | `{{ARCH_CHECK_CMD}}` |
<!-- /MODULE:arch -->
<!-- MODULE:database -->
| Generate migration | `{{MIGRATE_GEN_CMD}}` |
| Apply migration | `{{MIGRATE_APPLY_CMD}}` |
<!-- /MODULE:database -->

Every command in this table must actually exist in the project's script table. If one doesn't, the
model will confidently run a command that fails — delete the row instead.

## Project Structure

```
{{PROJECT_STRUCTURE}}
```
<!-- Annotate the directories that carry a convention, not every directory. The useful form is
     `path/ — what belongs here and what doesn't`. Skip anything self-explanatory. -->

## How We Work Together

The rules below are not suggestions. When a rule and a shortcut conflict, the rule wins — or you
raise the conflict explicitly and let me decide. Read the module that governs what you're touching
before you touch it.

<!-- Cross-tool agents (Codex, Cursor, Gemini, Copilot, Windsurf, Cline, aider): the provider-neutral
     hub is AGENTS.md at the repo root — read it first. Claude loads it via the import below, so the
     onboarding contract, the non-negotiables, and the hard guardrails are in every Claude context too. -->
@AGENTS.md

### Architecture — the premise everything else inherits from

**Clean Architecture is the premise of all coding efforts in this project.** Business rules live in
the core; the database, the web framework, the UI, and every vendor are replaceable details at the
edge; source-code dependencies point inward only. Every other rules module below is an application
of this premise to its own subject.

@.claude/rules/clean-architecture.md

### Process — how changes get proposed, planned, and landed
@.claude/rules/workflow.md
@.claude/rules/quality-bar.md
@.claude/rules/git-workflow.md
@.claude/rules/documentation.md

### Code — style, tests, failure handling
@.claude/rules/code-style.md
@.claude/rules/testing.md
@.claude/rules/error-handling.md

### Data & interfaces — schema, modeling, API boundaries
<!-- MODULE:api -->
@.claude/rules/api-design.md
<!-- /MODULE:api -->
<!-- MODULE:database -->
@.claude/rules/database.md
@.claude/rules/data-modeling.md
<!-- /MODULE:database -->

<!-- MODULE:frontend -->
### Interface — front-end engineering and visual language
@.claude/rules/frontend.md
<!-- /MODULE:frontend -->
<!-- MODULE:design-system -->
@.claude/rules/design-system.md
<!-- /MODULE:design-system -->

<!-- MODULE:ai -->
### AI features — model calls, prompts, enrichment
@.claude/rules/ai-features.md
<!-- /MODULE:ai -->

## Project Knowledge

Team-shared context lives in `docs/claude/` and is committed to git. **Read these when relevant:**

- `docs/claude/roadmap.md` — **the overall plan** — initiatives (Now/Next/Later); read with in-progress.md
- `docs/claude/in-progress.md` — **start here** — the ordered queue of what's next, with pointers to plan docs
- `docs/claude/completed-features.md` — what's already been built
- `docs/claude/worklog.md` — running change log (or the `CHANGELOG` `[Unreleased]`); append one line in the same commit as your change
- `docs/claude/architecture.md` — key decisions and why they were made
- `docs/claude/infrastructure.md` — deploy pipeline, hosting, data stores, jobs
- `docs/claude/key-patterns.md` — dev patterns, gotchas, testing conventions

Personal preferences and per-user workflow rules stay in local `~/.claude/` memory, not here.

## Project-Specific Rules

<!-- Everything above is portable across projects. Everything below is yours alone: the invariant
     that isn't obvious from the code, the integration that breaks in a surprising way, the
     convention a new contributor gets wrong every time. Add rules here as you catch yourself
     correcting the same mistake twice — that repetition is the signal that a rule is missing. -->

- _(none yet)_
