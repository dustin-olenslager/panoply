#!/usr/bin/env sh
# check-pr-size.test.sh — canary for check-pr-size.sh: a small change passes, a big one is flagged,
# and excluded paths (docs, lock files) never count toward the limit.
#
#   sh scripts/check-pr-size.test.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
GATE="$HERE/check-pr-size.sh"
SANDBOX="$(mktemp -d 2>/dev/null || mktemp -d -t size-canary)"
trap 'rm -rf "$SANDBOX" "$SANDBOX.out"' EXIT INT TERM

pass=0
fail=0
want_in() {
  if printf '%s' "$2" | grep -q "$3"; then pass=$((pass + 1)); printf '  ok   %s\n' "$1"
  else fail=$((fail + 1)); printf '  FAIL %s (missing %s in: %s)\n' "$1" "$3" "$2"; fi
}

cd "$SANDBOX" || exit 1
git init -q . && git config user.email t@t && git config user.name t
echo base > a.txt && git add -A && git commit -qm base
BASE="$(git rev-parse HEAD)"

lines() { i=0; while [ "$i" -lt "$1" ]; do echo "line $i"; i=$((i + 1)); done; }

lines 50 > small.py && git add -A && git commit -qm small
out="$(SIZE_MAX_LINES=300 sh "$GATE" --since "$BASE")"
want_in "1 small change is OK" "$out" "OK (50 changed lines in 1 files)"

lines 400 > big.py && git add -A && git commit -qm big
out="$(GITHUB_OUTPUT="$SANDBOX.out" sh "$GATE" --since "$BASE")"
want_in "2 over the line limit is BIG" "$out" "BIG: 450 changed lines"
want_in "3 BIG writes big=true" "$(cat "$SANDBOX.out")" "big=true"

git reset -q --hard "$BASE"
mkdir -p docs && lines 900 > docs/guide.md && lines 900 > uv.lock && lines 20 > code.py && git add -A && git commit -qm docs
out="$(sh "$GATE" --since "$BASE")"
want_in "4 docs and lock files do not count" "$out" "OK (20 changed lines in 1 files)"

git reset -q --hard "$BASE"
for n in 1 2 3 4 5 6 7 8 9 10 11; do echo x > "f$n.py"; done && git add -A && git commit -qm many
out="$(sh "$GATE" --since "$BASE")"
want_in "5 over the file limit is BIG" "$out" "BIG: 11 changed lines in 11 files"

out="$(sh "$GATE" --since "$BASE"; echo "exit=$?")"
want_in "6 BIG never fails the build" "$out" "exit=0"

# Excludes must match nested paths even when the repo has files the globs would expand to.
git reset -q --hard "$BASE"
mkdir -p docs/area sub && echo top > README.md && lines 400 > docs/area/deep.md && lines 400 > sub/NOTES.md && lines 10 > code.py && git add -A && git commit -qm nested
out="$(sh "$GATE" --since "$BASE")"
want_in "7 nested docs are excluded too" "$out" "OK (10 changed lines in 1 files)"

out="$(SIZE_EXCLUDE='code.py' sh "$GATE" --since "$BASE")"
want_in "8 SIZE_EXCLUDE adds a glob" "$out" "OK (0 changed lines in 0 files)"

echo "check-pr-size canary: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
