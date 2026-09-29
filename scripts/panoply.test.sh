#!/usr/bin/env bash
# panoply.test.sh — canary for scripts/panoply.sh.
#
# Why this exists: the kit's own rules require that any gate which pattern-matches must ship a
# fixture that carries every defect it claims to catch, plus a compliant one, and assert
# fail-then-pass. A single manual pass on a real repo cannot distinguish "compliant" from
# "detects nothing" — a check that always exits 0 looks identical to a perfect one.
#
# Asserts every state the doctor can report, by building a throwaway repo per case:
#   current(0) absent(10) partial(11) stale(12) placeholders(13) drifted(14) off(0) not-a-repo(0)
#
#   sh scripts/panoply.test.sh        (run from the kit root; used by CI)
set -u
# pipefail is a bash extension. CI invokes this gate as `sh scripts/panoply.test.sh`, where `sh` is
# dash and `set -o pipefail` is an illegal option that aborts the run before any check executes —
# a gate that cannot start reads as a broken repo rather than a broken check. Enable it only where
# the shell supports it (an `if`, not `A && B || C`, which older shellcheck flags as SC2015).
if (set -o pipefail) 2>/dev/null; then set -o pipefail; fi

KIT="$(cd "$(dirname "$0")/.." && pwd)"
DOC="$KIT/scripts/panoply.sh"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

pass=0; fail=0
_ok()   { pass=$((pass+1)); printf '  ok   %s\n' "$1"; }
_bad()  { fail=$((fail+1)); printf '  FAIL %s — %s\n' "$1" "$2"; }

# assert_exit <name> <expected-code> <dir>
assert_exit() {
  _n="$1"; _want="$2"; _d="$3"
  ( cd "$_d" && sh "$DOC" check ) >/dev/null 2>&1
  _got=$?
  if [ "$_got" = "$_want" ]; then _ok "$_n (exit $_got)"; else _bad "$_n" "want exit $_want, got $_got"; fi
}

_new_repo() {  # _new_repo <name> -> prints path
  _p="$WORK/$1"; mkdir -p "$_p"; ( cd "$_p" && git init -q . && printf 'x\n' > README.md \
    && git add -A && git -c user.email=t@t -c user.name=t commit -qm init ) >/dev/null 2>&1
  printf '%s' "$_p"
}

# A compliant adopter: the triad, no tokens, stamped, mirrors generated and in sync.
_make_adopted() {
  _p="$1"
  cp "$KIT/AGENTS.md" "$_p/AGENTS.md"
  sed -i 's/{{PROJECT_NAME}}/fixture/g' "$_p/AGENTS.md"
  mkdir -p "$_p/docs/claude" "$_p/.claude/rules" "$_p/scripts"
  cp "$KIT/docs/claude/roadmap.md" "$_p/docs/claude/roadmap.md" 2>/dev/null || printf '# roadmap\n' > "$_p/docs/claude/roadmap.md"
  # copy modules and strip every {{TOKEN}} so the fixture is genuinely adapted
  for _m in "$KIT"/.claude/rules/*.md; do
    b="$(basename "$_m")"; sed 's/{{[A-Z_][A-Z0-9_]*}}/fixture/g' "$_m" > "$_p/.claude/rules/$b"
  done
  cp "$KIT/scripts/sync-agents.sh" "$_p/scripts/sync-agents.sh"
  ( cd "$_p" && PANOPLY_SELF=0 sh scripts/sync-agents.sh ) >/dev/null 2>&1
  ( cd "$_p" && sh "$DOC" stamp ) >/dev/null 2>&1
}

echo "panoply.test.sh — kit $("$DOC" version)"

# --- case 1: absent ----------------------------------------------------------------------------
R="$(_new_repo absent)";            assert_exit "absent repo"            10 "$R"
# --- case 2: partial (AGENTS.md only) ----------------------------------------------------------
R="$(_new_repo partial)"; cp "$KIT/AGENTS.md" "$R/AGENTS.md"; sed -i 's/{{PROJECT_NAME}}/p/g' "$R/AGENTS.md"
                                    assert_exit "half-applied repo"      11 "$R"
# --- case 3: unadapted (triad present, tokens left) --------------------------------------------
R="$(_new_repo unadapted)"; _make_adopted "$R"
sed -i 's/fixture/{{PROJECT_NAME}}/' "$R/AGENTS.md"          # re-introduce one token
                                    assert_exit "unfilled placeholders"  13 "$R"
# --- case 4: stale (adapted, no stamp) ---------------------------------------------------------
R="$(_new_repo stale)"; _make_adopted "$R"; rm -f "$R/.panoply-version"
                                    assert_exit "stale (no stamp)"       12 "$R"
# --- case 5: stale (stamp behind) --------------------------------------------------------------
R="$(_new_repo stale2)"; _make_adopted "$R"
sed -i 's/^kit_version: .*/kit_version: v0.0.1/' "$R/.panoply-version"
                                    assert_exit "stale (old version)"    12 "$R"
# --- case 6: drifted mirrors -------------------------------------------------------------------
R="$(_new_repo drifted)"; _make_adopted "$R"
printf '\nhand edit that bypasses the generator\n' >> "$R/GEMINI.md"
                                    assert_exit "drifted mirrors"        14 "$R"
# --- case 7: current ---------------------------------------------------------------------------
R="$(_new_repo current)"; _make_adopted "$R"
                                    assert_exit "compliant adopter"       0 "$R"
# --- case 8: escape hatch ----------------------------------------------------------------------
R="$(_new_repo off)"; ( cd "$R" && PANOPLY_OFF=1 sh "$DOC" check ) >/dev/null 2>&1
_off=$?
# Prefer an if over `A && B || C`: SC2015 (shellcheck <= 0.11) fires on the chain, and CI runs an
# older shellcheck than this box does, so the chain passes locally and fails the PR.
if [ "$_off" = 0 ]; then _ok "PANOPLY_OFF escape hatch (exit 0)"; else _bad "PANOPLY_OFF" "got $_off"; fi
# --- case 9: not a git tree must never block ---------------------------------------------------
R="$WORK/nogit"; mkdir -p "$R";     assert_exit "non-git dir is not blocked" 0 "$R"

echo
if [ "$fail" = 0 ]; then printf 'PANOPLY.TEST: all green (%d checks)\n' "$pass"; exit 0; fi
printf 'PANOPLY.TEST: FAILED (%d ok, %d failed)\n' "$pass" "$fail"; exit 1
