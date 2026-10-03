#!/usr/bin/env sh
# check-spec.test.sh — canary for check-spec.sh.
#
# Why this exists: a pattern-matching gate that only ever reports "OK" looks identical to a gate that
# works. This asserts BOTH directions — a structural change with no spec is REFUSED, a spec carrying an
# unresolved marker is REFUSED, and a compliant spec PASSES — plus the exemptions and the escape hatch,
# so "detects correctly" is distinguishable from "blocks nothing" and from "blocks everything".
#
# THE TRAP THIS CANARY MUST AVOID (learned by the algorithm canary, which shipped it once):
#   1. A fixture helper that prints diagnostics on STDOUT while being called from inside `mkrepo`, whose
#      stdout IS the fixture path, corrupts the captured path and every case fails for a reason unrelated
#      to the gate. Rule: helpers mkrepo calls write to STDERR only, and mkrepo asserts its own stdout.
#   2. Cases driving the gate's default `git` mode depend on the ambient git state of the machine that
#      runs them. Rule: every case passes an EXPLICIT base (`--since <sha>`), so the comparison is pinned
#      by the test rather than inferred from HEAD.
#   Plus the one that matters most here: case 6 asserts the gate CANNOT BLOCK ITS OWN REMEDY, because
#   this gate's remedy is writing a file and a gate that refuses that write is unsatisfiable.
#
#   sh scripts/check-spec.test.sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GATE="$ROOT/scripts/check-spec.sh"

TMP="$(mktemp -d 2>/dev/null || mktemp -d -t spec-canary)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0
ok()  { pass=$((pass + 1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL %s\n' "$1"; }

# Make a scratch repo seeded with a base commit, and print its path. Prints ONE clean line on stdout;
# diagnostics go to stderr. Everything is pinned — identity, no hooks, no global config — so the canary
# inherits nothing from the machine it runs on.
mkrepo() {
  d="$TMP/$1"
  mkdir -p "$d/scripts"
  git -C "$d" init -q 2>/dev/null || { printf 'cannot init git repo\n' >&2; exit 2; }
  git -C "$d" config user.email canary@example.invalid
  git -C "$d" config user.name canary
  git -C "$d" config commit.gpgsign false
  git -C "$d" config core.hooksPath /dev/null
  git -C "$d" symbolic-ref HEAD refs/heads/main
  cp "$GATE" "$d/scripts/check-spec.sh"
  printf 'base\n' > "$d/README.md"
  git -C "$d" add -A
  cmit "$d" base || exit 2
  case "$d" in
    ""|*"
"*) printf 'canary fixture broken: path is not one clean line: %s\n' "$d" >&2; exit 2 ;;
  esac
  printf '%s' "$d"
}

# Commit inside a fixture and ASSERT it landed. Prints NOTHING on success.
cmit() {
  d="$1"; msg="$2"
  before="$(git -C "$d" rev-list --count HEAD 2>/dev/null || echo 0)"
  ( cd "$d" && git commit -q --no-verify -m "$msg" ) >/dev/null 2>&1 || true
  after="$(git -C "$d" rev-list --count HEAD 2>/dev/null || echo 0)"
  if [ "$after" -le "$before" ]; then
    printf 'canary fixture: commit did not land in %s (%s -> %s)\n' "$d" "$before" "$after" >&2
    return 1
  fi
  return 0
}

# The root-commit SHA of a fixture — the pinned diff base every case uses.
root_sha() { git -C "$1" rev-list --max-parents=0 HEAD 2>/dev/null | head -1; }

# Run the gate against a fixture with an EXPLICIT base. Echoes ok / fail-nospec / fail-unresolved
# / fail-unresolvable / fail-errored. A refusal is a finding; an unresolvable base is a broken check; a
# gate error is a broken gate — conflating them is how an always-blocking gate passes a naive test.
gate_at() {
  d="$1"; base="$2"
  out="$( ( cd "$d" && sh scripts/check-spec.sh --since "$base" ) 2>&1 )" && { printf 'ok'; return 0; }
  case "$out" in
    *"has no spec"*)            printf 'fail-nospec' ;;
    *"unresolved ambiguity"*)   printf 'fail-unresolved' ;;
    *"does not resolve"*|*"no parent commit"*) printf 'fail-unresolvable' ;;
    *)                          printf 'fail-errored' ;;
  esac
}

# Does the refusal name the remedy? A gate that stops an agent without telling it the way forward just
# produces a retry loop.
gate_at_msg() { ( cd "$1" && sh scripts/check-spec.sh --since "$2" ) 2>&1 | grep -q "$3"; }

# A minimal compliant spec body — one story, one scenario, one requirement, no marker.
compliant_spec() {
  cat > "$1" <<'SPEC'
# Spec: thing

## Goal
A caller can do the thing.

## User stories
### US-1 — do the thing (P1)

- **Independent test:** run the one command and see the thing happen.
- **Acceptance scenarios:**
  1. **Given** nothing, **when** the command runs, **then** the thing exists.

## Requirements
- **FR-001**: The system MUST do the thing.
SPEC
}

# --- case 1: structural change, no spec → REFUSED ---------------------------
r="$(mkrepo fail-no-spec)"; base="$(root_sha "$r")"
mkdir -p "$r/src"
printf 'x\n' > "$r/src/thing.ts"
git -C "$r" add -A; cmit "$r" "feat: thing" || exit 2
rc="$(gate_at "$r" "$base")"
if [ "$rc" = "fail-nospec" ]; then ok "structural change with no spec is refused"
else bad "expected a refusal, got '$rc'"; fi
if gate_at_msg "$r" "$base" "spec.md"; then ok "refusal names the remedy (no retry loop)"
else bad "refusal does not name the remedy"; fi

# --- case 2: spec carrying an unresolved marker → REFUSED -------------------
r="$(mkrepo fail-unresolved)"; base="$(root_sha "$r")"
mkdir -p "$r/src" "$r/docs/agents/core/thing"
printf 'y\n' > "$r/src/thing.ts"
cat > "$r/docs/agents/core/thing/spec.md" <<'SPEC'
# Spec: thing
- **FR-002**: The system MUST retain data for [NEEDS CLARIFICATION: how long?]
SPEC
git -C "$r" add -A; cmit "$r" "feat: thing with open question" || exit 2
rc="$(gate_at "$r" "$base")"
if [ "$rc" = "fail-unresolved" ]; then ok "unresolved [NEEDS CLARIFICATION] is refused"
else bad "expected an ambiguity refusal, got '$rc'"; fi
if gate_at_msg "$r" "$base" "two legal"; then ok "ambiguity refusal names both settlements"
else bad "ambiguity refusal does not name the remedy"; fi

# --- case 3: same change, marker resolved → PASS (positive control) ---------
compliant_spec "$r/docs/agents/core/thing/spec.md"
git -C "$r" add -A; cmit "$r" "docs: resolve the question" || exit 2
rc="$(gate_at "$r" "$base")"
if [ "$rc" = "ok" ]; then ok "resolved spec passes (positive control)"
else bad "a resolved spec must pass — a gate that blocks its own remedy is unsatisfiable (got '$rc')"; fi

# --- case 4: docs-only change → PASS (exemption) ----------------------------
r="$(mkrepo pass-docs-only)"; base="$(root_sha "$r")"
printf '# Notes\n\nA copy change.\n' > "$r/NOTES.md"
git -C "$r" add -A; cmit "$r" "docs: notes" || exit 2
rc="$(gate_at "$r" "$base")"
if [ "$rc" = "ok" ]; then ok "docs-only change passes (not structural)"
else bad "docs-only change must not need a spec (got '$rc')"; fi

# --- case 5: escape hatch actually lifts the gate ---------------------------
r="$(mkrepo pass-escape-hatch)"; base="$(root_sha "$r")"
mkdir -p "$r/src"; printf 'z\n' > "$r/src/other.ts"
git -C "$r" add -A; cmit "$r" "feat: other" || exit 2
if ( cd "$r" && SPEC_OFF=1 sh scripts/check-spec.sh --since "$base" >/dev/null 2>&1 ); then
  ok "SPEC_OFF=1 lifts the gate"
else bad "escape hatch did not lift the gate"; fi

# --- case 6: THE GATE MUST NOT BLOCK ITS OWN REMEDY -------------------------
# The remedy for this gate is WRITING A FILE, so this is the case that matters most: refuse, apply the
# remedy, allow — and it must close in ONE session without a TTL or a cache to wait out.
r="$(mkrepo pass-remedy-roundtrip)"; base="$(root_sha "$r")"
mkdir -p "$r/lib" "$r/docs/agents/core/sub"
printf 'a\n' > "$r/lib/a.ts"
git -C "$r" add -A; cmit "$r" "feat: a" || exit 2
first="$(gate_at "$r" "$base")"
compliant_spec "$r/docs/agents/core/sub/spec.md"
git -C "$r" add -A; cmit "$r" "docs: spec" || exit 2
second="$(gate_at "$r" "$base")"
if [ "$first" = "fail-nospec" ] && [ "$second" = "ok" ]; then ok "refuse → apply the remedy → allow (round trip)"
else bad "remedy round trip broken (first='$first' second='$second')"; fi

# --- case 7: --staged reads the index (the pre-commit path) -----------------
r="$(mkrepo staged-mode)"
mkdir -p "$r/src"; printf 'b\n' > "$r/src/b.ts"
git -C "$r" add -A
out="$( ( cd "$r" && sh scripts/check-spec.sh --staged ) 2>&1 )" && rc=ok || rc=refused
if [ "$rc" = "refused" ] && printf '%s' "$out" | grep -q "has no spec"; then
  ok "--staged refuses an unspecified staged change"
else bad "--staged: expected a refusal, got '$rc' / $(printf '%s' "$out" | head -1)"; fi

# --- case 8: a spec added in the SAME change satisfies it -------------------
# The pre-commit path must accept a spec that is staged but not yet committed — otherwise the gate is
# unpassable in the one workflow an agent actually uses.
r="$(mkrepo pass-spec-same-change)"
mkdir -p "$r/src" "$r/docs/agents/core/same"
printf 'c\n' > "$r/src/c.ts"
compliant_spec "$r/docs/agents/core/same/spec.md"
git -C "$r" add -A
if ( cd "$r" && sh scripts/check-spec.sh --staged >/dev/null 2>&1 ); then
  ok "a spec staged in the same change satisfies --staged"
else bad "same-change spec was not accepted by --staged (the gate is unpassable)"; fi

# --- case 9: the gate must not mutate the repo it judges --------------------
r="$(mkrepo no-mutation)"; base="$(root_sha "$r")"
mkdir -p "$r/src" "$r/docs/agents/core/x"
printf 'd\n' > "$r/src/d.ts"
compliant_spec "$r/docs/agents/core/x/spec.md"
git -C "$r" add -A; cmit "$r" "feat: d" || exit 2
before="$(git -C "$r" status --porcelain)"
( cd "$r" && sh scripts/check-spec.sh --since "$base" >/dev/null 2>&1 ) || true
after="$(git -C "$r" status --porcelain)"
if [ "$before" = "$after" ]; then ok "gate does not mutate the tree it judges"
else bad "gate mutated the repo: '$before' -> '$after'"; fi

# --- case 10: --since with an empty base fails loudly (never checks nothing) -
r="$(mkrepo empty-base)"
if ( cd "$r" && sh scripts/check-spec.sh --since "" >/dev/null 2>&1 ); then
  bad "--since '' must refuse, not silently check nothing"
else ok "--since with an empty base refuses"; fi

# --- case 11: THE GATE MUST NOT MATCH ITS OWN CONVENTION META-SYNTAX ---------
# A spec that DISCUSSES the marker in prose (a template, a rule module, a spec quoting the convention)
# must pass. A gate that flags its own documentation reports every correct repo as broken — the
# always-red failure the kit's placeholder scan already hit once.
r="$(mkrepo pass-metasyntax)"; base="$(root_sha "$r")"
mkdir -p "$r/src" "$r/docs/agents/core/meta"
printf 'e\n' > "$r/src/e.ts"
cat > "$r/docs/agents/core/meta/spec.md" <<'SPEC'
# Spec: meta

## Requirements
- **FR-001**: An unknown is written `[NEEDS CLARIFICATION: …]` in a draft spec.
- **FR-002**: A template uses the form [NEEDS CLARIFICATION: <the question>] as its placeholder.
SPEC
git -C "$r" add -A; cmit "$r" "feat: meta" || exit 2
rc="$(gate_at "$r" "$base")"
if [ "$rc" = "ok" ]; then ok "a spec discussing the marker convention is NOT flagged (no self-match)"
else bad "gate matched its own metasyntax ('$rc') — every correct repo would read as broken"; fi

# --- case 12: a metasyntax marker must NOT hide a real one ------------------
r="$(mkrepo fail-real-marker-among-metasyntax)"; base="$(root_sha "$r")"
mkdir -p "$r/src" "$r/docs/agents/core/both"
printf 'f\n' > "$r/src/f.ts"
cat > "$r/docs/agents/core/both/spec.md" <<'SPEC'
# Spec: both
- **FR-001**: An unknown is written `[NEEDS CLARIFICATION: …]`.
- **FR-002**: The system MUST retain data for [NEEDS CLARIFICATION: 90 days or 7 years?]
SPEC
git -C "$r" add -A; cmit "$r" "feat: both" || exit 2
rc="$(gate_at "$r" "$base")"
if [ "$rc" = "fail-unresolved" ]; then ok "a real marker beside metasyntax is still refused"
else bad "real marker was hidden by metasyntax in the same file (got '$rc')"; fi

printf '\ncheck-spec canary: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
