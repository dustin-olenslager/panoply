# Panoply — agent-agnostic project governance

A drop-in governance kit for any project — new or existing, any language, any stack, any agent or LLM
platform. Copy it in, run one command, and every agent that touches the repo arrives already knowing
how you work.

```
npx degit dustin-olenslager/panoply my-app
cd my-app && git init
```

Then run `.agents/commands/adapt-agents-setup.md` with whatever agent you use. It fills every
placeholder, prunes the modules that don't apply, maps the architecture layers onto your real
directories, and reports what it inferred, what it deleted, and the few things only you can add.

**What you get:** Clean Architecture as the premise, a change-approval protocol, plan files that
survive context compaction, migration safety rails, enforced verification, and a documentation system
that keeps project knowledge in the repo instead of in one person's chat history.

## The problem this solves

Every agent you point at a repo starts from zero and re-derives your standards from whatever it can
infer. The result is predictable: the same correction, made twice a week, forever — because the
correction was never written down anywhere the next agent reads.

Panoply is that writing-down. It gives the repo a governance spine that agents read *before* they act:
what the layers are, what must be approved, what gets verified, and where knowledge goes. The habit
that keeps it alive is in the last section.

## How it stays agent-agnostic

The canonical source lives in three places, and none of them belong to a vendor:

| Path | What it is |
|---|---|
| `AGENTS.md` | The cross-tool hub. Non-negotiables, read order, guardrails. |
| `.agents/rules/*.md` | The rule modules. Depth lives here. |
| `docs/agents/` | Project knowledge — the plan spine, architecture, infrastructure, in-progress queue. |

Tool-native mirrors are **generated** by `scripts/sync-agents.sh` and never committed. Each generated
file is **fully self-contained** — the complete ruleset is inlined, not a pointer to `.agents/rules/` —
so any agent reads the entire governance from its own native file. One source of truth, mirrored per
vendor, with a CI `sync-agents.sh --check` keeping every mirror in lockstep with the source.

**Never hand-edit a mirror.** Edit the source and re-run the sync.

## The two ideas that make it work

**Clean Architecture is the premise, not a module.** `clean-architecture.md` defines the four layers
and the Dependency Rule; every other rules file carries only the consequence for its own subject. The
adapt command maps the layers onto your real directories — and if your existing codebase doesn't follow
them yet, it says so honestly and records the gaps instead of pretending.

**Prune, don't leave blanks.** Optional content sits inside `<!-- MODULE:x -->` fences. A project with
no database gets those rules deleted — file, imports, and fences — not left half-filled. An unfilled
`{{PLACEHOLDER}}` teaches the model that the whole file is decoration, so the adapt command's final
phase greps for leftovers and refuses to finish while any remain.

## Pulling in kit fixes (the update path)

A repo that already adopted the kit keeps its **own copy** of the scripts and rule modules, so a kit
fix does not reach it by itself. Three commands cover the lifecycle, and none of them pull from the
network — a rule change is **reviewed**, never silently overwritten:

```
sh scripts/panoply.sh check        # is this repo on the current kit? (exit 0 = yes)
sh scripts/panoply.sh apply        # refresh the deterministic half; prints ADDED/KEPT/DRIFTED per file
sh scripts/panoply.sh migrate      # carry an OLD-layout repo onto the current layout
```

- **`check` never lies about which copy is stale.** The doctor embeds a *generation* marker; when it
  carries none, when a reachable kit source disagrees, or when the repo's own committed doctor is an
  older generation, it reports `SELF-STALE` (exit 15) instead of a clean `OK`. A doctor that cannot
  verify refuses rather than failing open.
- **`apply` tells the truth.** Every managed file it considers prints its disposition — `ADDED`,
  `KEPT` (yours wins), `DRIFTED` (differs, and was **not** brought current), `FORCED` (replaced, with a
  backup named). If anything stayed drifted the stamp reads `<version>+drifted` and `apply` exits 12: a
  stamp certifies the *state*, never the attempt.
- **`--force-scripts` is recoverable.** Before overwriting a locally-edited file it writes
  `scripts/<file>.panoply-bak` and says where. Read the kit `CHANGELOG` before reaching for it.
- **`migrate`** translates an old-layout repo (`docs/claude/` + `.claude/rules/`) onto the current one
  (`docs/agents/` + `.agents/rules/`), reporting the translation first, copying your adapted content
  forward, leaving the old tree in place for review, and refreshing the doctor itself.

The escape hatch `PANOPLY_OFF=1` disables `check` entirely for a repo mid-migration.

## What's inside

```
AGENTS.md                        The canonical cross-tool hub. Non-negotiables, read order,
                                 guardrails. Depth lives in the imported rule modules.
.agents/
  policy.md                      Tool-agnostic MUST-NOT guardrails and safe defaults.
  rules/                         Modular guidelines, @-imported by the generated agent hub:
    clean-architecture.md        THE FOUNDATION — the four layers, the Dependency Rule,
                                 ports & adapters, and a mechanical review checklist.
                                 Every other module inherits from this one.
    workflow.md                  Change approval + planning protocol.
    quality-bar.md               The check that stops the easy path winning by default.
    git-workflow.md              Branching, commits, the stacked-PR trap and its recovery.
    documentation.md             How docs/agents/ works.
    code-style.md  testing.md  error-handling.md
    database.md  data-modeling.md  api-design.md
    frontend.md  design-system.md  ai-features.md
    agent-readiness.md           DUAL-MODE: the app is usable by a human in its UI *and*
                                 drivable by an AI agent. The three surfaces (HTTP API,
                                 MCP server, A2A agent card), idempotency for retrying
                                 agents, BYO-LLM-key config, scoped agent identity, and
                                 the trust rule that agent writes are visible + reversible.
                                 Pairs with scripts/check-agent-readiness.sh.
    algorithm.md                 Question, delete, simplify, accelerate, automate last.
  personas/                      Specialist agent prompts (architect, reviewer, security,
                                 database, UI/UX...) — see personas/README.md.
  commands/
    adapt-agents-setup.md        The one-command onboarding.
    audit-agents-setup.md        The periodic reality check.
    assess-stack.md              Is the stack itself still the right choice?
docs/agents/                     The project-knowledge system, pre-scaffolded:
  in-progress.md                 Ordered queue of what's next. Read this first.
  completed-features.md  architecture.md  infrastructure.md  key-patterns.md
  _templates/                    Plan-file template + feature-area folder convention.
scripts/                         Machine surface: panoply.sh, sync-agents.sh, gates, canaries.
```

Months later, run `.agents/commands/audit-agents-setup.md` to check the configuration still matches
reality — commands that no longer exist, stale docs, new stack elements with no rules module, and
import-direction drift. Its sibling `/assess-stack` asks the prior question: is the stack itself still
the right choice?

## What is enforced, and what merely advises

Worth being precise about, because the difference decides whether any of this holds.

**Enforced by the repo, whatever tool wrote the code:** `.github/workflows/verify.yml` plus the
pre-commit hook — the check that code changed and the worklog did not, the plan-before-code gate, the
architecture-boundary check, and `sync-agents.sh --check` for mirror drift.

**Prose, and only as strong as the agent reading it:** `.agents/policy.md` — the hard MUST-NOTs
(secrets, destructive filesystem operations, privilege escalation, git history rewriting, arbitrary
code from the network, publishing, destructive DB commands) plus safe-default command classes. It binds
no tool that does not read it. If your agent supports a permission file, translate this document into
that format — but keep `.agents/policy.md` as the canonical source.

**The real cross-tool backstop is server-side:** branch protection on the default branch and required
CI status checks. A client-side hook is skippable with `--no-verify`; CI is the plane that actually
binds.

## Using the agent?

Run `scripts/sync-agents.sh` to generate the mirror files for whichever agent or LLM platform you use.
They are gitignored in the kit so the canonical source stays agent-agnostic, but they live in your
working tree and are read by your tool. Re-run `sync-agents.sh` whenever you edit a rule module.

## The Panoply skill (one-instruction apply)

Everything the Quickstart does by hand collapses into a single instruction once the `panoply` skill is
installed in your agent. Say **"use panoply"** or **"panoply this"**, and the agent fetches the kit into
a temp dir and runs the adapt against the target for you. The skill is a thin trigger: it clones the kit
and hands the whole job to the kit's own `adapt-agents-setup`, so the applier and the kit can never
drift.

- **The kit** (this repo) is the per-repo governance content that gets copied into a project.
- **The skill** is the global/personal applier layer in your agent's config. Its only job is to
  fetch-and-adapt the kit on request.

See [`skills/panoply/SKILL.md`](skills/panoply/SKILL.md) for the skill text.

## Adopting an existing repo

Stage the kit in a temp dir so it never clobbers an `AGENTS.md` you already wrote, then let the adapt
command merge — **your rules win every conflict**.

```
npx degit dustin-olenslager/panoply .agents-kit-tmp
```

## Adapting it by hand

Everything the adapt command does, you can do manually: fill the `{{PLACEHOLDERS}}` in `AGENTS.md` and
the rules files, delete module fences (and their `@` imports) that don't apply, delete personas you
won't use, and fill the layer table in `clean-architecture.md`. Each rules file opens with a two-line
header saying when it applies and when to delete it.

## The habit that keeps it alive

When you catch yourself correcting an agent the same way twice, that correction is a **missing rule**.
Add it to the "Project-Specific Rules" section of `AGENTS.md`, or to the relevant module — then re-run
`sync-agents.sh` so every mirror picks it up.

The template gives you the skeleton. The corrections you feed it are what make it yours.

## License

MIT — see [LICENSE](LICENSE).
