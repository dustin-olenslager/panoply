# Progress board: every project shows its live state

> **Applies when:** always, in every repo built with dev-kit.
> **Delete this file (and its `@` import in the generated agent hub) if:** never.

Every dev-kit repo has a live progress board: a claude.ai Dashboard artifact that shows the roadmap, the queue, open PRs, decisions, open questions, live production and working sessions, and keeps itself current (Dustin, 2026-11-10).

1. **One board per repo, declared in the repo.** `.agents/progress-board.json` names the board's URL. CI fails without it (`scripts/check-progress-board.sh`). `10ton-bootstrap` creates the board, the file and the timer for a new repo.
2. **One engine fills every board.** dev-kit's `scripts/vps/progress-board/` builds the standard sections from the docs spine and GitHub. A repo adds its own sections as extras: its config names one with `"use"`, and the command lives in the engine (`core.EXTRAS`), never in the repo (SEC-6). Never hand-build a per-project sync script.
3. **The docs spine is the source.** The board shows what `docs/agents/roadmap.md`, `docs/agents/in-progress.md` and the decisions doc say on main. Keep them current and the board is current; never edit a board's data by hand.
4. **It refreshes itself.** The dev-kit-core hook starts the repo's sync after `git push` or `gh pr merge`, and a 30-minute timer is the backstop. A failed sync shows on the board's own status section; fix the cause, not the board.
5. **The link travels with the work.** Every PR body links the repo's board (`land` adds it if missing). Sessions are told at start which boards changed in the last day, and on Desktop the board opens beside the chat the first time a session works in the repo.
6. **Every item links to where it lives.** A queue or roadmap row that has a Plane work item, a Figma frame or a Miro board names them in its Plan cell, after the plan doc: the Plane id typed bare (`BACKLOT-259`), Figma and Miro as pasted links to the exact frame or board (`?node-id=…`, `?moveToWidget=…`). A PR body carries the same in one `Links:` line. The board turns them into one-click links; it never guesses from other text, so a row with none shows none. Whoever creates the Plane item, the Figma frame or the Miro board adds it to the row in the same change. (Dustin, 2026-11-13.)
