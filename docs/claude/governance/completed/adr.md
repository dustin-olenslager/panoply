# Decision Record

## ADR-0001 — Panoply Optimization: Mandatory PR Gates, Expert Review, Docs Enforcement (2026-08-21)

### Context
Panoply is a provider-neutral agent-governance kit. Currently:
- CI/pre-commit templates exist but are **advisory** — branch protection + required checks must be manually enabled by a human (Step 10 of adapt command)
- Docs-gate (`check-docs.sh`) is in progress (M3 of 3) — enforces worklog presence mechanically
- No structured expert-review protocol exists for non-trivial changes
- The kit's own repo does not dogfood the full enforcement plane

Three escalated conflicts from expert panel:
1. **Branch protection setup**: Auto-API vs Interactive CLI vs Fail-CI
2. **Expert-review gate**: CI artifact check vs Evidence grep vs Trivial escape hatch
3. **Architecture purity**: Port+adapter vs Concrete CI script

### Decision
**Adopt the "Interactive CLI + Evidence Grep + Concrete Script" path:**

1. **Branch protection**: Add `scripts/init-repo-protection.sh` — interactive `gh` CLI command that configures branch protection on the default branch (requires `gh` auth). Fails with clear instructions if `gh` unavailable or unauthenticated. **No auto-API, no CI-fail.** The adapt command (Phase 10) runs this script interactively and reports success/failure.

2. **Expert-review protocol**: Add a **concrete script** `scripts/check-expert-review.sh` that runs in CI and verifies via grep:
   - `plan.md` exists for the PR's feature area
   - `checklist.md` has ≥1 unchecked item at PR open (proves planning happened)
   - `adr.md` has a new section since base branch (proves architectural decision recorded)
   - PR description contains sign-off from ≥2 named personas (Security, Performance, Maintainability, UX, or domain-specific)
   - Trivial changes (single file, ≤15 lines, no schema/API/interface change) skip via label `trivial` or commit message prefix `trivial:`

3. **Architecture**: The expert-review check is a **Frameworks & Drivers** concern (a CI script). The *policy* (what requires review) lives in `AGENTS.md` / `.claude/rules/workflow.md` as a rule. No port/adapter indirection — this is a mechanical gate, not a business rule.

4. **Dogfood**: The kit repo itself enables all gates via this optimization PR.

### Consequences

**Positive:**
- Provider-neutral: `gh` CLI works on GitHub; GitLab/Gitea equivalents can be added later as separate scripts
- No hosted deps, no runtime deps — POSIX sh + `gh` (already in CI images)
- Trivial escape hatch prevents ceremony overload
- Evidence-grep is hard to game (empty ADR section fails; missing plan.md fails)
- Kit repo becomes the reference implementation

**Negative:**
- `gh` CLI dependency for the init script (mitigated: optional, falls back to manual instructions)
- Evidence-grep can be satisfied with boilerplate (mitigated: review culture + adversary-review skill)
- Adds ~2 new scripts to maintain

**Risks & Fallbacks:**
| Risk | Fallback |
|------|----------|
| `gh` auth fails in CI | Script exits 0 with warning; manual step documented |
| Team ignores expert-review label | CI job fails PR; cannot merge |
| Trivial label abused | Audit via `gh pr list --label trivial` quarterly |
| ADR becomes checkbox theater | Adversary-review skill grades ADR quality in review phase |

### Rejected Alternatives

| Alternative | Why Rejected |
|-------------|--------------|
| Auto-API branch protection (Security) | Token management in CI is a security surface; silent failure is dangerous |
| Fail CI until branch protection manual (Platform) | Breaks "drop-in works" promise; new adopters hit wall immediately |
| Port+adapter for expert review (Arch Guardian) | Over-engineering for a mechanical gate; no business rule varies by provider |
| No trivial escape hatch (QA) | Small fixes (typo, version bump) would need full ceremony — unsustainable |

### Migration
- Phase 1: Add `init-repo-protection.sh` + wire into adapt Phase 10
- Phase 2: Add `check-expert-review.sh` + wire into `ci-verify.yml` template
- Phase 3: Update `workflow.md` + `AGENTS.md` with expert-review policy
- Phase 4: Run full dogfood on kit repo (this PR)
- Phase 5: Archive plan, update roadmap, completed-features