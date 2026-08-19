# docs/claude — project knowledge base

Committed, team-shared context for both humans and Claude Code. Everything here is written to be
read under context pressure: short, dated, and specific. Personal preferences and machine-local
setup do **not** belong here — those live in your own `~/.claude/` memory.

## Read order

Start at the top; read what bears on the task, not everything every time.

1. `in-progress.md` — the ordered queue of what is next, with plan-doc pointers. **Always read first.**
2. `architecture.md` — decisions and their reasoning (ADR entries).
3. `key-patterns.md` — conventions, gotchas, testing practice.
4. `infrastructure.md` — deploy, hosting, data stores, secrets, background jobs.
5. `completed-features.md` — what already exists, so you do not rebuild it.
6. The relevant **area folder** — active plans and research for the thing you are changing.

## Layout

```
docs/claude/
  README.md               this file
  in-progress.md          ordered queue of active work
  completed-features.md   shipped log, with archive paths
  architecture.md         decisions worth recording (ADRs)
  infrastructure.md       how it runs and deploys
  key-patterns.md         patterns, gotchas, testing conventions
  _templates/
    plan.md               copy this to start any plan
    feature-area/         the per-area folder convention
  reports/                dated command-output reports (e.g. stack-assessment-<date>.md)
  <area>/                 e.g. api/, ui/, data/, integrations/
    <feature>/plan.md     active work
    completed/            archived, renamed on ship
```

Never create flat files at the top of `docs/claude/` — new work goes in an area folder.

`reports/` is the one exception to the lifecycle below: it is an **append-only dated archive** of
command-generated reports (`/assess-stack --save` and similar). Reports are history — they are
never moved to `completed/`, never pruned as stale, and old reports naming since-removed things
are the point, not a defect. Newest file wins; earlier ones exist for trend comparison.

## Lifecycle of a doc

1. **Plan** — copy `_templates/plan.md` into `<area>/<feature>/plan.md`; link it from `in-progress.md`.
2. **Build** — re-read the plan at the start of each milestone; tick milestones off; record surprises
   inline with `> **Build note:**` at the moment you find them.
3. **Ship** — move the whole `<feature>/` folder into `<area>/completed/`, rename files to describe
   what shipped, add a row to `completed-features.md`, and remove the item from `in-progress.md`.
4. **Promote** — anything durable the build taught you (a decision, a gotcha) graduates out of the
   plan into `architecture.md` or `key-patterns.md`. Plans are archived; those two files are living.

Archive, never delete. Update docs in the same PR as the code they describe.
