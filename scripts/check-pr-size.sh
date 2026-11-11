#!/usr/bin/env sh
# check-pr-size.sh — flags a change too big for one reviewer to read in a sitting (.agents/rules/small-slices.md).
#
# Warns, never fails: it prints `BIG` and writes `big=true` to $GITHUB_OUTPUT so CI can label the PR.
# Docs, lock files, generated agent mirrors and binaries are not counted; they are not what a
# reviewer reads. The limits are a default, not a law: tune them per repo.
#
#   sh scripts/check-pr-size.sh --since <base-sha>
#   SIZE_MAX_LINES=300 SIZE_MAX_FILES=10 (defaults); SIZE_EXCLUDE adds space-separated globs.
set -u

MAX_LINES="${SIZE_MAX_LINES:-300}"
MAX_FILES="${SIZE_MAX_FILES:-10}"
EXCLUDE="docs/* *.md *.mdc .clinerules/* .windsurf/* *.lock package-lock.json pnpm-lock.yaml go.sum ${SIZE_EXCLUDE:-}"
# The globs are matched against paths with `case`, never expanded against the working tree.
set -f

SINCE=""
case "${1:-}" in
  --since) SINCE="${2:-}" ;;
  "") ;;
  *) echo "check-pr-size: unknown argument '$1'" >&2; exit 2 ;;
esac
[ -n "$SINCE" ] || SINCE="$(git merge-base HEAD origin/main 2>/dev/null || git rev-parse HEAD~1)"

lines=0
files=0
tab="$(printf '\t')"
git diff --numstat "$SINCE"...HEAD > "${TMPDIR:-/tmp}/pr-size.$$" || { echo "check-pr-size: cannot diff against '$SINCE'" >&2; exit 2; }
while IFS="$tab" read -r add del path; do
  [ "$add" = "-" ] && continue
  skip=0
  for g in $EXCLUDE; do
    # shellcheck disable=SC2254 # glob match against a single path is intentional
    case "$path" in $g) skip=1; break ;; esac
  done
  [ "$skip" -eq 1 ] && continue
  lines=$((lines + add + del))
  files=$((files + 1))
done < "${TMPDIR:-/tmp}/pr-size.$$"
rm -f "${TMPDIR:-/tmp}/pr-size.$$"

if [ "$lines" -gt "$MAX_LINES" ] || [ "$files" -gt "$MAX_FILES" ]; then
  msg="BIG: $lines changed lines in $files files (limit $MAX_LINES lines / $MAX_FILES files). Split it into smaller slices, or say in the PR body why it can't split. Rule: .agents/rules/small-slices.md"
  echo "check-pr-size: $msg"
  [ -n "${GITHUB_ACTIONS:-}" ] && echo "::warning title=PR too big::$msg"
  [ -n "${GITHUB_OUTPUT:-}" ] && echo "big=true" >> "$GITHUB_OUTPUT"
else
  echo "check-pr-size: OK ($lines changed lines in $files files)"
  [ -n "${GITHUB_OUTPUT:-}" ] && echo "big=false" >> "$GITHUB_OUTPUT"
fi
exit 0
