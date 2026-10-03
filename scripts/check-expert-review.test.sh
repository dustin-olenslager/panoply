#!/usr/bin/env sh
# check-expert-review.test.sh — canary for the expert-review gate.
#
# The gate had no test at all, which is how its fail-open on an unresolvable diff base went unnoticed:
# `git rev-list <bad-ref>..HEAD` errors, the loop body never runs, and the gate reports OK. In CI that
# is a gate that silently stops guarding the checkout it exists to guard.
#
# Asserts both directions, per the kit's gate doctrine: a missing base REFUSES (exit 2, not 0), a real
# base behaves, and the escape hatch lifts it. POSIX sh, no runtime deps.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
GATE="$HERE/check-expert-review.sh"
pass=0
fail=0

ok()  { pass=$((pass+1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail+1)); printf '  FAIL %s\n' "$1"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

mk_repo() {
  r="$TMP/$1"; mkdir -p "$r/scripts"
  cp "$GATE" "$r/scripts/"
  git -C "$r" init -q
  git -C "$r" -c user.email=t@t -c user.name=t commit -q --allow-empty -m "chore: init"
  printf '%s\n' "$r"
}

root_sha() { git -C "$1" rev-list --max-parents=0 HEAD; }

# --- case 1: an unresolvable base REFUSES (the regression this file exists for) ---
r="$(mk_repo bad-base)"
out="$( ( cd "$r" && sh scripts/check-expert-review.sh --since deadbeefdeadbeef ) 2>&1 )" && rc=ok || rc=$?
if [ "$rc" = "2" ]; then ok "unresolvable --since base refuses with exit 2 (was: silently OK)"
else bad "unresolvable base must exit 2, got '$rc' — a gate that reports OK here guards nothing"; fi
if printf '%s' "$out" | grep -q "does not resolve"; then ok "refusal names the real cause"
else bad "refusal message does not explain the unresolvable base: $out"; fi

# --- case 2: a resolvable base does NOT produce the refusal (positive control) ---
r="$(mk_repo good-base)"; base="$(root_sha "$r")"
mkdir -p "$r/docs/claude"; printf -- '- note\n' > "$r/docs/claude/worklog.md"
printf 'a\n' > "$r/planish.md"
git -C "$r" add -A; git -C "$r" -c user.email=t@t -c user.name=t commit -q -m "docs: note"
out="$( ( cd "$r" && sh scripts/check-expert-review.sh --since "$base" ) 2>&1 )" && rc=ok || rc=$?
if [ "$rc" != "2" ]; then ok "a resolvable base does not trigger the refusal (exit $rc)"
else bad "resolvable base wrongly refused: $out"; fi

# --- case 3: the escape hatch lifts the gate ---
r="$(mk_repo hatch)"
if ( cd "$r" && EXPERT_REVIEW_OFF=1 sh scripts/check-expert-review.sh --since deadbeefdeadbeef >/dev/null 2>&1 ); then
  ok "EXPERT_REVIEW_OFF=1 lifts the gate (declared exception)"
else bad "escape hatch did not lift the gate"; fi

printf '\ncheck-expert-review canary: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
