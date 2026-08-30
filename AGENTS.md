# AGENTS.md — {{PROJECT_NAME}}

Canonical, provider-neutral instructions for ANY coding agent or LLM working in this repo
(Claude Code, OpenAI Codex, Cursor, Gemini, GitHub Copilot, Windsurf, Cline, aider, …).
If you are Claude Code, `CLAUDE.md` imports this file — read it as your hub.

The tool-native files (`.cursor/rules/`, `.clinerules/`, `.windsurf/rules/`,
`.github/copilot-instructions.md`, `GEMINI.md`, `CONVENTIONS.md`) are **generated** and
**self-contained**: `scripts/sync-agents.sh` inlines the `MIRROR` block below (the universal preamble)
followed by the full body of every `.claude/rules/*.md` module, so each tool gets the COMPLETE ruleset
from its own native file — never a pointer it cannot follow. This file is self-contained too: the same
rule bodies are inlined at the bottom, between the `PANOPLY:RULES` markers, for AGENTS.md-native tools
(Codex, …) that cannot follow `@`-imports. Do not edit the generated files or the marked block; edit
`AGENTS.md` (preamble) or `.claude/rules/*.md` (bodies) and run `sh scripts/sync-agents.sh`.

## Start here — onboarding contract (read in this order, before writing anything)

This is the exact order a new agent reads, whatever tool you are. It maps 1:1 to the four things you
must do: **find the context**, **not break anything**, **carry existing work forward**, **make new
work fit**.

1. **This file (`AGENTS.md`)** — the map and the non-negotiables below.
2. **`docs/claude/roadmap.md`** — the overall plan: the initiatives this project is committed to, in
   Now / Next / Later. This is the strategic arc — what we are building and where we are in it.
3. **`docs/claude/in-progress.md`** — the tactical queue that rolls up into the roadmap: what is in
   flight, what is next, and the *exact next step* to resume cold. **Carry these initiatives forward;
   do NOT open a parallel track for work already queued here.**
4. **The running worklog** — `docs/claude/worklog.md`, or this repo's `CHANGELOG.md` / `HISTORY.md`
   `[Unreleased]` section if it keeps one instead. Skim what landed recently. You will append one line
   here in the same change as your work (see Non-negotiables).
5. **`CLAUDE.md`** — project overview, tech stack, the real command table, and the directory map.
   Plain markdown; read it even if you are not Claude. It lists the rule modules as `@.claude/rules/*.md`.
6. **`.claude/rules/clean-architecture.md`** — the architecture premise every change obeys (below).
7. **The `.claude/rules/` module governing what you are about to touch** — `testing.md`, `database.md`,
   `api-design.md`, `frontend.md`, `error-handling.md`, etc. Plain markdown; open the one that applies.
8. **`docs/claude/architecture.md`** and **`key-patterns.md`** — decisions and gotchas, so you extend
   the design instead of re-litigating it.

Then: **propose before you edit**, **keep the roadmap/plan/worklog current in the SAME change as the
work**, and **verify (test + typecheck + lint + the architecture-boundary check) before you commit.**
Full doctrine: `.claude/rules/workflow.md` and `.claude/rules/documentation.md`.

In a monorepo the closest `AGENTS.md` to the file you are editing wins; this root file is the default.

## Non-negotiables

- **Clean Architecture is the premise of all code here.** Dependencies point inward only; business
  rules never import a framework, ORM, HTTP client, or vendor SDK; every external concern sits behind
  a port with its adapter at the edge; one composition root wires them. Name the layers your change
  touches before you write it. Full rule + review checklist: `.claude/rules/clean-architecture.md`.
- **Plan before code; verify before commit.** No multi-file change without a persisted plan under
  `docs/claude/`; no commit without a green test / typecheck / lint run in the same session.
- **The plan and worklog are never stale — and this is enforced, not just asked.** Every change
  updates `docs/claude/in-progress.md` (its status + Next step), appends one line to the running
  worklog, and moves the `roadmap.md` initiative when it starts or ships — all in the same commit as
  the code. Shipped-but-unlogged counts as not done. **The landing gate `scripts/check-docs.sh` fails
  any commit that changes code but not the worklog in the same commit** — it runs in required CI, so
  no agent in any tool can land a code change without its doc update. Full doctrine:
  `.claude/rules/documentation.md`.

## Architecture is non-negotiable

This project is built on Clean Architecture. Every change — planned or written, by any human or AI
agent, in any tool — obeys one rule: **source-code dependencies point inward only.** Business rules
(Entities / Domain, Use Cases / Application) never import a framework, ORM, HTTP client, UI library,
vendor SDK, or environment/config. Every external concern sits behind a **port** (an interface
declared in the use-case layer) implemented by an **adapter** at the edge.

- You **MUST** place each new piece in one of the four layers and keep its imports pointing inward.
  The layer→directory map is in `.claude/rules/clean-architecture.md` → "This project's layers".
- You **MUST NOT** put a business rule in a controller, route handler, UI component, database trigger,
  or ORM lifecycle hook.
- You **MUST NOT** serialize a domain entity to the wire or persist one by ORM reflection — map to a
  DTO at the boundary.
- Before you build, state the layers you touch and the ports you add (the plan template forces this).
  If a new dependency would point outward, stop and raise it before writing the code.
- This is enforced **mechanically** where the project has wired it: the architecture-boundary check in
  `CLAUDE.md` → Key Commands (a dependency-cruiser / import-linter / ArchUnit config) fails the build
  on an outward import. That check binds every contributor equally **only once it runs in required
  CI** — a client-side pre-commit hook is skippable with `--no-verify`, so CI is the plane that
  actually holds against a non-Claude agent. See "Enforcement — the honest version" below.

<!-- MIRROR:start — this block is copied verbatim into every tool-native file by scripts/sync-agents.sh. Edit here only; it is the "if you read nothing else" contract for tools that do not open AGENTS.md. -->
## If you read nothing else in this repo

**Before writing anything, open `AGENTS.md` at the repo root and read it fully.** The short version:

- **Read, in order:** `docs/claude/roadmap.md` (the plan) → `docs/claude/in-progress.md` (the queue +
  the exact next step) → the running worklog (`docs/claude/worklog.md` or the `CHANGELOG`
  `[Unreleased]` section) → `CLAUDE.md` (stack + commands) → the `.claude/rules/` module for what you
  touch.
- **Carry existing work forward.** The top of `in-progress.md` is the live task with its next step —
  continue it; do NOT open a parallel track for work already queued.
- **Keep the plan and worklog current in the SAME change as the code.** Shipped-but-unlogged = not done.
- **Clean Architecture is mandatory:** dependencies point inward only; business rules import no
  framework / ORM / HTTP / SDK; external concerns sit behind a port with an edge adapter.

### MUST NOT — hard guardrails

For Claude Code these are enforced by `.claude/settings.json`. **That permission gate binds only
Claude** — for every other tool these are advisory doctrine, and the only cross-tool enforcement is
whatever the repo has wired server-side (branch protection + required CI). Honor them as absolute:

- **NEVER** force-push, `git reset --hard` a shared branch, delete branches/tags, or rewrite published
  history.
- **NEVER** run a destructive database command: `db:push` / `db:reset` / `db:drop`, `prisma db push`,
  `prisma migrate reset`, `drizzle-kit push`, `alembic downgrade base`, `supabase db reset`, or raw
  `DROP`. Migrations are forward-only and reviewed.
- **NEVER** pipe the network to a shell (`curl … | bash`, `iwr … | iex`) or install from an untrusted
  source.
- **NEVER** read or print secrets (`.env`, `*.pem`, `id_rsa`, `credentials.json`), and never put a
  credential in a git remote URL or a commit.
- **NEVER** publish a package or deploy (`npm publish`, `cargo publish`, `docker push`, …) unless the
  task explicitly asks and a human has approved.
- **ALWAYS** stop and get human approval before any change that is destructive, irreversible, or
  outside the approved scope.
<!-- MIRROR:end -->

## Where everything lives

| You need | Read |
|---|---|
| The overall plan (initiatives) | `docs/claude/roadmap.md` |
| What to work on now | `docs/claude/in-progress.md` |
| What landed recently | `docs/claude/worklog.md` (or `CHANGELOG.md` `[Unreleased]`) |
| How to work (process) | `.claude/rules/workflow.md`, `quality-bar.md`, `git-workflow.md`, `documentation.md` |
| Architecture premise | `.claude/rules/clean-architecture.md` |
| Code / tests / errors | `.claude/rules/code-style.md`, `testing.md`, `error-handling.md` |
| Data & interfaces | `.claude/rules/database.md`, `data-modeling.md`, `api-design.md` |
| Stack, commands, structure | `CLAUDE.md` |
| Decisions & gotchas | `docs/claude/architecture.md`, `key-patterns.md` |

Deep rules are **not copied here** — they live once under `.claude/rules/` and are plain markdown any
agent can open. This file is the index, the onboarding order, and the guardrail; the modules are the depth.

## Enforcement — the honest version

Be clear-eyed about what actually stops a bad change, because half of these tools have no permission
model at all:

- **`.claude/settings.json`** is a real gate, but it binds **only Claude Code**. It does nothing to a
  Cursor, Codex, Copilot, Windsurf, Cline, or aider agent.
- For every other tool, the guardrails above are **doc-level MUST-NOT prose** — always in context (the
  `MIRROR` block is mirrored into each tool's native rules file), but advisory. A determined or
  confused agent can still run the command.
- **The only cross-tool enforcement is server-side:** branch protection on the default branch (blocks
  force-push and direct pushes no matter who typed them) and **required CI status checks** (test,
  typecheck, lint, the architecture-boundary check, secret scan) that block a merge regardless of tool.
  This repo ships a starter CI workflow at `scripts/templates/ci-verify.yml` and a pre-commit sample
  at `scripts/templates/pre-commit`; **turn them on and mark the CI checks required** — until you do,
  the only backstop against a non-Claude agent is the prose above. Do not assume a gate you have not
  wired.

## The rules, in full — inlined for AGENTS.md-native tools

The complete text of every `.claude/rules/` module is reproduced below by `scripts/sync-agents.sh`, so a
tool that reads AGENTS.md but cannot follow `CLAUDE.md`'s `@`-imports (Codex and others) still gets the
entire ruleset from this one file. The bodies live once under `.claude/rules/`; this block is a generated
rendering of them. **Do not edit between the markers** — edit the modules and re-run `sh
scripts/sync-agents.sh` (`--check` fails CI if this block drifts).

<!-- PANOPLY:RULES:BEGIN — generated from .claude/rules/*.md by scripts/sync-agents.sh. Edit the modules, not here. -->

# Clean Architecture

> **Applies when:** always — this is the premise of every coding effort in this project, and the module every other rules module inherits from.
> **Delete this file (and its `@` import in `CLAUDE.md`) if:** never. Adapt the directory map below to the project instead.

## The premise

Business rules outlive every framework choice. The web framework, the ORM, the database, the UI library, and the vendor APIs in this repo will all be replaced, rewritten, or upgraded on someone else's schedule; the rules describing what this system actually does will not. So the core of this codebase depends on none of them. A core that imports its framework cannot be tested without booting infrastructure, cannot be reasoned about without knowing that framework's lifecycle, and cannot be migrated off it without a rewrite — which is why "we will clean it up later" never happens: the coupling grows faster than the cleanup. Dependency direction is not decoration. It is the single property that keeps tests fast, changes local, and rewrites optional. Follow it by default; justify any exception in the change description, before you write it.

## The four layers

Innermost to outermost. **The Dependency Rule**: source-code dependencies point inward only — inner layers know nothing about outer ones.

| Layer | What belongs in it | Forbidden in it | The test that proves you got it right |
| --- | --- | --- | --- |
| **Entities / Domain** | Business objects and their invariants, value types, pure domain calculations and policies | Any import from an outer layer: ORM base classes, decorators/annotations, HTTP, files, network, clock, random, env | It compiles and its tests pass with every framework, driver, and network dependency uninstalled |
| **Use Cases / Application** | One unit per application operation; orchestration, authorization decisions, transaction boundaries; the **ports** (interfaces) the operation needs | Knowledge of HTTP, SQL, ORM types, queue payload formats, UI concepts, or which vendor implements a port | Every test runs against in-memory fakes of its ports — no container, server, database, or network |
| **Interface Adapters** | Controllers/handlers, presenters and view models, port implementations (repositories, gateways), mappers, DTOs | Business rules; any decision that would change if the business changed while the protocol stayed the same | Deleting this layer would lose no business rule — only translation and wiring |
| **Frameworks & Drivers** | The web framework, ORM and migrations, database, broker, cache, vendor SDKs, UI framework, config, the composition root that wires everything | Anything you could not replace by writing a new adapter | Swapping the vendor produces a diff confined to this layer and its adapters — no entity or use-case file appears in it |

**Details** — the database, the ORM, the web framework, the UI, the message broker, and every third-party API — are outermost, replaceable, and never depended on by the core. Naming one of them in an inner-layer file is the defect.

## The Dependency Rule in practice

How it actually gets violated, and the mechanical fix. Each of these is a real pattern, not a hypothetical.

| Violation as it appears in code | Mechanical fix |
| --- | --- |
| A use case imports an ORM model, entity class, or query builder | Declare a port in the use-case layer taking and returning domain types; implement it as an adapter; inject it at the composition root. Persistence stays behind the port. |
| A domain type carries a framework decorator or annotation (`@Entity`, `@Column`, a validation-library schema, serialization attributes) | Keep the domain type plain. Define a separate persistence/serialization model in the outer layer plus a mapper. A decorator is an import — it is a dependency pointing outward. |
| A use case returns an HTTP response, a status code, or a serialized envelope | Return a plain domain value or an application-level result type; let the controller translate it. A use case that knows about `404` cannot be reused by a job, a CLI, or another service. |
| Business logic in a controller or route handler (`if (user.plan === 'pro' && seats > 5)`) | Move the condition into an entity or use case. The controller is left parsing input, calling one use case, and rendering output. |
| Business logic in a UI component (pricing math, eligibility, state-machine transitions) | Move it into the domain layer. In a client-server product the authoritative copy lives server-side behind the API — the client may mirror it for instant feedback, but the server decides (see `frontend.md`). In a client-only app, move it into a plain domain module and call that from the component. Either way the rule never lives inline in a component or hook. |
| Business logic in a database trigger, stored procedure, or ORM lifecycle hook | Move the rule into the domain, where it is visible in code review, unit-testable, and versioned with the code it constrains. Triggers and hooks fire invisibly and cannot be reasoned about locally. |
| An inner-layer file reads config or environment variables | Pass the value in as a parameter, or behind a port, from the composition root. Reading env is I/O, and it is the usual reason a "pure" test needs a `.env` file. |

## Where things go

Answer in order, stop at the first yes. This should take under 30 seconds.

1. Would this code change because the **business** changed its rules, even on an identical stack? → **Entities / Domain**.
2. Does it describe one complete application operation — sequencing steps, deciding who may do it, marking a transaction boundary? → **Use Cases / Application**.
3. Does it exist only to translate between the outside world and the core — parse a request, shape a response, map a row, call a vendor? → **Interface Adapters**.
4. Would it change because a vendor, framework, or library version changed? → **Frameworks & Drivers**.

Sharpest heuristics, for when the four questions tie:

- Changes when the business changes → inner. Changes when a vendor or framework changes → outer. **Both** → it is two pieces of code wearing one name; split it at that seam first, then place each half.
- **If you cannot test it without booting infrastructure, it is in the wrong layer or it is missing a port.** No third option.
- Torn between two adjacent layers: place it inward only if it is expressed entirely in domain terms. Otherwise outward — moving code inward later is mechanical, moving it outward means untangling everything that started depending on it.

## Boundary crossing

- Data crossing a boundary is a **DTO**: plain data, no behavior, no framework types, in both directions. Domain objects stay inside.
- **Never serialize a domain entity directly to the wire.** The wire shape is a published contract with its own compatibility rules; the domain shape changes whenever a business rule does. Couple them and every internal rename becomes a breaking API change, and every private field leaks to clients. Map explicitly in the adapter.
- **Never let an ORM persist a domain entity by reflection.** Reflection mapping forces the schema to mirror the object graph and drags lazy-loading, proxies, and identity-map semantics into domain code — after which the domain cannot change without a migration. Define a persistence model in the outer layer and map to it.
- Mappers live in the outer layer, always. The inner layer must not know the shape it is mapped into; if it does, the dependency has already reversed.
- **Validation splits across the boundary.** The adapter validates *shape and format* — required fields, parseable types, well-formed identifiers — and rejects with a protocol error. The entity or use case enforces *invariants and business rules* — the ones that must hold no matter which client called. Never let the outer check substitute for the inner one: every other entrypoint (job, CLI, test, another service) skips it.
- Construct entities only through a constructor or factory that enforces their invariants, so an invalid instance cannot exist for other code to find.

## Pragmatism guardrails

Clean Architecture is a dependency discipline, not a file-count competition. The following are cargo cult, and this file does not ask for them:

- **Do not create a port with exactly one implementation that will never have a second, purely for symmetry.** A port earns its place when it crosses an I/O or process boundary, needs a test double, or has a plausible second implementation. A pure function needs no interface — call it.
- **Do not add a mapper when the shapes are identical and stable** and the inner type carries no framework dependency. Add it the moment the shapes diverge, or the outer shape becomes a published contract.
- **Do not split a small project into four physical top-level directories** when a lighter arrangement preserves the direction. One folder per feature with domain, ports, and adapters separated inside it is fully compliant.
- **Do not add a use case that only forwards to a repository** with no rule, decision, or transaction. For a pure read with no business rule, a query adapter may serve a read model directly — until a rule appears, at which point it moves inward.
- **Do not demand a separate persistence model** in a project whose domain has no invariants worth protecting. Small CRUD is allowed to let one model serve both — until the first real rule shows up, then split.

**The invariant that actually matters is the dependency direction.** Folder layout, file counts, and naming ceremonies are means to it, not the goal. A change may not be rejected in review for "not enough layers"; it must be rejected for a dependency pointing outward.

**The one rule pragmatism never overrides: never let a shortcut point a dependency outward.** Skipping a port, a mapper, or a directory is a judgement call you can revisit cheaply. Making an inner layer import an outer one is the failure this whole file exists to prevent — it is not a shortcut, it is the bug, and it is the thing that will not be cheap to revisit.

<!-- MODULE:project-layers — the adapt command fills this map from repo inspection. KEEP always; replace every {{TOKEN}} with this project's real directory, then delete the two example layouts below. -->

## This project's layers

| Layer | Directory in this project | Import rule |
| --- | --- | --- |
| Entities / Domain | `{{DOMAIN_DIR}}` | Imports nothing from the three rows below. No framework, ORM, HTTP, or SDK imports at all. |
| Use Cases / Application | `{{USECASE_DIR}}` | Imports `{{DOMAIN_DIR}}` only. Declares its ports here. |
| Interface Adapters | `{{ADAPTER_DIR}}` | Imports the two above. Implements the ports; owns DTOs and mappers. |
| Frameworks & Drivers | `{{INFRA_DIR}}` | May import anything. Nothing imports it except the composition root. |

**Monorepos:** each deployable app gets its own four-row map — duplicate this table per app (a server app and a client app each have their own domain/use-case/adapter split; a shared package is usually inner-layer code for whichever apps import it). Do not force one map across apps whose layers live in different trees.

Two layouts that both satisfy the rule — **illustrations only**, pick whichever fits the project's size:

```
# Illustration A — layered service (larger project, teams working in parallel)
src/domain/           order.ts, money.ts, pricing-policy.ts          -> {{DOMAIN_DIR}}
src/application/      place-order.ts, ports/order-repository.ts      -> {{USECASE_DIR}}
src/adapters/         http/order-controller.ts, persistence/sql-order-repository.ts, mappers/
                                                                     -> {{ADAPTER_DIR}}
src/infrastructure/   server.ts, db-client.ts, migrations/, container.ts
                                                                     -> {{INFRA_DIR}}

# Illustration B — feature-sliced (small project; same dependency rule, fewer directories)
src/features/orders/order.ts          entity + invariants, plain     -> {{DOMAIN_DIR}}
src/features/orders/place-order.ts    use case + port interfaces     -> {{USECASE_DIR}}
src/features/orders/order.http.ts     controller + request/response DTOs
src/features/orders/order.repo.ts     port implementation; the ORM lives here
                                                                     -> {{ADAPTER_DIR}}
src/platform/                         server, db client, config, wiring
                                                                     -> {{INFRA_DIR}}
```

<!-- /MODULE:project-layers -->

<!-- MODULE:arch — KEEP when a dependency-boundary linter exists or will be wired; adapt drops this whole block (and the {{ARCH_CHECK_CMD}} rows in CLAUDE.md and git-workflow.md) on a repo that has none, leaving only the doctrine below. -->
## Enforcement — the gate, not just the checklist

The review checklist below is the human pass. Dependency direction is *also* checked **mechanically**,
so a violation fails a command instead of resting on a reviewer noticing it. This is the one guardrail
that binds every contributor equally — a human, or any AI agent in any tool — but **only once it runs
in required CI**: a client-side pre-commit hook is skippable with `--no-verify` and a non-Claude agent
may never run it, so CI is the plane that actually holds.

- **The tool, per stack (name it, do not hand-roll it):** JS/TS → dependency-cruiser (`forbidden`
  rules); Python → import-linter (`layers` contract); JVM → ArchUnit (`layeredArchitecture()`);
  Go → go-arch-lint or `depguard`; .NET → NetArchTest; Rust → module visibility + `cargo-deny`. Each
  encodes the same table under "This project's layers": no inner layer may import an outer one.
- **When it runs:** `{{ARCH_CHECK_CMD}}` runs in the pre-commit gate beside typecheck and test
  (`git-workflow.md`) and — the binding copy — as a **required** CI check
  (`scripts/templates/ci-verify.yml`). Green is the only passing score; no agent may merge past it red.
- **Report-only ramp for a non-conforming repo:** if the layer map still has `target:` rows (business
  logic in controllers, ORM models imported inward), start the linter in **report-only** mode so the
  violation count is visible without blocking, then flip it to blocking once the count reaches zero.
  This is exactly where the check earns its keep — do not skip it on the messy repos that need it most.
- **Wiring:** the kit NAMES this gate and CHECKS for it (`/audit-claude-setup` Check 6); it does not
  generate a layout-coupled config for you. Use your stack's tool (or the `arch-enforce` skill if you
  have it) to create the config from the filled layer map, then set `{{ARCH_CHECK_CMD}}` to its invocation.
<!-- /MODULE:arch -->

## Review checklist

Run against any diff. Each item is pointable: a reviewer can highlight a line and say "this violates item N."

1. **Import direction.** No file in `{{DOMAIN_DIR}}` imports from `{{USECASE_DIR}}`, `{{ADAPTER_DIR}}`, or `{{INFRA_DIR}}`; no file in `{{USECASE_DIR}}` imports from `{{ADAPTER_DIR}}` or `{{INFRA_DIR}}`. Read the diff's import block first — it is the fastest violation to spot. *Automated by the Enforcement gate above — `{{ARCH_CHECK_CMD}}`, run in pre-commit and required CI.*
2. No framework, ORM, HTTP, SDK, or env import appears in `{{DOMAIN_DIR}}` or `{{USECASE_DIR}}` — including decorators, annotations, and type-only imports, which still bind those layers to a vendor's shape and release cycle.
3. No domain type carries a persistence, validation-library, or serialization annotation.
4. No use case accepts or returns a framework request/response, a status code, or a transport-shaped envelope.
5. Every conditional that encodes a business rule lives in `{{DOMAIN_DIR}}` or `{{USECASE_DIR}}` — not in a controller, a UI component, a database trigger, or an ORM lifecycle hook.
6. Every I/O the core needs sits behind a port declared in `{{USECASE_DIR}}` and implemented in `{{ADAPTER_DIR}}` — including clock, random/ID generation, and outbound HTTP. Those three are I/O, and skipping them is the usual reason a test needs a real timer or network.
7. Every new use case has a test that runs against fakes only — no container, database, server, or network. If it cannot, item 6 was missed.
8. Data crossing a boundary is a DTO, the mapper sits in the outer layer, and no domain entity is serialized to the wire or handed to an ORM's reflection.
9. Validation is on both sides and neither substitutes for the other: shape and format at the adapter, invariants in the entity or use case.
10. Every new port has both a real implementation and a test double, or a one-line reason in the PR for existing. A port with one implementation and no test double is a deletion candidate, not a compliance win.
11. **Swap test.** Name the vendor or framework this change touches, then confirm the diff to replace it would stay inside `{{ADAPTER_DIR}}` and `{{INFRA_DIR}}`. If an entity or use-case file would appear in that diff, the change is not done.

---

# Workflow: Change Approval & Planning

> **Applies when:** always — this is the baseline collaboration protocol for every project.
> **Delete this file (and its `@` import in CLAUDE.md) if:** never. If you disagree with a rule, edit it; do not delete the module.

## Change Approval

- **Describe your proposed changes and get approval before editing code.** State what you plan to change, which files, and why — then stop and wait for confirmation. Editing first and explaining after removes the user's only cheap moment to redirect you.
- **This applies to bug fixes exactly as much as to features.** "It's just a fix" is the most common excuse for skipping approval, and fixes are where wrong assumptions do the most damage.
- **Never assume the root cause. State your hypothesis and let the user confirm or redirect.** Say "I believe X is happening because Y — do you want me to fix it there?" rather than silently fixing what you guessed. The user usually knows something about the system you cannot see from the code, and a confident wrong diagnosis costs a full rewrite.
- **Name the layers the change touches** — Entities/Domain, Use Cases/Application, Interface Adapters, Frameworks & Drivers (see `clean-architecture.md`). A proposal written as a list of file paths hides the one thing worth catching early: which way the new dependencies point.
- **If the change would point a dependency outward, raise it before you write it, not after.** At proposal time it is a sentence and a redesign; once the code exists and works, nobody rewrites working code to fix an import direction, and the violation becomes permanent.
- When you find a second problem while fixing the first, surface it — do not fold it into the current change without asking. Scope creep smuggled into an approved change is unreviewable.

### What counts as trivial (no approval needed)

Proceed directly, and mention what you did afterward, when the change is:

- A typo, comment, or string fix with no behavioral effect.
- A one-line change the user explicitly described and asked you to make.
- Formatting, import ordering, or lint autofixes.
- Adding a log line or assertion to diagnose something, with no production behavior change.
- Any change fully contained in a file you were just asked to write.

Everything else — new files, new dependencies, schema/API/interface changes, anything touching more than one file, anything you would need a paragraph to explain — needs approval first. When in doubt, ask; asking costs one message, a wrong rewrite costs an hour.

This carve-out is itself a setting: a project that chose the **strict** protocol at adapt time deletes the list above, and every change — trivial or not — gets described and approved first.

## Planning Workflow

- **A plan is a roadmap row first, never a new directory.** The moment you start work, add a row to the project's `docs/claude/roadmap.md` (Now/Next/Later) — in the same session, even if that row is the only artifact and the plan dies the same day. A dead roadmap row beats a lost plan. Never create a top-level `<name>-plan/`, `<name>-specs/`, or `scratch_*` plan directory; that scatter is exactly what this rule eliminates. Deeper detail goes in `docs/claude/<area>/<slug>/plan.md` inside the repo, linked from the row.
- **`docs/claude/roadmap.md` is the SINGLE plan doc every agent reads and edits.** There is exactly one per project. Before planning anything, read it; when you plan anything, write there. If you find a plan doc anywhere else — repo root, flat in `docs/claude/`, a stray folder — it is stale by definition: fold it into a roadmap row and archive it under `docs/claude/<area>/completed/` rather than continuing to edit it in place. Two live plan docs means the next agent reads the wrong one. `scripts/check-plan-home.sh` enforces this in CI and pre-commit (`PLAN_HOME_ALLOW` for a legitimate exception, `PLAN_HOME_OFF=1` while adopting a repo with a backlog).

- **Enter plan mode before any non-trivial or multi-step work.** Any feature, milestone, or task spanning more than a couple of files starts with a plan — use the planning tool, not an informal chat summary, so the plan is an artifact rather than a paragraph that scrolls away.
- **ALWAYS persist the plan to a file under `docs/claude/`.** A plan that exists only in chat context dies at the next compaction, and you will silently resume with a different plan than the one that was approved. The file is the source of truth; the chat is not.
  - Copy `docs/claude/_templates/plan.md` as the starting point.
  - Write it into the relevant area folder, not flat in `docs/claude/` — e.g. `docs/claude/<area>/<feature>/plan.md`. See `docs/claude/_templates/feature-area/README.md` for the folder convention.
  - Link the new plan from `docs/claude/in-progress.md` in the same step, or nobody will find it.
- **When a milestone splits into sub-milestones, do not overwrite the parent plan.** Either nest the sub-milestones inline under their parent, or create a sibling file in the same folder and link to it from the parent. The parent plan must stay readable as a high-level overview — that overview is what a future session reads first to reorient, and flattening it into task-level detail destroys it.
- **Re-read the plan file at the start of each milestone.** Do this even if you "remember" the plan; after a compaction your memory of it is a summary of a summary.
- **Update the plan as work completes** — check off finished milestones, and record deviations inline with a `> **Build note:**` line explaining what you found and why the approach changed. Discoveries made during the build are the most valuable content in the file and the first thing lost if you do not write them down.
- If the work turns out to be materially different from the plan, stop and re-plan with the user rather than improvising forward. A plan that no longer matches reality is worse than no plan, because it still looks authoritative.

## Before you propose

The approval you are asking for is only as good as the proposal. Before you describe a change, run
the self-check in `quality-bar.md` — it governs *what* you propose; this file governs *when and how*
you propose it.

## Expert Review (non-trivial changes)

- **Every non-trivial change requires structured expert review before merge.** Trivial changes (per the list above, plus: single file, ≤15 lines added, no schema/API/interface change, or PR labeled `trivial` / commit prefixed `trivial:`) skip this gate.
- **Four default personas must be considered:** Security, Performance, Maintainability, UX. Domain-specific personas may be added per project.
- **Review evidence required (checked by `scripts/check-expert-review.sh` in CI):**
  1. `plan.md` exists for the feature area (persisted under `docs/claude/<area>/...`).
  2. `checklist.md` has ≥1 unchecked item at PR open (proves planning happened).
  3. `adr.md` has a new section since the PR base branch (proves architectural decision recorded).
  4. PR description contains sign-off from ≥2 named personas (e.g., `Security: ✓`, `Performance: LGTM`).
- **Process:** Author drafts plan → opens PR → requests review from relevant personas → each persona comments with sign-off → CI gate passes → merge.
- **Conflict escalation:** If personas disagree on a fundamental trade-off, the ADR records both positions and the decision; the operator (human) breaks ties.
- **No rubber stamps:** A sign-off without reading the diff is a process violation. The adversary-review skill (§16) provides the grading rubric.

---

# Long-Term Quality Bar

> **Applies when:** always — before proposing any approach, and before any structural decision that is hard to reverse.
> **Delete this file (and its `@` import in `CLAUDE.md`) if:** never. This is the rule that stops the easy path from winning by default.

## The self-check

Before proposing an approach, ask yourself, in writing:

> **"Is this the best choice for a production system that will be used for years, or am I choosing the easier path?"**

Answer it honestly in the proposal. If the answer is "this is easier," say so out loud — the user can accept a shortcut they were told about, and cannot accept one they were not.

Then a second question, cheaper to answer and just as revealing:

> **"Which layer does this belong in, and does anything in it point a dependency outward?"**

If you cannot name the layer, you do not yet understand the change well enough to propose it. If the honest answer is "it points outward," that is a design decision — surface it here rather than letting it arrive as an import. See `clean-architecture.md`.

The path of least resistance is not neutral: it spends someone else's time later to save yours now. Prefer the right structure even when it costs more work up front, and when you don't, name the debt you are taking on.

## Flag tradeoffs explicitly

- When a simpler approach trades away scalability, type safety, maintainability, queryability, testability, or an established best practice, **state the tradeoff and give your honest recommendation.** Not a menu with no opinion — a recommendation, with the reason.
- Quantify where you can: what breaks at 10x the data, what a future change would cost, what the migration out looks like. "It might not scale" is unactionable; "this reads the whole table on every request, so it degrades past roughly N rows" is a decision the user can make.
- If you are proposing the cheaper option deliberately (a prototype, a spike, a deadline), say that it is deliberate and note what would have to change to make it permanent.

## Never dismiss an option without evaluating it

- **"Over-engineered" is a conclusion, not an argument.** Do not use it — or "unnecessary", "premature", "YAGNI" — to skip past an option you have not actually evaluated. Cheap dismissal is how the wrong architecture gets chosen without anyone noticing a choice was made.
- Evaluate every viable option on its own merits: queryability, analytics and reporting, extensibility, type safety, testability, operational cost, and the cost of reversing it later.
- Only after that evaluation may you recommend against an option — and then you must say which merit it loses on.
- This applies with equal force to options the user proposed and options you proposed. Do not defend your first idea; evaluate it the same way.

## Present two options and let the user decide

When the decision is genuinely a judgement call, do not decide silently. Present it like this:

1. **Option A** — one line on what it is; what it costs now; what it costs later.
2. **Option B** — same.
3. **What differs that actually matters** — the one or two axes the choice turns on.
4. **Your recommendation, and why.**

Then stop and wait. Do not start implementing either option while the question is open. Two well-drawn options with honest tradeoffs is a better deliverable than a confident single answer that quietly closed off the alternative.

## Applies to

Run the self-check on any of these before writing code:

- **API design** — endpoint shape, payload contracts, versioning, what the server sends versus what the client must fetch.
- **Data modeling** — table and entity structure, normalized rows versus blob/document columns, junction tables versus polymorphic columns, what gets its own status and timestamps.
- **Type-system choices** — shared types versus duplicated ones, unions versus open strings, where the source of truth for a type lives.
- **Component and module architecture** — boundaries, ownership of state, what is generic versus domain-specific, how deep the layering goes.
- **Storage, queue, and integration choices** — anything with a vendor or a schema attached.
- **Dependency direction** — anything that introduces a new port, moves a rule across a layer boundary, or would make an inner layer depend on an outer one (a framework, ORM, vendor SDK, or UI library). Direction is the hardest thing on this list to reverse: by the time it is wrong, working code depends on it being wrong.
- **Anything hard to change later** — if reversing the decision would require a migration, a coordinated deploy, a client update, or touching more than a handful of files, it belongs on this list.

Routine work — a bug fix inside an existing pattern, a copy change, adding a field to an existing shape — does not need the ceremony. If you cannot tell which kind of change you are making, treat it as the structural kind and ask.

## What this rule is not

It is not a licence to gold-plate. It does not authorize building for imagined requirements, adding abstraction layers nobody asked for, or expanding scope beyond the request. The bar is **the right decision at the current scope**, argued honestly — not the largest possible decision.

---

# Git Workflow: Commits, PRs, Branching

> **Applies when:** the project is version-controlled with git and changes land through pull requests.
> **Delete this file (and its `@` import in CLAUDE.md) if:** the project is not in git, or has no PR/review process at all.

## Commits

- Use conventional commit prefixes: `feat:`, `fix:`, `refactor:`, `test:`, `chore:`, `docs:`. They make the history greppable and let release tooling derive changelogs without human curation.
- **Keep commits atomic — one logical change per commit.** A commit that does two things cannot be reverted, cherry-picked, or bisected without dragging the other one along.
- **Do not mix a domain change and an infrastructure change in one commit.** A commit that alters a business rule *and* swaps an adapter, ORM call, or vendor client leaves the reviewer no way to tell which half changed the behaviour — and if it has to be reverted, both halves go. Split them along the layer boundary (see `clean-architecture.md`); the domain commit is the one that needs real scrutiny.
- **Never push directly to `{{DEFAULT_BRANCH}}`.** All work lands via a branch and a PR, so every change has a reviewable diff and a revert point.
- **Remind the user to commit at the end of each feature or milestone** — they forget, and uncommitted work is the one kind of work that a crashed machine or a bad `git checkout` can delete outright.

## Pre-commit gates (both, every time)

- **Run the FULL typecheck before committing: `{{TYPECHECK_CMD}}`.** Every package, unfiltered — do not grep the output, and do not spot-check only the files you changed. A type error in an untouched package that your change broke through a shared type is exactly the failure this catches, and partial checks have shipped broken CI more than once.
- **Run the full test suite before committing: `{{TEST_CMD}}`.** All tests must pass. Do not skip, `.only`, or comment out a failing test to get a commit through — fix the code, or stop and report the failure.
<!-- MODULE:arch -->
- **Run the architecture-boundary check before committing: `{{ARCH_CHECK_CMD}}`.** It fails on any
  import that points outward across a layer boundary (`clean-architecture.md`). A dependency-direction
  violation caught here is a one-line move; caught after the code ships, nobody rewrites working code
  to fix an import direction and the violation becomes permanent. *This local run is convenience, not
  enforcement — it is `--no-verify`-skippable and a non-Claude agent may never run it; the binding
  copy is the same check as a **required CI status** (`scripts/templates/ci-verify.yml`).*
<!-- /MODULE:arch -->
- If a change alters query structure, response shapes, or call ordering, update the corresponding test fixtures and mocks in the same commit — see "Sequentially-consumed mocks go stale" in `testing.md` for the failure mode and how to spot it.
- Both gates run before the commit, not before the push. A local commit you have not verified is a commit you will push at 6pm without rechecking.

## Branching

- **Always branch from an up-to-date `{{DEFAULT_BRANCH}}`.** Fetch first: `git fetch origin && git switch -c <branch> origin/{{DEFAULT_BRANCH}}`. Branching from a stale local copy imports every conflict that landed since you last pulled.
- **Do not branch from another feature branch or an open PR's branch (no stacked PRs) — the default with exactly one exception, below.** PRs are squash-merged, which rewrites the base PR's commits into a single new SHA. The stacked branch still carries the *original* commits, so after the base merges, your branch will conflict with its own already-merged changes — a conflict that looks impossible and wastes an afternoon.
- If new work depends on an unmerged PR, the rule is: wait for it to merge, then branch fresh from `{{DEFAULT_BRANCH}}`. The one exception: you are truly blocked and waiting is not an option — then stack, flag it prominently in the PR description so the reviewer knows the base is moving, and expect to run the recovery below after the base squash-merges.

### Recovery: already stacked on a squash-merged branch

Do not run a plain `git rebase {{DEFAULT_BRANCH}}` — it replays the duplicated commits and recreates every conflict. Drop the old base's commits instead:

```
git fetch origin
git rebase --onto origin/{{DEFAULT_BRANCH}} <old-base-branch-tip>
```

`<old-base-branch-tip>` is the last commit that belonged to the base branch (its SHA before the squash-merge, or `origin/<old-base>` if the ref still exists). Everything after that point replays cleanly onto the new base.

### Before you ship, merge, or delete a branch: prove it carries unmerged work

A branch showing commits "ahead" of `{{DEFAULT_BRANCH}}` is *not* proof it holds unmerged work. A squash-merge collapses the branch's commits into one new SHA on `{{DEFAULT_BRANCH}}` and leaves the original branch behind with its old commits, so `git log` and `git status` keep calling it "ahead" long after every line it changed has landed — the same rewrite behind the stacked-branch trap above. Trust the diff, not the ahead count.

- **Run `git cherry -v {{DEFAULT_BRANCH}} <branch>` before you open a PR, merge, or ship a branch.** A line prefixed `-` is a commit whose change is already present on `{{DEFAULT_BRANCH}}` (an equivalent patch merged); a line prefixed `+` is genuinely unmerged. All `-` means the branch carries nothing new — do not merge it, and do not "resolve" the phantom conflicts a re-merge invents against already-merged code. `git diff {{DEFAULT_BRANCH}}...<branch>` (three dots) is the same verdict from the other side: an empty diff means nothing to ship.
- **Only a branch with `+` lines is work.** Everything else is cleanup, not a merge.
- **Delete a verified-merged branch, but record its tip SHA first so the delete is reversible.** `git rev-parse <branch>` and note the branch name + SHA in the PR or `HISTORY.md`/`CHANGELOG` before deleting — deleting a merged branch loses nothing but the ref, and the ref is the only way back if the check was wrong (`git branch <name> <sha>` restores it). Then delete both ends and prune: `git push origin --delete <branch>`, then `git fetch --prune` so every checkout drops its dead remote-tracking ref.
- **`git branch -d` is a weaker check than `git cherry`, not a stronger one.** For a squash-merged branch `-d` *refuses* ("not fully merged") because git never sees the collapsed SHA as an ancestor. When `git cherry` has already proved the branch is fully merged but `-d` still refuses, re-read the cherry output once, then delete with `git branch -D` — the cherry check is the authority here, not `-d`.

## Keeping branches fresh

- **Rebase open PR branches onto `{{DEFAULT_BRANCH}}` every 1–2 days.** Small, frequent rebases produce one or two trivial conflicts; a week of drift produces a wall of them, and a wall of conflicts is where correct code gets resolved away by accident.
- Rebase before requesting review, so the reviewer reads the diff that will actually merge.
- After rebasing a pushed branch, force-push with `git push --force-with-lease` — never a bare `--force`, which will silently discard a collaborator's commits pushed since your last fetch.

## Repo hygiene & credentials

- **Verify commit identity before the first commit in a fresh clone.** A freshly reset or provisioned machine has empty git identity, so the first commit lands under the wrong author. Before committing in any new clone, confirm `git config user.name` and `git config user.email` match the identity this repo declares it commits under (in `CLAUDE.md`/`AGENTS.md`); set them **repo-locally** (`git config user.email …`, never `--global`) if they do not. The check is portable even though the value is per-project — the author the repo commits under is declared in-repo.
- **Never put a credential in the remote URL, and never commit a secret.** Keep secrets in env or a secret store; keep git auth in a credential helper (`git config credential.helper`, `~/.git-credentials`, or the OS keychain) so the remote stays `https://github.com/<owner>/<repo>.git` — never `https://<user>:<token>@github.com/...`. A token in the URL leaks through `git remote -v`, shell history, CI logs, and the reflog, and removing it does not un-expose it: if one was ever embedded, **rotate it.**
- **The `.claude/settings.json` deny-list binds only Claude Code.** It does nothing to a Cursor,
  Codex, Copilot, Windsurf, Cline, or aider agent. The tool-agnostic guardrail is **server-side**:
  branch protection on `{{DEFAULT_BRANCH}}` (blocks force-push and direct pushes no matter who typed
  them) plus **required status checks** (`scripts/templates/ci-verify.yml`). Turn both on — that is
  what actually stops a non-Claude agent, and the cross-tool `MUST NOT` list in `AGENTS.md` is advisory
  prose until you do.

## Pull requests

- The PR description states what changed and why, and links the plan doc under `docs/claude/` when there is one.
- Keep the PR scoped to the approved change. Unrelated drive-by fixes belong in their own PR, where they can be reviewed on their own merits.
- Never merge your own PR past a failing CI job by re-running it until it goes green — a flaky test is a bug report, not an obstacle.

---

# Documentation & Memory

> **Applies when:** always — this defines where project knowledge lives and how it survives context compaction.
> **Delete this file (and its `@` import in CLAUDE.md) if:** never. If the project keeps its knowledge base elsewhere, retarget the paths rather than dropping the module.

## Two tiers of memory

- **`docs/claude/` — team-shared, committed to git.** Facts about the project that any contributor or agent needs: what is being built now, what shipped, why the architecture is the way it is, and the patterns and gotchas that cost someone a day to learn. If a teammate would benefit, it goes here.
- **`~/.claude/` — personal, never committed.** Individual preferences, machine-local setup, per-user workflow habits. Keep it out of `docs/claude/`, because personal preference presented as project doctrine misleads everyone else on the team.

The distinction is not about secrecy, it is about durability: committed docs are versioned alongside the code they describe, so they can be reviewed, corrected, and blamed.

## Read order (start here, in this order)

1. **`docs/claude/in-progress.d/`** — the queue, ONE FILE PER TASK, each carrying that task's status and its exact next step. Always read this first; it tells you what the current work actually is, which is the one thing a fresh context window cannot infer from the code. `docs/claude/in-progress.md` is a GENERATED table view of the directory — read it if the repo renders one, but never edit it.
2. **`docs/claude/architecture.md`** — the decisions and their reasoning, so you extend the design instead of re-litigating it.
3. **`docs/claude/key-patterns.md`** — conventions, gotchas, and testing practice, so your code matches what is already there.
4. **`docs/claude/infrastructure.md`** — deploy pipeline, hosting, data stores, secrets, background jobs. Read before touching anything that runs outside the dev machine.
5. **`docs/claude/completed-features.md`** — what already exists, so you do not rebuild it.
6. **The relevant area folder** (e.g. `docs/claude/<area>/…`) — active plans and research for the feature you are working on.

Read the specific files that bear on the task, not all of them every time. But never start non-trivial work without at least `in-progress.d/` and the area folder for the thing you are changing.

## The always-current plan & worklog

Four artifacts, four altitudes. Each owns ONE fact-granularity; nothing restates another, so nothing
drifts. This is the anti-redundancy contract — keep to it and the logs cannot contradict each other.

| Altitude | File | Owns | Granularity |
|---|---|---|---|
| Strategic | `docs/claude/roadmap.md` | Initiatives, their band (Now/Next/Later), links down | one initiative |
| Tactical | `docs/claude/in-progress.d/<slug>.md` (one file per task) | The active queue, blocked, parked, per-task Next step | one task/feature |
| Continuous | `docs/claude/worklog.md` **or** the repo's `CHANGELOG`/`HISTORY` `[Unreleased]` | What actually landed | one change |
| Durable | `docs/claude/completed-features.md` | What now exists + its archived plan path | one shipped feature |

A fifth surface, `CHANGELOG.md`/`HISTORY.md` release notes, is **user-facing and derived** — curated
from the worklog at release time, not maintained per-change in parallel. If the repo uses its
`[Unreleased]` section AS the running worklog, there is no separate `worklog.md` (one running log, never two).

### The same-change update contract (every agent, every provider)

In the SAME commit that lands work — Claude, Codex, Cursor, or any other tool:

1. **Append one worklog line** (to `worklog.md`, or the `[Unreleased]` section) — what changed, where.
2. **Write your task's own fragment** — `docs/claude/in-progress.d/<slug>.md` — with its status and its
   Next-step handoff, or **delete the fragment** on ship. Never edit a shared table: the queue is one file
   per task precisely so two open PRs cannot collide on it, the same reason the worklog is one file per
   change. `docs/claude/in-progress.md` is a generated view — do not edit it, and do not commit it.
3. **On ship**, additionally: add the `completed-features.md` entry, MOVE the `roadmap.md` initiative
   (to Shipped if this was its last plan), and archive the plan folder.
4. **On a new or reprioritised initiative**: add or move its `roadmap.md` row.

This contract is plain-markdown, enforced by review and `/audit-claude-setup` — never a Claude-only
permission gate, so it binds a non-Claude agent exactly as much as a Claude one. It is mirrored into
`AGENTS.md` so every tool reads it. **Shipped-but-unlogged counts as not done** (see below).

### The queue is the ONLY backlog — autonomous drivers included

A project has exactly one answer to "what is next", and it is this directory. An agent that keeps its
own private list — an untracked `TASKS.md`, a session database, a scratch file — has created a second
backlog that nobody else can see, and within a day the two disagree about what is done.

So the fragment is written to be **driven, not just read**. Frontmatter carries what a driver needs;
the body carries what a human needs:

```markdown
---
id: <slug>
status: open | in-progress | blocked | done
order: <int>            # optional; ties break by filename
req: <request-id>       # optional; set by a request-scoped seed
risk: operator-confirm  # optional; data-loss or irreversible-prod work, never auto-executed
---

<what the task is>

**Next step:** <the exact next action — the file to open, the command to run, the blocker>
```

`status` is the queue state (a `- [ ]` checkbox by another name). `risk:` is a halt flag: a driver
stops and asks rather than executing it. **Next step** is the handoff a cold session resumes from, and
it is the one line always worth writing — the person who needs it cannot reconstruct where you stopped
from the code alone.

This is the same contract Phalanx's autonomous loop adopted in its ADR-0004, so a task seeded by the
loop and a task written by hand are the same file. A committed queue is also the only kind a reviewer,
a diff, or a non-Claude agent can see at all.

### The landing gate — mechanical enforcement

The contract's deterministic core is enforced by `scripts/check-docs.sh`, which fails any commit that
changes a non-markdown file (source, config, schema, scripts, CI) but not the worklog target in the
same commit. It runs in required CI (`scripts/templates/ci-verify.yml`) and the pre-commit hook, so it
binds every agent in every tool — the provider-neutral floor. The gate enforces **presence**, not
**correctness**: a vague or wrong worklog line passes. Correctness is a review problem, not an
automation problem — the honest limit of any git-native kit. The worklog target is auto-detected
(`CHANGELOG.md`/`HISTORY.md` `[Unreleased]`, else `docs/claude/worklog.md`), overridable via
`DOCS_WORKLOG`.

## When to write

- **When a plan is made** — persist it to a file under the area folder, from `docs/claude/_templates/plan.md`, and link it from your task's `in-progress.d/` fragment. Plans that live only in chat are erased by compaction.
- **During the build, at the moment of discovery** — when reality contradicts the plan, record it inline with a `> **Build note:**` line. Written later, it is written wrong; written never, the next person rediscovers it the expensive way.
- **When you pause or hand off** — before you stop, write the *exact next action* where the next session looks first: the **Next step** line of your task's `in-progress.d/` fragment, or the `Next step` line of the plan doc for a multi-session feature. Not a topic ("continue the auth work") — the file to open, the function to change, the command to run, the blocker. A cold session resumes from this and nothing else, so it is the one note always worth writing: the person who needs it is not you, and cannot reconstruct where you stopped from the code alone.
- **When a decision is made that a future reader would otherwise question** — add an ADR entry to `architecture.md`. The trigger is "someone will wonder why we did this," not "this was hard."
- **Always ADR-worthy: anything that moves a layer boundary or introduces a port.** A new port and the adapter behind it, a rule relocated between layers, a Detail swapped out (database, framework, vendor), or a deliberate decision to let one layer know about another. These are precisely what `architecture.md` exists for: the reasoning is invisible in the diff six months later, so without the entry the next person re-litigates a decision that was already made carefully. See `clean-architecture.md`.
- **When you get burned by a non-obvious behavior** — add it to `key-patterns.md` as a gotcha, with the symptom, not just the fix. The next person will arrive with the symptom.
- **When infrastructure changes** — update `infrastructure.md` in the same PR as the change. Infra docs that lag the infra are worse than none, because they are trusted.

Update the doc in the same PR as the code it describes. A "docs pass later" never happens. **Shipped-but-unlogged counts as not done:** if it is live and the log does not show it, the task is unfinished — finish it by writing the record. The first time the log lags reality, every reader stops trusting it and re-reads the code instead, which is the exact cost this whole file exists to avoid.

## When to archive

After a feature is tested and signed off:

1. Move its entire folder — plan, research, references, everything — into that area's `completed/` subfolder.
2. **Rename the files to describe what shipped**, not generic `plan.md`. A folder of six files named `plan.md` is unsearchable.
3. Add an entry to `completed-features.md`: what shipped, when, and the archived path.
4. Delete the task's `in-progress.d/` fragment.
5. Update any closed issue or milestone descriptions that pointed at the old paths.

Archive, do not delete. The reasoning behind a shipped feature is the context for the next change to it.

## Hygiene

- One fact, one home. If something belongs in `architecture.md`, do not also paste it into a plan file — copies drift, and a reader cannot tell which copy is current.
- **`completed-features.md` is the feature narrative, not a changelog.** It records what a user or
  caller can now do, plus the archived plan path. If the repo keeps a `CHANGELOG.md`/`HISTORY.md`,
  that stays the release/commit line; `completed-features.md` may reference a release but never
  restates the commit log. One fact, one home — across both files, and across the four altitudes above.
- Correct stale docs on sight. Finding an out-of-date statement and leaving it there makes you the reason the next person trusts it.
- Keep entries short and dated. These files are read under context pressure; a wall of prose gets skimmed and misread.

---

# Code Style & Patterns

> **Applies when:** always — any project in which Claude reads, writes, or edits source code.
> **Delete this file (and its `@` import in `CLAUDE.md`) if:** never. Trim individual rules instead.

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

## Project conventions (filled in by `/adapt-claude-setup`)

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

---

# Testing

> **Applies when:** the project has an automated test suite, or is about to get one.
> **Delete this file (and its `@` import in `CLAUDE.md`) if:** the project has no test runner and none is planned.

## Testability is a design signal, not a fixture problem

- **Domain and use-case logic must be testable with no database, no HTTP, and no framework boot.** Construct the thing, call it, assert the result. This is the single most reliable check that the Dependency Rule held (see `clean-architecture.md`) — you cannot fake it, because a rule that reaches outward simply will not run without the outer layer.
- **If a test of a business rule needs a live schema, a running server, or the framework's test harness, that is a design defect the test is reporting.** Fix the design — move the rule inward, put a port where the reach-out is — rather than adding the fixture that makes the symptom go away. The fixture is cheaper today and is the reason the suite is slow in a year.
- Say it out loud when you hit one. "This needed a database to test, so I extracted a port" is a finding worth reviewing; silently adding infrastructure to a unit test is not.

## The pyramid maps onto the layers

- **Wide, fast base — Entities/Domain and Use Cases/Application.** Pure in-process tests, no I/O, milliseconds each. Most tests live here because most behaviour should. These are the tests you can afford to run after every edit.
- **Middle band — Interface Adapters and Frameworks & Drivers.** Test each adapter against the real thing it adapts: a real database for a repository, a real round-trip for an HTTP client, the real serializer for a mapper. An adapter tested against a mock of its own dependency asserts nothing except that you wrote the mock to match your assumption.
- **Thin top — end-to-end.** A handful of paths proving the wiring holds. If you find you need many end-to-end tests before you feel safe, that is evidence business rules are living in the outer layers, where only an end-to-end test can reach them.

## Baseline

- Write unit tests for all business logic: validation, data transformations, calculations, state machines, permission checks, formatting. Logic without a test is a behaviour nobody can change safely later.
- **Run `{{TEST_CMD}}` after every change**, not just at the end of a task. A failure found one edit later is a two-minute fix; found ten edits later it is a bisect.
- If tests fail, fix the code until they pass before moving on. Report the failure — never continue building on a red suite.
- **Never skip, `.only`, comment out, or delete a failing test to get green.** A skipped test is an untested behaviour plus a false signal, which is worse than no test. If a test is genuinely obsolete because the behaviour was removed, delete it in the same change that removes the behaviour, and say so.
- Do not filter or spot-check the run. Run the full suite, unfiltered, before committing.

<!-- MODULE:api — KEEP IF the project exposes endpoints (HTTP routes, RPC handlers, GraphQL resolvers, queue consumers, CLI commands). DELETE otherwise. -->

## Enforced endpoint test coverage

Every endpoint must have a test, and CI must be the thing that says so. Reviewers forget; a job does not.

> **If the enforcement machinery below does not exist in this project yet** (no check script, no allowlist), it is the target state, not a description of current CI — the adapt setup offers to scaffold it (~30 lines walking the route manifest). Until it exists, follow rules 1–3 by discipline and say so in PRs; do not assert CI behavior that is not wired.

**1. Mirror the source tree in the test tree.** For an endpoint at `{{ENDPOINT_SRC_DIR}}/<path>/<name>.<ext>`, its test lives at `{{TEST_DIR}}/<path>/` under the project's test-discovery naming convention — suffix style (`<name>.test.<ext>`) or prefix style (`test_<name>.<ext>`), whichever the runner actually collects. A mechanical mapping means the coverage check needs no configuration and no judgement call about where a test "should" go.

**2. Detect endpoints exactly, not by heuristic.** Derive the endpoint list from the same manifest the application itself uses — the router registration file, the route table, the handler index. Deriving it from filename patterns produces both false positives and, worse, silent false negatives.

**3. New endpoint and its test ship in the SAME change.** A separate follow-up PR for tests is never written. CI fails the change if an endpoint file has no matching test file, and the error message names the exact missing path so the fix is obvious.

**4. Legacy gaps live in a shrink-only allowlist.** Endpoints that predate this rule are listed in `scripts/endpoint-test-allowlist.yaml` (one path per line, no wildcards).
   - **CI refuses net-new entries.** The check compares the allowlist against the default branch's version and fails if it grew. The only direction it moves is shorter.
   - **Touching an allowlisted file means writing its test in the same change and deleting its allowlist entry.** Also enforced in CI. This turns every visit to legacy code into a small, permanent payment against the debt, instead of a project nobody schedules.
   - Never add an entry to unblock yourself. If you believe an exception is warranted, stop and ask the user.

**5. Run the check locally before pushing:** `{{COVERAGE_CHECK_CMD}}`. Discovering this in CI wastes a full pipeline cycle.

## What an endpoint test asserts

- Success status code and the exact response shape (field names, types, nesting).
- Each validation failure path and the status/error body it produces.
- Not-found and forbidden paths for any resource looked up by id.
- Pagination, filtering, and sorting parameters if the endpoint accepts them.

<!-- /MODULE:api -->

## Mocking

<!-- MODULE:api — KEEP IF the project exposes endpoints. DELETE otherwise. -->
- **Mock the authentication/authorization middleware to inject a fixed test user.** Endpoint tests exist to test the endpoint; re-testing auth in every endpoint file makes each test slower, flakier, and coupled to the auth implementation. Test auth once, in its own suite.
<!-- /MODULE:api -->
- **Inject a fake through the port rather than patching a module.** The data layer stays out of the test — no live database, service, or network — because the use case receives its repository/gateway as a dependency and the test hands it an in-memory implementation. Real dependencies make tests order-dependent, environment-dependent, and slow, and they fail for reasons that have nothing to do with the change under review.
- Injection beats patching for a concrete reason: a patch keyed on a module path breaks the moment someone moves the file, and it silently stops patching anything if the path is wrong, while a constructor or parameter argument is checked by the compiler and cannot miss.
- Mock at the boundary the code actually calls (the client module, the repository), not deeper. Mocking internals couples the test to implementation details and it breaks on every refactor. **If there is no port to inject at, that is a finding — record it.** When the code is yours to change in this same effort, add the port. When you are testing existing conventionally-structured code, patching the module at the boundary it calls is an acceptable interim — note the missing port rather than blocking the test on an architecture refactor nobody approved.

### Sequentially-consumed mocks go stale — watch for this

Many mocking styles queue results and hand them out **in call order**. So when you add a query to an existing parallel batch (a `Promise.all`, a concurrent fetch group, a transaction block), the queued mock results shift by one and every downstream assertion is now reading the wrong row.

- After changing the number or order of calls in a batch, **update the mock push order in every affected test file** in the same change.
- The failure mode is silent: tests can still pass while asserting against the wrong data. If a test keeps passing after you changed the query it covers, treat that as a red flag and verify the mock alignment by hand.
- Prefer mocks keyed by argument over positional queues where the framework allows it — they survive reordering.

## Before you commit

- Full test run, unfiltered: `{{TEST_CMD}}`.
<!-- MODULE:api — KEEP IF the project exposes endpoints. DELETE otherwise. -->
- Endpoint coverage check: `{{COVERAGE_CHECK_CMD}}`.
<!-- /MODULE:api -->
- Verify assertions match any new response shape — dropped fields, renamed fields, changed types — rather than assuming an untouched test still tests what it claims.

---

# Error Handling

> **Applies when:** always — any project that accepts input, performs I/O, or shows results to a user.
> **Delete this file (and its `@` import in `CLAUDE.md`) if:** never. Trim individual rules instead.

## Validate at the boundaries

- Validate every input at the point it enters the system: request params, body, query strings, headers, message payloads, CLI arguments, file contents, environment variables. Inside the boundary, code is entitled to assume the data is well-formed — that assumption is only safe if the boundary actually enforced it.
- Validate with the project's schema/validator, not with hand-rolled `if` chains. A schema is a single declaration that produces both the runtime check and the type, so the two cannot drift apart.
- Reject unknown or extra fields rather than ignoring them. Silently dropping a misspelled field turns a caller's bug into your bug report.
- Validate and normalize before writing to storage. A bad row outlives the request that created it.

## Wrap the things that can actually fail

- Put `try`/`catch` (or the language's equivalent) around **I/O and external calls**: database queries, HTTP requests to other services, file system access, queue publishes, third-party SDK calls. These fail for reasons your code cannot prevent, so they are the places a handler earns its keep.
- Set an explicit timeout on every outbound network call. Without one, a hung dependency becomes a hung request, then an exhausted pool, then an outage.
- Catch narrowly and rethrow what you cannot handle. A catch block that swallows everything hides bugs that have nothing to do with the failure you were guarding against.
- Never leave an empty catch block. If a failure is genuinely ignorable, log it at debug level and write the one-line reason it is ignorable.

## DON'T over-engineer internal error handling

This counter-rule matters as much as the rules above. Defensive code between your own modules is not free — it adds branches nobody tests, hides real failures behind fallbacks, and trains readers to distrust the type system.

- Trust framework and language guarantees between internal modules. Do not null-check a value the type system already proves is non-null. Do not re-validate *shape and format* that the boundary validator already validated. Do not wrap a pure function in `try`/`catch` because it "might" throw.
- The carve-out that is **not** re-validation: entities and use cases enforcing their own *invariants and business rules* (see the validation split in `clean-architecture.md`). The boundary check protects one entrypoint; the domain check protects every entrypoint — jobs, CLIs, tests, other services — and neither substitutes for the other.
- Do not add fallback values that mask a broken invariant. If an internal call returning nothing means the system is in an impossible state, let it throw — a loud crash with a stack trace is more debuggable than a silent default that propagates wrong data for a week.
- Rule of thumb: handle errors where you can **do** something about them (retry, fall back to a real alternative, surface a message to the user). Everywhere else, let them propagate to the boundary handler.

## Errors belong to the layer that raised them

- **A domain or use-case failure is a domain type, not a framework exception.** A broken business rule raises or returns a named domain error (`InsufficientFunds`, `AlreadyClaimed`) — never the web framework's exception class, never a bare status code. Domain code that knows what `409` means cannot be reused by a job, a CLI, or a second transport without dragging the web framework along.
- **Translation from domain error to transport status code happens in the Interface Adapters layer, and nowhere else.** One mapping in one place, so changing the API's error contract is one edit. A status code chosen deep inside a use case is invisible to that mapping and will drift from it — and nothing will fail until a client notices.
- **A use case must never return or raise an HTTP-shaped thing**: no status codes, no response envelopes, no framework error classes. If you cannot write the failure without naming a transport, the rule is in the wrong layer. See `clean-architecture.md`.

## Consistent, typed error responses

- Return errors in one shape across the whole API, defined once as a shared type and reused by every handler. Ad-hoc error bodies force every client to special-case them.
- The shape carries at minimum: a stable machine-readable code, a human-readable message, and (for validation failures) the offending fields. Clients branch on the code, never on the message text.
- Map failure classes to correct status codes — bad input, unauthenticated, forbidden, not found, conflict, upstream failure, unexpected. Returning success-with-an-error-body defeats every client retry and monitoring rule.
- Never leak stack traces, SQL, internal paths, or upstream provider payloads to the caller. Log those; return the code.

## Log with enough context to debug

- Every logged error includes: what operation was running (route/job/handler name), the identifying inputs (record ids, not full payloads), and the underlying error message and stack. A log line that says only `Error: request failed` costs an hour of bisecting.
- Never log secrets, tokens, passwords, full auth headers, or personal data. Log the id, not the record.
- Log the error where you have the context, once. The same failure logged at four levels of the stack makes the real one harder to find.

## Never fail silently — the strongest rule here

**Every user-facing operation that fails must surface the failure to whoever initiated it, and log it.** In a UI, that means a visible error state; in a headless service, the "user" is the caller, and the failure maps to the typed error response — never a swallowed exception, never success-with-nothing-happened.

<!-- MODULE:frontend — KEEP IF the project renders a user interface. DELETE otherwise. -->
- In the UI this covers API calls, form submissions, auth flows, uploads, background refreshes, optimistic updates, and streamed responses. Visible means the user can tell the operation failed and what to do next: an inline message, an error state on the component, or a toast — not a spinner that never resolves and not a screen that silently keeps stale data.
- A rejected promise with no catch, a catch that only logs, and a loading flag that is never cleared on failure are all the same bug: the user is lied to about the state of their data.
- Optimistic updates must roll back on failure, and say they rolled back. Leaving the optimistic value on screen after the write failed means the user believes something was saved that was not.
<!-- /MODULE:frontend -->
- If a background operation fails and its initiator cannot act on it, it still gets logged with full context — but say plainly in your change description that it is intentionally silent, so the choice is reviewed rather than assumed.

---

# Database & Migrations

> **Applies when:** the project owns a database schema and a migration history.
> **Delete this file (and its `@` import in CLAUDE.md) if:** the project has no database of its own, or only reads from a schema another team owns.

## The database is a Detail

Everything in this file is outer-layer work. The ORM, the driver, and the schema are Frameworks & Drivers; the repository implementations that wrap them are Interface Adapters — replaceable in principle, and never permitted to dictate the shape of a business rule. See `clean-architecture.md`. The migration rules below lose none of their force for being outer-layer: they are how you keep a Detail from taking production down.

- **Repository interfaces are ports owned by the inner layer; the Interface Adapters layer implements them.** The use case declares what it needs (`findActiveOwnedBy`, `save`); the adapter decides how to get it. A repository interface carrying `limit`, `offset`, `include`, or a query-builder object in its signature is the ORM leaking inward — express the need, not the query.
- **Never pass an ORM model or entity inward.** Map rows to domain types in the adapter, at the edge. An ORM object in a use-case signature drags lazy loading, session lifetime, and the vendor's column names into your business rules — and from then on every migration is also a domain change.

## Schema changes

- Make every schema change through a migration. Never edit the database directly — through a GUI, a console, or an ad-hoc `ALTER`. A direct edit exists only on that one machine; the next environment to deploy will not have it, and the schema file will disagree with reality.
- Treat the schema definition file (`{{SCHEMA_FILE}}`) as the single source of truth. Change it first, then generate the migration from it. If the schema file and the database disagree, the schema file is right and the database needs a migration.
- Every new table, column, index, constraint, or enum value requires a generated migration in the same change. A schema edit with no migration file alongside it is an incomplete change.

## NEVER hand-write migration files

- **Always create migrations through the toolchain's generation command, `{{MIGRATE_GEN_CMD}}`. Never author a migration file from scratch.** The failure differs by toolchain but the rule does not: in toolchains that keep journal/snapshot bookkeeping alongside each migration, a from-scratch file has neither, so the migrator cannot see it — it passes review, passes local testing where you ran the SQL yourself, and then silently never runs in production. In chain-based toolchains (revision graphs with down-revision pointers), a from-scratch file risks a broken or forked chain that blocks every later migration. Generate first; the bookkeeping comes with it.
- If the generated SQL is wrong or needs tuning, edit the generated file. That keeps the bookkeeping intact. Do not delete it and write a replacement from scratch.
- Make migrations idempotent — `IF NOT EXISTS` on creates, `IF EXISTS` on drops. A migration may be re-run against a partially-migrated database during a retry or a rollback-and-replay; a non-idempotent one fails the second time and blocks the deploy. If the toolchain has an auto-patch step for this, run it after any manual edit to a migration.
- Migrations are forward-only. Never edit or delete a migration that has been merged or applied anywhere but your own machine — the migrator records what it applied, and rewriting history makes its record a lie. Fix a bad migration with a new migration.

## Apply, then verify

- After generating, apply with `{{MIGRATE_APPLY_CMD}}`. This command must be the toolchain's **non-interactive, forward-only applier** (deploy-style, never a dev-mode sync that can prompt to reset) — it was chosen at adapt time precisely because it never drops data, which is what makes it safe to run without asking. If the command in this file can prompt, reset, or drop, the fill is wrong: stop and fix it rather than running it.
- **Verify the migration actually landed by querying the database directly** — inspect the system catalog (e.g. `information_schema.columns`) or select the new column. Do not trust the CLI's success output alone; a migrator can report success for a file it skipped, and the failure then surfaces as a production error instead of a local one.
- State the verification in your report: which object you queried and what you saw. "The command printed OK" is not verification.

## NEVER use the interactive push/sync command

- **Never run the ORM's interactive schema-push/sync command** (the one that diffs the schema against a live database and applies it in place). It can DROP tables and columns to make the database match, it prompts mid-run in ways that are easy to answer wrong, and it leaves no migration file — so the change never reaches any other environment. Use generate + apply instead, always.
- The same ban covers any "reset", "force", or "accept data loss" flag on the migration tooling. If you believe one is genuinely needed, stop and ask the user first.

## Writing data

- Validate and sanitize every input before it reaches a write. Enforce shape and type at the boundary, not in the handler body.
- **Never delete-and-re-insert a row to update it. Use UPDATE.** Delete+insert silently drops every column you did not list in the insert, breaks foreign keys pointing at the old row (or cascades deletes you did not intend), and burns two writes plus index churn to do one row's work.
  - The one legitimate exception: deleting genuinely ephemeral records for a business reason — e.g. discarding raw uploads or transcripts once they have been processed. That is a deletion, not an update, and it should be obvious from the code which it is.
- Prefer the project's query builder / parameterized API over raw SQL in handlers. Where raw SQL is unavoidable, parameterize it — never interpolate user input into a query string.

## CI enforcement

CI should fail the build, not just warn, on:

- a migration file with no matching journal/manifest entry or with a broken revision chain, per what the toolchain keeps (catches hand-written migrations),
- a migration missing its idempotency guards,
- a schema file modified with no new migration in the same change,
- a diff between the schema file and the migration history (regenerate and compare — a non-empty diff means someone edited one without the other).

Each check is a plain script over the migrations directory. Add them once; they catch the exact failures above before they reach production.

---

# Data Modeling

> **Applies when:** the project designs its own persistent data model and expects to query, aggregate, or report on that data.
> **Delete this file (and its `@` import in CLAUDE.md) if:** the project stores no durable data of its own.

Model for the queries you will have to answer later, not just the screen you are building today. Reshaping a data model after it holds production data is the most expensive refactor there is.

## Domain model vs. persistence model

- **The domain model is the shape your business rules reason about; the persistence model is the shape the database stores.** They are different concerns in different layers (see `clean-architecture.md`), and this file governs the persistence side.
- **They may legitimately be the same shape**, and early on they usually should be: while the entity is simple and no rule needs a shape the table cannot hold, one model is less to keep in sync. Split them when a rule actually strains against a column, and map between them in the repository adapter. Two hand-maintained models with no rule forcing them apart is pure cost.
- The checklist below decides **queryability at the persistence layer**. "Rows, not a blob" governs how data is stored and reported on — it does not dictate that the domain type must be flat, nor that every value object needs its own table.

## Decision checklist

Apply this before writing any new table, column, or migration. A reviewer should be able to point at a line and say which item it violates.

1. **Will this data ever be queried, filtered, aggregated, sorted, or reported on?**
   If yes, it is rows in a table — not a blob/JSON column, not a serialized array, not a delimited string. Rows are indexable, joinable, and countable; blob contents are not. Blob columns are for opaque payloads you only ever read back whole: raw provider responses, request snapshots, unstructured config.
2. **Does a user interact with this thing — create it, resolve it, dismiss it, assign it, react to it?**
   If yes, it is its own entity with its own table. Give it: a primary key, explicit status (never inferred from the presence of another field), created/updated timestamps, and foreign keys to whatever it belongs to. That is what makes "how many were dismissed last month, by whom" a single query instead of a migration.
3. **Could this relationship become many-to-many, or could the set of linked types grow?**
   If either, use a junction table, not a polymorphic `target_type` + `target_id` pair. Polymorphic columns cannot carry a foreign key, so nothing stops them pointing at a deleted row, and every join needs a `WHERE type = ...` filter the database cannot optimize.
4. **Can this state be derived from other columns?**
   If yes, derive it. Do not store a second copy that can drift. Exception: a denormalized value kept deliberately for read performance — write a comment saying what recomputes it and when.
5. **Is every column's meaning unambiguous from its name and type?**
   Prefer explicit enums/check constraints over free-text status strings. A status column with no constraint accumulates typos and dead values that no report can ever fully account for.

## Table conventions

- Every table gets a surrogate primary key, `created_at`, and `updated_at`. Timestamps cost nothing now and are unrecoverable later — you cannot backfill when a row was created.
- Declare foreign keys with an explicit delete behavior (restrict, cascade, or set null). Choose it deliberately; the default is rarely what you want for user-visible records.
- Prefer soft deletion (a `deleted_at` or status value) for records users can reference, restore, or report on. Hard-delete only what is genuinely ephemeral.
- Store timestamps as timezone-aware instants, money as integer minor units or a decimal type — never floats — and enumerable values as enums or constrained strings.
- Index the columns you filter and join on, especially every foreign key. Add the index in the same migration as the column, while you still remember the access pattern.
- Name tables and columns consistently with the existing schema (same pluralization, same case, same `*_id` suffix). Consistency is what lets a reader guess a column name correctly.

## When a blob column is the right answer

Use one only when all three hold: the payload is opaque or third-party-shaped, you read it back whole rather than querying inside it, and nothing in a report needs a field from it. If you later need to filter on a field inside the blob, promote that field to a real column in a migration — do not add an index into the blob and call it done.

## Adding to an existing model

- Read the neighboring tables before designing a new one and follow their patterns. A schema whose tables disagree with each other about naming, timestamps, or status modeling is harder to query than one with a slightly imperfect but uniform convention.
- Never widen a column's meaning to avoid a migration ("this field also means X now"). Overloaded columns are how a schema stops being trustworthy — add the column.
- When you remove the last writer of a column, remove the column in a migration. A column nothing writes still appears in every report and misleads whoever reads it next.

---

# API & Event Payload Design

> **Applies when:** the project exposes an API, RPC surface, or event/socket stream that another process or client consumes.
> **Delete this file (and its `@` import in CLAUDE.md) if:** the project has no server-to-client or service-to-service boundary of its own.

## Where this surface sits

- **Request and response DTOs live in Interface Adapters.** They speak the transport's vocabulary — envelopes, field names, status codes, pagination — and they must be free to change when the API changes without any use case changing. See `clean-architecture.md`.
- **Use cases take and return plain application types**, never a framework request/response object and never a DTO. A use case that accepts the framework's request object cannot be called from a job or a CLI, and testing it then requires booting a server.
- The handler stays thin: validate and parse into an application type, call one use case, map its result — or its domain error — to a DTO and a status. A business rule inside a handler is a layer violation, not a shortcut, and it is unavailable to every other caller.

## Data availability principle

- **When the server already holds the enriched data at the point of emission, send it.** Do not emit a bare ID or a skeleton object and leave the client to fetch what you were already holding in memory. The client then blocks on a round-trip, renders a spinner or a flash of empty state, and the user waits — that is a UX regression, not a simplification.
- This applies identically to socket/event payloads, webhook bodies, REST responses, and RPC results. "The client can just call the detail endpoint" is the failure mode, not the design.
- **Exactly three conditions justify a lean payload:**
  1. Enriching would require extra queries the server has not already loaded — you would be adding database work to every emission to save a request the client may never make.
  2. The event is high-frequency and bandwidth-sensitive (cursor positions, presence, progress ticks), where per-message size dominates cost.
  3. The client genuinely does not need the data yet — it is for a view that may never open.
- **"It is simpler to implement" is not one of them.** Neither is "the client already has a fetch hook." If you ship a lean payload, name which of the three conditions applies, in the PR description or a comment next to the emit.
- Cost check before enriching: if the extra data means one more query over data already in scope, send it. If it means an N+1 across a list, restructure the query — do not push the N+1 onto the client.
- The principle is unchanged by the layering; it is simply **an adapter-layer composition decision**. The use case returns what it computed; the adapter decides how much of that goes on the wire. Compose the richer payload from what the adapter already holds — never satisfy it by pushing transport-shaped data requirements down into a use case.

## Response shape consistency

- Give every endpoint of the same kind the same envelope. Collections return the same wrapper with the same pagination fields; single records return the same object shape everywhere they appear. A client should never need per-endpoint unwrapping logic.
- One canonical shape per entity. If a list view needs fewer fields, return a documented subset with the same field names and types — never rename or retype a field between endpoints.
- Errors use one typed shape across the whole surface: a stable machine-readable code, a human-readable message, and optional field-level details. Clients branch on the code, never on message text.
- Use HTTP status codes (or their transport equivalent) honestly: 400 for malformed input, 401/403 for auth, 404 for missing, 409 for conflict, 422 for semantic validation failure, 5xx only for genuine server faults. Never return 200 with an error body — every caller's error handling misses it.
- Absent versus empty must be unambiguous: pick `null` or omission for "no value" and apply it consistently. Do not mix empty string, `null`, and missing key for the same concept.
- Additive changes only on a published surface. Removing or retyping a field breaks consumers you cannot see — add the new field, migrate callers, then remove.
- Timestamps go over the wire as unambiguous instants in a single documented format. Never send a naive local time.

## Where validation belongs

- Validate at the boundary, before any business logic runs: request params, body, query strings, and event payloads from other services. Parse into a typed value and pass that inward — do not re-check the same field at three depths.
- Validate with a schema, not scattered `if` statements, so that the accepted shape is inspectable and the rejection message names the offending field.
- Treat everything crossing the boundary as untrusted, including payloads from internal services and third-party webhooks. Verify webhook signatures before parsing.
- Enforce authorization at the boundary too, and enforce it per record, not just per route. "The client only shows their own records" is not authorization.
- Do not re-check *shape and format* between internal modules that share types — trust the type system inside the trust boundary. Over-defensive internal checks hide the real boundary and rot. Domain *invariants* are different: entities and use cases enforce those themselves regardless of what the boundary checked, because every other entrypoint skips the boundary (see the validation split in `clean-architecture.md`).
- Never leak internals in error responses: no stack traces, no SQL, no upstream vendor payloads. Log the full detail server-side with enough context to debug (route, actor, params, error), return the typed shape to the caller.

## Boundary changes

- Update the shared/generated types in the same change as the handler. A response shape and its type declaration must never disagree.
- Every new endpoint or event ships with tests in the same change. What those tests must assert is defined once, in `testing.md` ("What an endpoint test asserts") — that list is the single home for it.
- When you change a response shape, update the consumers in the same change and grep for every reader of the changed field. A dropped or renamed field that still typechecks on the server is a silent client break.

---

<!-- MODULE:frontend — KEEP IF the project contains client-side application code. DELETE otherwise. -->

# Front-End Engineering

> **Applies when:** the project builds a client-side application (`{{UI_FRAMEWORK}}` components, views, routes, and client state).
> **Delete this file (and its `@` import in `CLAUDE.md`) if:** the project has no user interface — a library, CLI, service, or job runner. Pair it with `design-system.md`, which covers how the UI should *look*; this file covers how it should be *built*.

## The UI is a Detail

- **View components render and dispatch; they do not decide.** Whether a record is valid, eligible, overdue, or permitted is a business rule, and it never lives inline in a component or a hook — a rule embedded in a component cannot be tested without rendering it, and it gets re-implemented slightly differently on the next screen. In a client-server product the authoritative copy lives server-side, in the domain layer behind the API; in a client-only app it lives in a plain domain module the component calls. See `clean-architecture.md`.
- **The typed client `{{API_WRAPPER}}` is the adapter** between this layer and everything behind it. Every rule below about going through it follows from that: call the adapter, never reach past it.
- Derived *presentation* state — formatting, sort order, which chip to show — is this layer's job. Derived *business* state — is this at risk, may this user approve it — is not. The client may mirror a business rule for instant feedback (disabling a button, inline validation), but the server's answer is the real one and the server always re-enforces it: a client-computed rule the server doesn't check is a rule every other client is free to break.

## File organization

- `{{UI_PRIMITIVES_DIR}}` — generic, product-unaware primitives. They take props, emit events, and know nothing about the domain. A primitive that imports a domain type is no longer a primitive.
- `{{DOMAIN_COMPONENTS_DIR}}` — components that know the product's nouns. Compose them from primitives; see `design-system.md` for the "assemble before you invent" rule.
- `{{PAGES_DIR}}` — one file per route. Pages wire data to components and own the route's async states; they should contain little markup of their own.
- One component per file, named the same as the file, exported by name. A file that exports three components hides two of them from search and from reuse.
- Extract a subcomponent when a piece is reused, or when a file grows past the point where its render is readable in one screen — not merely because a file is long. Splitting a linear render into six files makes it harder, not easier, to follow.

## State

- **Colocate state with the component that uses it.** Start with local state; it is the only kind that cannot desynchronize.
- **Lift state only when two siblings must agree on it**, and lift exactly to their nearest common parent — no higher. State parked at the root re-renders the whole tree and turns every read into prop-drilling.
- **Reach for global/context state only when the value is genuinely app-wide** (session/user, theme, feature flags) or when lifting would thread a prop through four or more layers. Say why in the code or the PR, because global state is the hardest thing here to remove later.
- **Server data is not application state.** Cache it in the project's data-fetching layer (`{{DATA_FETCH_LIB}}`); do not copy it into local state "so it's easier to edit" — you then own an invalidation bug forever. Copy into local state only for an in-progress edit buffer, and drop it on save.
- Derive, do not duplicate. If a value is computable from existing state or props, compute it during render rather than storing it in a second state variable that can drift.

## Data fetching

- **All network access goes through the project's typed client `{{API_WRAPPER}}`.** Never call the raw HTTP primitive (e.g. `fetch`) directly from a component: the wrapper is where base URL, auth headers, error shaping, and response typing live, and a raw call opts out of all of them silently.
- If an endpoint's response type is missing or wrong, fix it in the shared types — do not cast at the call site. A local cast makes the next caller repeat the bug.
- **Avoid request waterfalls.** Requests that do not depend on each other are issued in parallel, not sequentially awaited. A child component that fetches data its parent could have requested alongside its own turns one round-trip into two.
- Fetch at the route/page level or in a dedicated hook — not inside deeply nested presentational components, which makes the request count a function of the render tree.
- Mutations invalidate or update the affected cache entries. A stale list after a successful create is a bug, not a refresh-button opportunity.

## Loading, empty, and error — the required trio

Every asynchronous surface ships all three states. No exceptions, and this is checkable in review by looking for the three branches.

- **Loading** — a skeleton or inline indicator matching the eventual layout, so content does not shift when data lands.
- **Empty** — a real designed state that names what belongs here and offers the action that creates it. A blank region reads as a broken page.
- **Error** — a visible message in the UI *and* a logged error with enough context to debug. **Never let a user-facing async operation fail silently**; a spinner that never resolves is the worst possible outcome because the user cannot tell whether to wait or retry. Error shape and logging rules live in `error-handling.md`.

This applies to page loads, form submissions, background saves, file uploads, and auth flows alike.

## Accessibility floor

Non-negotiable minimum; a screen failing any of these is not done:

- **Every interactive element is reachable and operable by keyboard.** If you attach a click handler to a non-interactive element, you have created a control that keyboard and screen-reader users cannot use — use a real button/link instead.
- **Focus is always visible.** Never remove the focus outline without replacing it with an equally clear one, and return focus sensibly when dialogs and menus close.
- **Every control has an accessible name** — a visible label tied to the input, or an explicit label attribute for icon-only buttons. An icon alone is unlabelled.
- **Contrast meets WCAG AA** (4.5:1 body text, 3:1 large text and interactive boundaries). Muted-on-muted is the usual offender.
- **Never encode meaning in color alone** — pair status color with text or an icon.
- **Respect reduced-motion preferences**: disable non-essential animation when the user has asked for it at the OS level.
- Images carry meaningful alt text, or empty alt when purely decorative.

## Performance hygiene

- **Virtualize long lists.** Render-everything is fine up to roughly a few hundred rows; past that, virtualize or paginate — beyond that threshold the DOM node count, not your code, becomes the bottleneck.
- **Give every image explicit dimensions** and serve it at display size. Unsized images cause layout shift; oversized ones waste the user's bandwidth on pixels never shown.
- Memoize only in response to a measured problem. Speculative memoization adds dependency arrays that go stale and produce bugs far more expensive than the render it saved.
- Code-split at route boundaries so a rarely used screen does not sit in the initial bundle.
- Keep effects narrowly scoped with honest dependencies. An over-broad effect that refetches on every render is the most common self-inflicted performance bug in client code.

## Removing UI

Deleting a button is never the whole change. When you remove the last entry point into a view, route, modal, or state branch, remove what it reached: the route registration, the view component, its state variant, its data fetching, and its tests — in the same change. Search the repo (including string-keyed and dynamic references) to confirm it was the last caller. An unreachable screen still ships in the bundle, still breaks silently, and still costs the next reader time. See `code-style.md` for the general dead-code rule.

<!-- /MODULE:frontend -->

---

<!-- MODULE:design-system — KEEP IF the project renders a user interface. DELETE otherwise. -->

# UI Design System

> **Applies when:** the project ships screens a human looks at (web app, desktop app, mobile app, or a styled docs/marketing surface).
> **Delete this file (and its `@` import in `CLAUDE.md`) if:** the project has no user interface — a library, CLI, service, or job runner. Nothing here applies to terminal output.

## Design reference

**This UI should feel like: `{{DESIGN_REFERENCE}}`** — same aesthetic family as `{{AESTHETIC_FAMILY}}`.

Name a real product, not adjectives. "Clean and modern" means nothing shared; a named product is a target the model has already seen thousands of screens of, so every unstated decision (border weight, empty-state tone, how a table row highlights) resolves the same way instead of being invented per screen.

## Visual style

Pick one value per axis and hold it everywhere. An inconsistent axis is more noticeable than a "wrong" one.

| Axis | The choice to make | This project |
| --- | --- | --- |
| Chrome weight | flat/hairline borders → soft cards → heavy shadowed surfaces | `{{CHROME_WEIGHT}}` |
| Palette strategy | monochrome + one accent → two-tone brand → full multi-hue | `{{PALETTE_STRATEGY}}` |
| Density | dense (max info per viewport) → balanced → airy/marketing | `{{DENSITY}}` |
| Default text size | small-body UI → standard-body → large/accessible-first | `{{DEFAULT_TEXT_SIZE}}` |
| Hover & motion | near-static, tint-only → light transitions → animated/expressive | `{{MOTION_INTENSITY}}` |

*Worked example (one product's answers — an illustration, not a mandate):* hairline borders and no drop shadows; monochrome with a single accent reserved for links and interactive affordances; dense layout with minimal padding; small body text with an even smaller label size; hover = a faint background tint, never a color jump.

## Layout patterns by page archetype

- **Detail / record page** — the primary pane is whatever the user actually came to see (the timeline, the document, the run log), not a grid of metadata. Metadata, related records, and destructive actions go in a secondary sidebar. A full-width header carries back-navigation, the record's name, and status. Getting this backwards — fields center-stage, real content in a tab — is the single most common design regression.
- **List / index page** — full-width table or list, search plus filters directly above it, one consistent pagination or infinite-scroll mechanism, row click navigates to the detail page, primary "create" action top-right. Do not mix pagination styles across lists.
- **Dashboard** — a scannable summary row on top, detail below; every tile states its time window and links to the filtered list it summarizes. A number with no drill-through is decoration.
- **Form / wizard** — one column, grouped into labelled sections; multi-step only when steps are genuinely sequential, and then show step position and allow going back without data loss.
- **Empty, loading, and error states** — designed, never default. Empty states name what would appear here and offer the action that creates it; loading uses skeletons matching the real layout so nothing jumps; error states say what failed and what to do next. See `error-handling.md`; these three are required for every async surface (see `frontend.md`).

## Component conventions

- **Primitives vs. domain components.** Generic, reusable, product-unaware primitives live in `{{UI_PRIMITIVES_DIR}}` (button, input, select, badge, dialog). Components that know about the product's nouns live in `{{DOMAIN_COMPONENTS_DIR}}`. Mixing them makes primitives unreusable and domain components untestable.
- **Assemble before you invent.** A new component is composed from existing primitives first. Add a new primitive only when no combination expresses it — then add it to `{{UI_PRIMITIVES_DIR}}` so the next person finds it instead of building a third variant.
- **Variants are a closed, named set**, declared on the primitive and reused verbatim (an illustrative set: `default`, `primary`, `success`, `warning`, `destructive`, `info`). Never style a one-off by overriding a primitive's internals from the call site — that override becomes the fourth unofficial variant.
- **Presentation never encodes a business rule.** A badge's variant map — which status renders as destructive — is presentation and belongs here. *What makes a record "at risk"* is a domain rule and does not (see `clean-architecture.md`). A component that decides eligibility has made that rule unavailable to every other surface, and the two will disagree.
- **One icon library and one icon size.** Use `{{ICON_LIBRARY}}` at `{{ICON_SIZE}}` everywhere; deviate only for a deliberate hero/empty-state graphic. Mixed icon sets and drifting sizes read as broken before anyone can say why.
- Styling goes through `{{STYLING_SYSTEM}}`. Do not introduce a second styling mechanism alongside it.

## Typography & spacing scale

Fill each row from the project's own tokens, then treat the table as the vocabulary — no ad-hoc sizes at call sites.

| Role | This project | Worked example (illustration only) |
| --- | --- | --- |
| Section header | `{{SECTION_HEADER}}` | small, semibold, muted, uppercase with slight letter-spacing |
| Field label | `{{FIELD_LABEL}}` | one step below body, muted foreground |
| Field value | `{{FIELD_VALUE}}` | body size, full-contrast foreground |
| Section padding | `{{SECTION_PADDING}}` | one padding step (~16px) on every panel |
| Element gap | `{{ELEMENT_GAP}}` | one vertical rhythm step (~12–16px) between stacked elements |
| Borders | `{{BORDER_TREATMENT}}` | 1px solid border token; a lower-opacity variant for row dividers |

Two sizes of the same thing is a bug: if a screen needs a size not in this table, extend the table rather than hardcoding a value.

## Forms

- **Labels above inputs**, never beside. Left-aligned labels break at narrow widths and force a second layout.
- **Pair related fields in a two-column grid** (first/last name, start/end date) so the form reads as groups; keep single-column for anything long or free-text.
- **Progressive disclosure driven by earlier answers** — fields that only apply to a chosen type appear after that choice. Do not render disabled fields that may never apply; disabled controls read as broken.
- **Button placement is consistent across every form in the app**: primary submit and its cancel neighbour in the same position and order everywhere. Pick one and never vary it per screen.
- **Errors are inline, adjacent to the offending field**, in the small destructive-text style, and the field itself gains an error border. A form-level banner is for submission failures only, not field validation.
- Preserve entered data on failed submission. Re-typing a form because the server rejected one field is the fastest way to lose a user.

## Consistency check

Run this against any new or changed screen before calling it done:

1. Does it match `{{DESIGN_REFERENCE}}`, or did it drift toward a different product's look?
2. Every visual-style axis above matches the rest of the app (chrome, palette, density, text size, hover).
3. It follows its page archetype's layout — and on a detail page, the primary pane holds real content, not metadata.
4. Loading, empty, and error states all exist and were actually viewed, not assumed.
5. No new primitive that an existing one could have covered; no primitive overridden from a call site.
6. All icons from one library at the standard size.
7. Every size, spacing, and border value comes from the scale table — no ad-hoc values.
8. Forms: labels above, consistent button placement, inline field errors, input preserved on failure.
9. Keyboard and focus behavior verified per `frontend.md` — the design is not done if it is mouse-only.

<!-- /MODULE:design-system -->

---

<!-- MODULE:ai — KEEP IF the project calls an LLM or enriches records from third-party sources. DELETE otherwise. -->

# AI Features & Data Enrichment

> **Applies when:** the project calls a language model, or fills in record fields from third-party data sources.
> **Delete this file (and its `@` import in CLAUDE.md) if:** the project does neither.

## Design for the next model, not this one

- **Model providers and enrichment vendors are Frameworks & Drivers, and they sit behind ports.** The use case declares the capability it needs (`classify`, `summarize`, `resolveOrganization`); the provider SDK implements it as an adapter. See `clean-architecture.md`. That is the whole reason a provider swap or a model upgrade is a one-adapter change instead of a grep across every feature.
- **Nothing inward of that adapter may name a provider, a model identifier, or a vendor's response shape.** A use case that branches on which model answered has hardcoded a Detail into a business rule, and the next upgrade has to touch it.
- **Build so that swapping in a newer model produces a visible quality improvement with zero code changes.** Model identifiers, prompts, and tuning parameters are configuration; if upgrading means editing call sites, the upgrade will be deferred and the product will quietly stay a generation behind.
- Route every model call through one internal client. Prompt selection, model selection, retries, timeouts, token accounting, and logging live there — not scattered across features.
- **Keep prompts as configuration, not hardcoded strings.** Store them as versioned templates (files or table rows) with named variables. This is what lets you iterate a prompt without a deploy and diff which version produced which output — and it is the same principle as the port: a prompt hardcoded at a call site is a Detail that has escaped into a business rule.

## Persist provenance on every output

- Write model outputs to a **single unified outputs/decisions table**, one row per call, rather than one column bolted onto each feature's table. One table means one query answers "what did the model decide, when, with what, and did anyone override it" across every feature.
- Every row records at minimum: the feature/kind, the input reference (which record it was about), the model version, the prompt version, the output, a timestamp, and the outcome (accepted, rejected, superseded).
- **Store the model version and prompt version on every single output.** Without them you cannot compare a new model against the old one, cannot attribute a regression, and cannot safely reprocess.
- **Track input and output tokens as separate columns.** They bill at different rates per model, so a single combined count cannot be turned into a cost figure after the fact — and cost per feature is the number that decides whether a feature stays on.
- Record failures and refusals as rows too. A table that only holds successes cannot tell you a prompt's failure rate.

## Reprocessing and freshness

- **Support batch reprocessing from the start**: a job that re-runs a chosen feature over a chosen set of records with the current model and prompt. When a better model ships, one operator action should level up the whole corpus overnight.
- Reprocessing writes new rows; it never overwrites old ones. Keeping the prior output is how you prove the new model is actually better before switching over.
- **Use lazy, on-demand evaluation for high-value surfaces** — the ones a user is actively reading, where quality matters more than a few hundred milliseconds. Computing at read time means those surfaces always hit the current model with no deploy and no backfill.
- Use precomputation for bulk, low-value, or latency-critical paths, and cache keyed on model version + prompt version + input hash — so a version bump invalidates the cache automatically instead of serving stale answers forever.
- Never block a user-facing write on a model call. Enqueue it and let the UI show a pending state.

## Enrichment from third-party sources

- **Persist enriched data in your own tables. Never re-fetch on render.** Fetch once — at record creation or in a background job — store the result, and serve from your own data thereafter. Per-render fetching costs a vendor call per page view, adds vendor latency to every load, and makes the page break when the vendor is down.
- **Enrich automatically in the background, not as a manual step.** When a record arrives with an identifier a vendor can resolve (a domain, an email, a company name), the enrichment job should start on its own. Anything requiring a user to click "enrich" ends up applied to a fraction of records, and the coverage gap poisons every report built on those fields.
- **Surface enriched data everywhere the record appears** — inline chips, list rows, search results, avatars, timeline items — not only on the record's detail page. Enrichment you paid for and only show in one place is mostly wasted.
- **Track which fields the user edited by hand** (a per-record list of user-modified field names, or per-field provenance) and make every enrichment write skip them. A background job that overwrites a correction the user made by hand destroys trust in the whole feature, and the user has no way to tell it happened.
- Record the source and fetch timestamp for each enriched field so stale or disputed data can be traced and re-fetched selectively.
- Treat vendors as categories, not dependencies: a structured-data provider (e.g. a people/company data API), an asset provider (e.g. a logo service), a model for classification and summarization. Put each behind a port so a vendor swap is one adapter, and never let a vendor's response shape leak into your schema or your API.

## Guardrails

- Validate and constrain model output before it is stored or displayed — parse to a schema, reject what does not conform, and log the rejection. Never render raw model output into a trusted context.
- Set explicit timeouts and cost/rate ceilings on every model and vendor call, and degrade to the un-enriched view on failure rather than erroring the page.
- Never send more of a record to a third party than the feature needs, and keep the redaction rules in the shared client, not per feature.

<!-- /MODULE:ai -->


<!-- PANOPLY:RULES:END -->
