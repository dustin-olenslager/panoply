# AUDIT — promises vs reality: the 8 code gates vs the doctrine

Scope: every sentence anywhere in `.agents/rules/*.md`, `AGENTS.md`, and the kit's own docs that
claims what one of the 8 gates does, compared against what the script actually does. Both directions
were hunted: doctrine describing behaviour the gate lacks, AND gate behaviour no doctrine documents.

**FIXED IN THIS PR (doctrine only, no gate behaviour changed):** rows 1, 2, 3, 5, 6, 7 (agent-readiness.md),
8, 9, 29 (algorithm.md), 10 (git-workflow.md), 11, 12, 27 (documentation.md), 13 (workflow.md),
18, 19 (spec.md), 22 (workflow.md), 24, 26 (git-workflow.md — conflict gate). Rows NOT fixed are the
low-severity residue that does not misrepresent a control (25, 28) plus the two behavioural findings
(G1, G2), which are the owner's call.

Method: read each script and quote `file:line` for what it blocks on / what is opt-in / what is a
warning / what escape hatch exists; extract every doctrine claim about it; compare. Behavioural
claims were reproduced in a scratch repo, not assumed.

Gates: `check-agent-readiness.sh`, `check-algorithm.sh`, `check-conflict-markers.sh`,
`check-docs.sh`, `check-expert-review.sh`, `check-plan-home.sh`, `check-rule-fork.sh`,
`check-spec.sh`.

Classification: **FALSE CLAIM** (doctrine describes behaviour that does not exist) · **OVERSTATED**
(opt-in presented as unconditional, or a soft warning presented as a block) · **UNDERSTATED** (gate
does more than claimed) · **STALE** (behaviour changed, doctrine did not) · **UNDOCUMENTED**
(behaviour with no doctrine statement at all).

---

## The full mismatch table

| # | Doctrine (file:line) — the claim | What the code actually does (file:line) | Class | Sev | Smallest fix |
|---|---|---|---|---|---|
| 1 | `.agents/rules/agent-readiness.md:98` — "the app **starts and passes a smoke test** with only `LLM_BASE_URL` / `LLM_API_KEY` / `LLM_MODEL` set — the standalone-with-one-key proof." | No smoke test exists anywhere in the script. It never runs the app; the closest is a static vendor-string grep (`scripts/check-agent-readiness.sh:243-264`). The gate's own header says the smoke test "stay[s] in the review checklist" (`:4-6`). | FALSE CLAIM | **HIGH** | Delete the bullet from the "what CI checks" list; move the smoke test to the review-checklist section it already lives in (line 100). |
| 2 | `.agents/rules/agent-readiness.md:96` — MCP schemas "are generated (not hand-written) **and in sync with the API schemas**". | The script checks ONLY that a generation helper name appears somewhere in the tree (`scripts/check-agent-readiness.sh:229-236`, `GEN=`). It never compares generated output against the API schemas — there is no sync check at all. | FALSE CLAIM | **HIGH** | Drop "and in sync with the API schemas"; state it checks generation exists, and sync is a review item. |
| 3 | `.agents/rules/agent-readiness.md:97` — "no vendor LLM endpoint **or model identifier** is hardcoded outside the LLM adapter." | `VENDOR_RE` matches endpoints and SDK constructor calls only (`scripts/check-agent-readiness.sh:243`). A hardcoded model id (`gpt-4o`, `claude-3-5-sonnet`) passes — reproduced: a repo with `const m='gpt-4o'` printed `ok no vendor LLM endpoint/SDK hardcoded`. | FALSE CLAIM | **HIGH** | Either add a model-id pattern to the gate, or (doctrine-only, this PR) state the gate checks **endpoints and SDK imports**, not model identifiers. |
| 4 | `.agents/rules/agent-readiness.md:95` — "every mutation route accepts an idempotency key." | Static best-effort: it finds mutation-shaped files and requires an idempotency token to exist globally (any file matching `middleware|/lib/|…`) or be referenced in each mutation file (`scripts/check-agent-readiness.sh:185-218`). A defined-but-never-wired helper on a global-looking path passes. Not per-route verification. | OVERSTATED | MED | Reword to "a mutation surface with an idempotency mechanism that is global or referenced by each mutation file (static detection)". |
| 5 | `.agents/rules/agent-readiness.md:92-98` — the verification list. | The gate also runs two checks doctrine never lists: **#6 a non-human scoped principal exists** (`:266-281`) and **#7 `--since` agent-surface drift** (`:283-317`). Both are real, both are absent from the "it checks" list (the principal IS covered by the rule body, the drift check is not). | UNDERSTATED / UNDOCUMENTED | MED | Add both to the list; name the `--since` drift check explicitly. |
| 6 | `.agents/rules/agent-readiness.md:94` — "the agent card exists and is valid JSON … and is served at the well-known path". | Accurate — but the "served" check is a **path-shape** heuristic (`public/.well-known/`, `*route.*`, `*/api/*`, `*handler*`), `scripts/check-agent-readiness.sh:154-164`. It never fetches the card. Also the JSON check **SKIPs loudly** (not fails) when no jq/python3/node is present (`:128-129`). | UNDERSTATED (limit) | LOW | State that "served" is a path-shape heuristic and JSON validation skips without a parser — the gate's own header already says this; surface it in the rule. |
| 7 | `.agents/rules/agent-readiness.md:92-98` — no mention that the whole gate is **opt-out** (`AGENT_READINESS=off`) or **warn-able** (`AGENT_READINESS_ENFORCE=warn`). | Both exist (`scripts/check-agent-readiness.sh:37`, `:39`, `:324-327`). `AGENT_READINESS_ENFORCE=warn` has no doctrine statement in the module that owns the gate. | UNDERDOCUMENTED | LOW | Name both knobs and the "never leave warn on" caveat in the module. |
| 8 | `.agents/rules/algorithm.md:143-145` — the gate "checks … a non-trivial change exists (code, or a new automation/process file)". | The gate classifies a change as structural via `CODE_RE` (`scripts/check-algorithm.sh:39`); "a new automation/process file", if it is not a code-suffixed/`scripts|src|…` path, is **not** caught. e.g. a new `.github/workflows/*.yml` counts (yml suffix), but a new `Makefile` target or a doc-only process change does not. | STALE / OVERSTATED | LOW | Reword to match the real predicate (code-suffixed or under a source/scripts/infra dir). |
| 9 | `.agents/rules/algorithm.md:141` — lists what the gate checks; no mention of the **`ALGORITHM_FILES` / `ALGORITHM_PLAN_GLOB` overrides** or the `--staged`/`--since`/git modes. | All exist (`scripts/check-algorithm.sh:18`, `:35`, `:41-56`). | UNDERDOCUMENTED | LOW | Add one line naming the overrides; the modes are implied by the other gates' doctrine. |
| 10 | `.agents/rules/git-workflow.md:26` — "`check-docs.sh --since` **walks every commit in the range**". | It walks every commit **except merge commits** — `[ "$(git rev-list --no-walk --count --merges "$sha")" -eq 0 ] || continue` (`scripts/check-docs.sh:92`). A merge commit is skipped. | OVERSTATED (minor) | LOW | Add "non-merge" or "each non-merge commit". |
| 11 | `.agents/rules/documentation.md:83-90` — describes the landing gate contract; no mention of **`DOCS_OFF`**, **`DOCS_EXEMPT`**, or the lazy worklog resolution. | All exist (`scripts/check-docs.sh:16-19`, `:28`, `:38-45`). `DOCS_OFF` is the declared escape hatch and is not named in the module that owns the gate. | UNDERDOCUMENTED | LOW | Add the hatch + `DOCS_EXEMPT` (product-is-markdown case) to the module. |
| 12 | `AGENTS.md:69-71` + `documentation.md:83` — "The landing gate `scripts/check-docs.sh` fails any commit that changes code but not the worklog in the same commit". | True for the gate's default/staged mode. The `--since` (CI) mode walks per-commit and skips merges (see #10). Also `documentation.md:54` says the same-change contract is "enforced by review and `/audit-agents-setup` — never a tool-only permission gate", which reads as contradicting the "enforced by check-docs.sh" claim two sections later. | STALE (internal tension) | LOW | Reconcile: `check-docs.sh` enforces the **worklog-presence core**; review enforces the rest (in-progress row, roadmap move). |
| 13 | `.agents/rules/workflow.md:53` — "`scripts/check-plan-home.sh` enforces **this**" where "this" is the whole plan-home rule incl. "a plan is a roadmap ROW". | The gate enforces **location only**: no plan-shaped file outside the allowed set, plus the canonical `roadmap.md` existing (`scripts/check-plan-home.sh:44-113`). It does **not** require a roadmap row, an `in-progress.md` row, or any content. The gate's own header says "enforces LOCATION, not CONTENT". | OVERSTATED | MED | State the contract as "no plan doc outside the canonical home, and `roadmap.md` exists"; the row/link obligations are review. |
| 14 | `docs/agents/README.md:46-47` + `docs/agents/roadmap.md:6-7` — "`check-plan-home.sh` fails CI **and pre-commit** on any plan doc outside this tree". | In `--staged` (pre-commit) mode the gate checks **only newly ADDED** files (`--diff-filter=A`, `scripts/check-plan-home.sh:36-37`); an edit to an already-tracked stray passes pre-commit. CI (tracked-tree) mode does catch it. | OVERSTATED | LOW | Say "pre-commit catches newly added strays; CI catches all". |
| 15 | `.agents/rules/workflow.md:53` — names `PLAN_HOME_ALLOW` and `PLAN_HOME_OFF=1` as the escape hatch. | Accurate (`scripts/check-plan-home.sh:28`, `:75-78`). | — clean | — | none |
| 16 | `.agents/rules/spec.md:107-109` — "wired into `ci-verify.yml` for the PR context and `pre-commit` for the local one. It fires on a structural change with no spec, and on a spec carrying an unresolved marker". | Accurate (`scripts/check-spec.sh`; template runs `--since` and pre-commit runs `--staged`). | — clean | — | none |
| 17 | `.agents/rules/spec.md:88-95` — honest-limits section (presence + resolution only; cannot judge story quality). | Accurate and matches the script's own "WHAT THIS GATE CANNOT DO" header (`scripts/check-spec.sh:27-33`). Model for the other modules. | — clean | — | none |
| 18 | `.agents/rules/spec.md` (whole module) — no mention of the gate's **wiring exemption** (`CONFIG_RE`: `.github/`, `.pre-commit`, tool configs, `.agents/` are treated as non-structural). | Real and load-bearing: a `.yml` under `.github/` is exempted from the structural predicate (`scripts/check-spec.sh:58-61`, `:132`). A CI-wiring change needs no spec. | UNDOCUMENTED | LOW | Add one sentence: CI/hook/config wiring is exempt by design. |
| 19 | `.agents/rules/spec.md:25` — "both it [`check-plan-home.sh`] and `check-algorithm.sh` glob `docs/agents/*/*/`". | True for `check-plan-home.sh` and `check-algorithm.sh`, but `check-spec.sh` only searches `docs/agents/*/*/spec.md` (`scripts/check-spec.sh:44`) — it has **no** lightweight-`docs/PLAN.md` home, while `check-algorithm.sh` and `check-expert-review.sh` both accept `docs/PLAN.md` (`:35` / `:52`). A lightweight-plan repo passes the algorithm gate and then has **no spec home the spec gate recognises**. | STALE / inconsistency | MED | Either note the mismatch or align the globs; at minimum document that the lightweight `docs/PLAN.md` path has no spec sibling. |
| 20 | `.agents/rules/workflow.md:55` — "`scripts/check-spec.sh` enforces presence and resolution in CI". | Accurate. | — clean | — | none |
| 21 | `.agents/rules/workflow.md:77-94` — the expert-review contract (4-check history corrected by PR #31). | Now matches the script. Verify: 1) plan doc **added or modified** by the change (`scripts/check-expert-review.sh:197-224`); 2) checklist item in that file, checked or unchecked (`:229-234`); 3) sign-off opt-in behind `EXPERT_REVIEW_REQUIRE_SIGNOFFS=1` (`:241-253`); 4) no `adr.md` check. Doctrine states all four correctly. | — clean | — | none |
| 22 | `.agents/rules/git-workflow.md:26` and `workflow.md:74` — trivial carve-out "single file, ≤15 lines added, no schema/API/interface change". | The script's trivial check requires exactly 1 file, ≤15 added lines **and zero files matching `.sql|prisma|graphql|proto|openapi|yaml|yml`** (`scripts/check-expert-review.sh:161-165`). A change touching one **`.yml`** file of 15 lines is NOT trivial. Doctrine says "no schema/API/interface change" — a yml config file is treated as schema-ish. | OVERSTATED (narrow) | LOW | "no schema/API/interface file (the gate treats `sql/prisma/graphql/proto/openapi/yaml/yml` as schema)". |
| 23 | `.agents/rules/workflow.md:89` — "The gate carries … `EXPERT_REVIEW_OFF=1`". | Accurate (`scripts/check-expert-review.sh:42`). | — clean | — | none |
| 24 | **No doctrine anywhere** (`.agents/rules/**`, `AGENTS.md`) mentions `check-conflict-markers.sh` or its escape hatch `CONFLICTS_OFF=1`. | The gate is CI-wired as a **required per-PR step** (`scripts/templates/ci-verify.yml:50-52`, `.github/workflows/verify.yml`) and `CHANGELOG.md:65-77` describes it as protecting a real incident — yet no rule module tells an agent it exists or names its escape hatch. | UNDOCUMENTED | **HIGH** | Add a short "no conflict markers" note to `git-workflow.md` (nearest doctrine) naming the gate, its tree-wide scan, and `CONFLICTS_OFF=1`. |
| 25 | `check-conflict-markers.sh --since` mode exists (`:32-33`, `:52-84`) but **no doctrine or CI invokes it**; CI runs tree mode. | The `--since` path resolves a path list from `git rev-list "$SINCE"..HEAD` and searches only those paths — a deliberately narrower scope. Undocumented. | UNDERDOCUMENTED | LOW | Document it or leave it as an internal mode; note in the file's header is already present. |
| 26 | `check-conflict-markers.sh` treats a lone `=======` line as a **non-failing note** (`:44-47`, `:104-124`). | Real and intentional (Markdown heading underline). Undocumented in doctrine — a reader of the run output could read the note as a failure. | UNDERDOCUMENTED (limit) | LOW | Covered by the fix for #24 ("ambiguous `=======` is reported, never fails"). |
| 27 | **No doctrine mentions `check-rule-fork.sh`** in `.agents/rules/**` or `AGENTS.md` (only CHANGELOG/completed docs and the optional, commented-out CI step). | The script exists, is a real read-only audit, and its own header explains the ALLOW list / `RULE_FORK_OFF` hatch. It is an adoption-time audit, not a per-PR gate, so absence from the always-on modules is defensible — but nothing tells an adopter it exists. | UNDOCUMENTED (low) | LOW | One line in `documentation.md` or the adapt command's report; not a per-PR obligation. |
| 28 | `check-rule-fork.sh:130` — `ALWAYS_MODULES` names nine modules; the anchor list (`:85-99`) carries 13 anchors. Doctrine makes no claim about which modules are "always applicable". | The `always` predicate is the module's own `Applies when:` line, checked by hand in the script. If a module's `Applies when` changes to/from "always", the literal list silently rots. Not a doctrine mismatch — a maintenance hazard the CHANGELOG already flags as canary-covered. | (clean) | — | none — noted for the owner. |
| 29 | `.agents/rules/algorithm.md:152` names `ALGORITHM_OFF=1`; **no doctrine names `ALGORITHM_FILES`/`ALGORITHM_PLAN_GLOB`** (dup of #9) and the module does not state the gate **refuses with exit 2** on an unresolvable base. | Real (`scripts/check-algorithm.sh:64-72`). The "refuse loudly on a broken base" property is stated in the script header, not the module. | UNDERDOCUMENTED | LOW | One sentence naming exit 2 / refuse-on-broken-base, consistent with the kit's own gate-design rule. |
| 30 | `.agents/rules/quality-bar.md:22-30` references the Algorithm pass and the deletion-candidate list enforced by `check-algorithm.sh`. | Accurate — it defers to `algorithm.md`; no false claim. | — clean | — | none |

### Behaviour that looks wrong (reported, NOT fixed — owner decides)

- **G1 — `check-docs.sh` ref guard diverges from the house pattern.** `check-docs.sh:87` uses
  `git rev-parse --verify` (no `-q`) and exits **1**, while the other four gates use
  `git rev-parse -q --verify` and exit **2** on a non-resolving `--since` base. The CHANGELOG treats
  the exit-2 shape as the house rule ("the same question must get the same answer in every gate").
  Exit 1 here is indistinguishable from "a commit failed the docs check". **Evidence:** run
  `sh scripts/check-docs.sh --since deadbeef` → `check-docs: ref 'deadbeef' not found …` exit 1.
  Not a doctrine lie; a real behavioural inconsistency. **Do not fix in this PR.**

- **G2 — the conflict gate's `--since` scope silently narrows.** It builds `PATHS` from
  `git rev-list "$SINCE"..HEAD` name-only lists and falls back to `.` when empty. If a range's
  commits name only paths that have since been deleted at HEAD, `git grep -- <path>` matches
  nothing and the run reports OK — a clean result about files that no longer exist. Tree mode (what
  CI runs) is unaffected. Flagged for the owner; not fixed.

---

## Ranked top-5 (by blast radius of the lie)

1. **[HIGH] #1** — agent-readiness doctrine promises a CI smoke test that does not exist. This is
   the *most dangerous* class: an agent trusting it will skip the standalone-with-one-key proof,
   which is exactly the dual-mode premise the whole module exists for.
2. **[HIGH] #2** — "generated **and in sync with the API schemas**": the "in sync" half is the part
   that catches drift, and it is not checked. An agent reads "CAUGHT BY CI" over an unchecked risk.
3. **[HIGH] #3** — "or model identifier": model-id hardcoding is the common real-world vendor lock
   (you hardcode `gpt-4o`, not `api.openai.com`), and the gate does not look for it.
4. **[HIGH] #24** — `check-conflict-markers.sh` is a required CI gate that **no rule module
   mentions**, and its escape hatch `CONFLICTS_OFF=1` is named nowhere the agent reads. An agent
   hitting a false-ish flag has no doctrine remedy, which the kit's own hatch doctrine forbids.
5. **[MED] #13 / #19** — plan/spec-home claims overstate the gate ("enforces this" = location only),
   and the lightweight `docs/PLAN.md` path has no spec-gate home while the algorithm gate accepts
   it — a repo can satisfy one gate's plan home and be unsatisfiable in the other.

---

## Clean bills of health (a real finding)

- **`check-spec.sh` vs `spec.md`** — the honest-limits section (`spec.md:88-95`) matches the script's
  own header and behaviour exactly. The module is the model the others should copy.
- **`check-expert-review.sh` vs `workflow.md`** — after PRs #31/#32 the four-point contract in
  `workflow.md:77-94` matches the code line-for-line, including the opt-in sign-off and the absent
  `adr.md` check. Verified by reading `scripts/check-expert-review.sh:197-253`.
- **`check-plan-home.sh` escape hatch** (`PLAN_HOME_ALLOW`, `PLAN_HOME_OFF=1`) — named in
  `workflow.md:53` and real in the script (`:28`, `:75-78`).
- **`check-algorithm.sh` escape hatch** — `ALGORITHM_OFF=1` named in `algorithm.md:152` and real
  (`scripts/check-algorithm.sh:31`).
- **`check-conflict-markers.sh` / `check-agent-readiness.sh` / `check-rule-fork.sh` / `check-docs.sh`
  escape hatches** each exist and are internally consistent; the gaps are documentation, not code.
