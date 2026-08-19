# Claude Project Template

A drop-in agent-governance kit for any project — new or existing, any language, any stack. Built on
Claude Code's config format, but it binds **every coding agent that touches the repo** — Codex,
Cursor, Copilot, Windsurf, Cline, aider, Gemini, and Claude alike. Copy it in, run one command, and
whatever tool works here arrives already knowing how you work: Clean Architecture as the premise, a
change-approval protocol, plan files that survive context compaction, migration safety rails,
enforced test coverage, and a documentation system that keeps project knowledge in the repo instead
of in one person's chat history.

## Quickstart

The kit lives in a versioned GitHub repo; `degit` copies its file tree with **no upstream git history**
to entangle with yours. No install, one command.

**New project:**

```
npx degit dustin-olenslager/panoply my-app
cd my-app && git init
```

Then open Claude Code in the project and run:

```
/adapt-claude-setup
```

**Existing repo** (drop the kit alongside code you already have): stage it in a temp dir so it never
clobbers a `CLAUDE.md` or `AGENTS.md` you already wrote, then let the adapt command merge — your
rules win every conflict.

```
npx degit dustin-olenslager/panoply .claude-kit-tmp
```

Then in Claude Code:

```
/adapt-claude-setup
```

`/adapt-claude-setup` reads the staged kit and binds **every agent and tool working in the repo**,
not just Claude. Three things carry that guarantee, and they are the headline of what the command
installs:

- **`AGENTS.md`** — the cross-tool hub that Codex, aider, and the rest read on entry. The command
  merges it into your project's existing `AGENTS.md` (yours wins every conflict), so the onboarding
  contract and non-negotiables are one shared contract for every tool.
- **Provider mirrors** — `scripts/sync-agents.sh` generates the tool-native rule files from
  `AGENTS.md`: `.cursor/rules/` (Cursor), `.github/copilot-instructions.md` (Copilot),
  `.windsurf/rules/` (Windsurf), `.clinerules/` (Cline), `GEMINI.md` (Gemini), and `CONVENTIONS.md`
  (aider). Each generated file is **fully self-contained** — the **complete ruleset is inlined**,
  not a pointer to `.claude/rules/` — so Cursor, Copilot, Windsurf, Cline, aider, and Gemini each
  read the entire governance from their own native file with **zero Claude dependency**, and
  `AGENTS.md` carries the full rules inline too (no `@`-imports). One source of truth, mirrored per
  vendor; a CI `sync-agents.sh --check` keeps every mirror in lockstep with the source.
- **CI + pre-commit** — `.github/workflows/verify.yml` plus the pre-commit hook are the enforcement
  plane that binds the repo regardless of which tool wrote the code.

Claude is one consumer of that shared contract. Its slice — `.claude/` and `CLAUDE.md` — is merged
in as a sub-point of the broader install: the kit's `CLAUDE.md` is renamed to `CLAUDE.template.md`
when you already have one, and `.claude/settings.json` deny-rules bind Claude alone. For every other
tool those same prohibitions ride along as doc-level MUST-NOTs in `AGENTS.md`, backstopped by CI.
The command also fills every placeholder, prunes the modules that don't apply, and deletes
`.claude-kit-tmp` when it's done.

Answer at most five questions (each has a default — "accept all" works). The command inspects your
manifests, scripts, CI config, and directory layout first, and only asks what it genuinely cannot
infer.

That's it. The command fills every placeholder, deletes the modules that don't apply to your
project, maps the four Clean Architecture layers onto your actual directories, and reports what it
inferred, what it deleted, and the few high-value things only you can add by hand.

Months later, run `/audit-claude-setup` to check the configuration still matches reality —
commands that no longer exist, stale docs, new stack elements with no rules module, and
import-direction drift. Its sibling `/assess-stack` asks the prior question: is the stack itself
still the right choice? It live-researches every element's support status, currency, and
maintenance trajectory, judges fit against your project's own pillars, and prices the exit using
the Clean Architecture layer map — behind a port means an adapters-only swap; bled inward means
port-extraction first, and it tells you both numbers. Run it with `--save` to keep dated reports
and get per-element trend tracking.

## The `/panoply` skill (one-instruction apply)

Everything the Quickstart does by hand — fetch the kit, then run `/adapt-claude-setup` — collapses
into a single natural-language instruction once the `panoply` skill is installed. Say **"use
panoply"**, **"panoply this"**, or **`/panoply [path]`** (the path is optional and defaults to the
current directory), and Claude Code fetches the kit into a temp dir and runs the adapt against the
target for you. The skill is a thin trigger: it clones the kit and hands the whole job to the kit's
own `/adapt-claude-setup`, so the applier and the kit can never drift.

Two distinct layers — don't conflate them:

- **The kit** (this repo — `skills/panoply/SKILL.md` now ships inside it) is the per-repo governance
  content that gets copied into a project.
- **The skill** (`~/.claude/skills/panoply/SKILL.md`) is a global/personal Claude Code skill — the
  *applier* layer. It lives in your Claude Code config, not in any project, and its only job is to
  fetch-and-adapt the kit on request.

**Install the skill (once per machine):**

```
mkdir -p ~/.claude/skills/panoply
cp skills/panoply/SKILL.md ~/.claude/skills/panoply/SKILL.md
```

(Copy it from a `degit`/clone of this repo, or straight out of an already-adapted project.) After
that, `use panoply` in any project triggers the fetch-and-adapt — no need to remember the `degit`
command or the temp-dir dance.

## What's inside

```
CLAUDE.md                        The spine. Short on purpose — it loads into every context
                                 window. Depth lives in the imported rules modules.
.claude/
  settings.json                  Safe-by-default permissions: read-only inspection allowed
                                 silently, destructive commands denied outright.
  settings.local.json.example    Per-developer overrides (git-ignored) — loosen locally
                                 without committing that choice.
  commands/
    adapt-claude-setup.md        The one-command onboarding described above.
    audit-claude-setup.md        The periodic reality check.
    assess-stack.md              Is the stack itself still the right choice? Live-researched
                                 health/fit/exit-cost report — never from training memory.
  rules/                         Modular guidelines, @-imported by CLAUDE.md:
    clean-architecture.md        THE FOUNDATION — the four layers, the Dependency Rule,
                                 ports & adapters, and a mechanical review checklist.
                                 Every other module inherits from this one.
    workflow.md                  Change approval + planning protocol.
    quality-bar.md               The check that stops the easy path winning by default.
    git-workflow.md              Branching, commits, the stacked-PR trap and its recovery.
    documentation.md             How docs/claude/ works.
    code-style.md  testing.md  error-handling.md
    database.md  data-modeling.md  api-design.md
    frontend.md  design-system.md  ai-features.md
  agents/                        A library of specialist subagents (architect, reviewer,
                                 security, database, UI/UX...) — see agents/README.md.
docs/claude/                     The project-knowledge system, pre-scaffolded:
  in-progress.md                 Ordered queue of what's next. Claude reads this first.
  completed-features.md  architecture.md  infrastructure.md  key-patterns.md
  _templates/                    Plan-file template + feature-area folder convention.
```

## The two ideas that make it work

**Clean Architecture is the premise, not a module.** `clean-architecture.md` defines the four
layers and the Dependency Rule; every other rules file carries only the consequence for its own
subject (the ORM is a detail; domain errors are domain types; components render and dispatch).
The adapt command maps the layers onto your real directories — and if your existing codebase
doesn't follow them yet, it says so honestly and records the gaps instead of pretending.

**Prune, don't leave blanks.** Optional content sits inside `<!-- MODULE:x -->` fences. A project
with no database gets those rules deleted — file, imports, and fences — not left half-filled. An
unfilled `{{PLACEHOLDER}}` teaches the model that the whole file is decoration, so the adapt
command's final phase greps for leftovers and refuses to finish while any remain.

## Permissions note

`settings.json` ships with `"defaultMode": "default"` — every write and execute prompts, while
read-only inspection (status, diff, log, test runs, typechecks) is pre-approved to cut prompt
fatigue. If you want a looser mode, set it in `.claude/settings.local.json` (and add that file to
`.gitignore`): `"acceptEdits"` auto-accepts file edits but still prompts for shell commands;
`"bypassPermissions"` skips all prompts and belongs only in throwaway sandboxes. Keep the deny
list either way — it is the backstop against force-pushes, secret reads, schema-destroying
commands, and pipe-to-shell installs, whatever the mode.

## Adapting it by hand

Everything the adapt command does, you can do manually: fill the `{{PLACEHOLDERS}}` in CLAUDE.md
and the rules files, delete module fences (and their `@` imports) that don't apply, delete agents
you won't use, and fill the layer table in `clean-architecture.md`. Each rules file opens with a
two-line header saying when it applies and when to delete it.

The one habit that keeps the kit alive: when you catch yourself correcting Claude the same way
twice, that correction is a missing rule — add it to the "Project-Specific Rules" section of
CLAUDE.md or the relevant module. The template gives you the skeleton; the corrections you feed it
are what make it yours.
