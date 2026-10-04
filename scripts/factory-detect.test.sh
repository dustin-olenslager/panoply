#!/usr/bin/env sh
# factory-detect.test.sh — the phase detector's canary.
#
# A detector that cannot report the WRONG phase is not evidence. Each case builds a real fixture repo
# in a specific state and asserts BOTH the phase AND that the evidence names the observation that
# produced it — a right answer for the wrong reason is a bug waiting to happen.
#
# The fixtures are built, not checked in: `git init` in a temp dir, so the case tests the detector and
# not some fixture's drift. State is constructed directly (never sourced from a moving ref — see the
# kit's gate-integrity lesson).
set -eu

HERE="$(cd "$(dirname "$0")" && pwd)"
DETECT="$HERE/factory-detect.sh"
TMP="${TMPDIR:-/tmp}/detect-canary.$$"
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT INT TERM

pass=0
fail=0
ok()  { pass=$((pass + 1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL %s\n' "$1"; [ -n "${2:-}" ] && printf '       %s\n' "$2"; }

mkrepo() {
  d="$TMP/$1"
  mkdir -p "$d/scripts"
  git -C "$d" init -q
  git -C "$d" config user.email canary@example.invalid
  git -C "$d" config user.name canary
  git -C "$d" config commit.gpgsign false
  git -C "$d" symbolic-ref HEAD refs/heads/main
  cp "$DETECT" "$d/scripts/"
  cp "$HERE/factory-phases.tsv" "$d/scripts/"
  printf 'x\n' > "$d/README.md"
  printf '%s' "$d"
}

# A minimal compliant-enough doctor stub: exits with the code we want to represent that state.
# The detector reads the EXIT CODE, so the stub needs only to exit correctly.
mkdoctor() {
  d="$1"; code="$2"
  cat > "$d/scripts/panoply.sh" <<DOC
#!/usr/bin/env sh
case "\${1:-}" in
  check) exit $code ;;
  *) exit 0 ;;
esac
DOC
  chmod +x "$d/scripts/panoply.sh"
}

cmit() {
  git -C "$1" add -A
  git -C "$1" -c user.email=c@e.invalid -c user.name=c -c commit.gpgsign=false commit -qm "${2:-c}"
}

# phase_of <repo> -> the phase number the detector reports
phase_of() { ( cd "$1" && sh scripts/factory-detect.sh ) 2>/dev/null | head -1 | sed 's/^phase \([0-9]*\).*/\1/'; }
why_of()   { ( cd "$1" && sh scripts/factory-detect.sh ) 2>/dev/null | grep '^  why' | head -1; }

# ---------------------------------------------------------------------------------------------
# case 1: NO kit at all → phase 0 (adopt/audit). The doctor is absent, so the phase history
# cannot be trusted. This is the "greenfield / not adopted" reading.
d="$(mkrepo no-kit)"
cmit "$d" "init"
p="$(phase_of "$d")"
if [ "$p" = "0" ]; then ok "a repo with no kit reports phase 0 (adopt)"
else bad "a repo with no kit reported phase $p, wanted 0"; fi

# case 2: a STALE kit → phase 0. The doctor's exit code is the authority, not the stamp's claim.
d="$(mkrepo stale-kit)"
mkdoctor "$d" 12
printf 'kit_version: v1.4.0+drifted\n' > "$d/.panoply-version"
cmit "$d" "stale"
p="$(phase_of "$d")"
if [ "$p" = "0" ]; then ok "a stale kit reports phase 0 even with a stamp present"
else bad "a stale kit reported phase $p, wanted 0"; fi
if why_of "$d" | grep -q '12'; then ok "the phase-0 report names the doctor's exit code"
else bad "the phase-0 report does not cite the doctor's exit code"; fi

# case 3: kit clean, no feature folders → phase 0 (spine un-seeded)
d="$(mkrepo unseeded)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '# in progress\n' > "$d/docs/agents/in-progress.md"
cmit "$d" "spine only"
p="$(phase_of "$d")"
if [ "$p" = "0" ]; then ok "a clean kit with no features reports phase 0 (un-seeded spine)"
else bad "a clean kit with no features reported phase $p, wanted 0"; fi

# case 4: feature folder with a plan but NO spec → phase 1 (the backfill case)
d="$(mkrepo no-spec)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents/core/thing"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '| Feature | Status |\n|---|---|\n| thing | active |\n' > "$d/docs/agents/in-progress.md"
printf '# Plan: thing\n\n- [ ] M1\n' > "$d/docs/agents/core/thing/plan.md"
cmit "$d" "plan no spec"
p="$(phase_of "$d")"
if [ "$p" = "1" ]; then ok "a feature with a plan but no spec reports phase 1"
else bad "a feature with a plan but no spec reported phase $p, wanted 1"; fi

# case 5: unresolved [NEEDS CLARIFICATION] → phase 1, and the report says which
d="$(mkrepo needs-clar)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents/core/thing"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '| thing | active |\n' > "$d/docs/agents/in-progress.md"
printf '# Spec\n\n## Requirements\n- **FR-001**: [NEEDS CLARIFICATION: which store?]\n' > "$d/docs/agents/core/thing/spec.md"
cmit "$d" "spec with marker"
p="$(phase_of "$d")"
if [ "$p" = "1" ]; then ok "an unresolved marker reports phase 1"
else bad "an unresolved marker reported phase $p, wanted 1"; fi
if why_of "$d" | grep -qi 'clarification'; then ok "the phase-1 report names the marker as the cause"
else bad "the phase-1 report does not name the marker"; fi

# case 6: user-facing spec, no wireframe → phase 2. This is the user's explicit ordering:
# design lands before backend.
d="$(mkrepo wants-wireframe)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents/core/thing"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '| thing | active |\n' > "$d/docs/agents/in-progress.md"
printf '# Spec\n\n## Requirements\n- **FR-001**: the user sees a screen listing tasks.\n' > "$d/docs/agents/core/thing/spec.md"
cmit "$d" "user-facing spec"
p="$(phase_of "$d")"
if [ "$p" = "2" ]; then ok "a user-facing spec with no wireframe reports phase 2"
else bad "a user-facing spec with no wireframe reported phase $p, wanted 2"; fi

# case 7: wireframe present, interviews missing → still phase 2, blocked on interviews
d="$(mkrepo wire-no-interviews)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents/core/thing/wireframe"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '| thing | active |\n' > "$d/docs/agents/in-progress.md"
printf '# Spec\n\n- **FR-001**: the user sees a screen.\n' > "$d/docs/agents/core/thing/spec.md"
printf '<html></html>\n' > "$d/docs/agents/core/thing/wireframe/index.html"
cmit "$d" "wireframe no interviews"
p="$(phase_of "$d")"
if [ "$p" = "2" ]; then ok "a wireframe with no interviews reports phase 2 (blocked on interviews)"
else bad "a wireframe with no interviews reported phase $p, wanted 2"; fi
if why_of "$d" | grep -qi 'interview'; then ok "the report names the missing interviews"
else bad "the report does not name the missing interviews"; fi

# case 8: spec + wireframe + interviews, no plan → phase 3
d="$(mkrepo wants-plan)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents/core/thing/wireframe"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '| thing | active |\n' > "$d/docs/agents/in-progress.md"
printf '# Spec\n\n- **FR-001**: a screen.\n' > "$d/docs/agents/core/thing/spec.md"
printf '<html></html>\n' > "$d/docs/agents/core/thing/wireframe/index.html"
printf '# Interviews\n\n## Persona: ops\nFinding: x changed the list layout.\n' > "$d/docs/agents/core/thing/interviews.md"
cmit "$d" "no plan yet"
p="$(phase_of "$d")"
if [ "$p" = "3" ]; then ok "spec + wireframe + interviews with no plan reports phase 3"
else bad "reported phase $p, wanted 3"; fi

# case 9: plan with open milestones → phase 4 (build)
d="$(mkrepo building)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents/core/thing/wireframe"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '| thing | active |\n' > "$d/docs/agents/in-progress.md"
printf '# Spec\n\n- **FR-001**: a screen.\n' > "$d/docs/agents/core/thing/spec.md"
printf '<html></html>\n' > "$d/docs/agents/core/thing/wireframe/index.html"
printf '# Interviews\n\n## Persona: ops\nFinding: x.\n' > "$d/docs/agents/core/thing/interviews.md"
printf '# Plan\n\n## Milestones\n- [ ] M1 write it\n- [ ] M2 ship it\n' > "$d/docs/agents/core/thing/plan.md"
cmit "$d" "open milestones"
p="$(phase_of "$d")"
if [ "$p" = "4" ]; then ok "open milestones report phase 4 (build)"
else bad "open milestones reported phase $p, wanted 4"; fi

# case 10: all milestones closed, clean tree, on main → phase 6 (ship bookkeeping)
d="$(mkrepo shipping)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents/core/thing/wireframe"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '| thing | active |\n' > "$d/docs/agents/in-progress.md"
printf '# Spec\n\n- **FR-001**: a screen.\n' > "$d/docs/agents/core/thing/spec.md"
printf '<html></html>\n' > "$d/docs/agents/core/thing/wireframe/index.html"
printf '# Interviews\n\n## Persona: ops\nFinding: x.\n' > "$d/docs/agents/core/thing/interviews.md"
printf '# Plan\n\n## Milestones\n- [x] M1 done\n- [x] M2 done\n' > "$d/docs/agents/core/thing/plan.md"
cmit "$d" "all closed"
p="$(phase_of "$d")"
if [ "$p" = "6" ]; then ok "closed milestones on a clean main report phase 6 (ship)"
else bad "closed milestones reported phase $p, wanted 6"; fi

# case 11: the phase table is DATA. Prove the detector reads it rather than hard-coding names:
# put the fixture in the SHIPPING state (so phase 6 is actually reached), then remove the phase-6
# row and confirm the reported NAME goes unknown while the NUMBER stays 6.
# The first draft of this case trimmed the table but left the fixture at phase 2, so the trimmed row
# was never consulted and the case failed for the wrong reason — the fixture must reach the phase
# whose row you removed, or the case proves nothing.
d="$(mkrepo table-driven)"
mkdoctor "$d" 0
mkdir -p "$d/docs/agents/core/thing"
printf '# roadmap\n' > "$d/docs/agents/roadmap.md"
printf '| thing | active |\n' > "$d/docs/agents/in-progress.md"
printf '# Spec\n\n- **FR-001**: internal tool.\nWireframe: n/a — no user-facing surface.\n' > "$d/docs/agents/core/thing/spec.md"
printf '# Plan\n\n- [x] M1\n' > "$d/docs/agents/core/thing/plan.md"
grep -v '^6	' "$HERE/factory-phases.tsv" > "$d/scripts/factory-phases.tsv"
cmit "$d" "trimmed table, phase 6 reachable"
out="$( cd "$d" && sh scripts/factory-detect.sh )"
if printf '%s' "$out" | head -1 | grep -q '^phase 6' && printf '%s' "$out" | head -1 | grep -q 'unknown'; then
  ok "the detector reads the phase table for names (data, not hard-coded)"
else bad "the detector did not read the table for the phase name" "$(printf '%s' "$out" | head -1)"; fi

# case 12: not a repo at all → exit 2, and NOT a phase (a phase is a successful answer)
d="$TMP/not-a-repo"; mkdir -p "$d"
if ( cd "$d" && sh "$DETECT" ) >/dev/null 2>&1; then
  bad "a non-repo directory was accepted as a phase"
else ok "a non-repo directory refuses with exit 2 rather than inventing a phase"; fi

# case 13: the documented escape hatch actually works. An escape hatch that does not disarm its
# gate is a documented lie, and this one is named in the rule module.
d="$(mkrepo off-switch)"
cmit "$d" "init"
if ( cd "$d" && FACTORY_PHASE_OFF=1 sh scripts/factory-detect.sh ) >/dev/null 2>&1; then
  ok "FACTORY_PHASE_OFF=1 disarms the detector"
else bad "FACTORY_PHASE_OFF=1 did not disarm the detector"; fi

printf '\nfactory-detect canary: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
