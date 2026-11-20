#!/usr/bin/env sh
# queue.sh — the work queue, one file per task: docs/agents/in-progress.d/<slug>.md.
#
# Why fragments: one shared queue table made every merge conflict every other open PR that touched
# it, and each repair cost a rebase and a CI run (dev-kit, 2026-11-20: 5 of 8 open PRs blocked by that
# file alone while 40 headless jobs a day each opened PRs). A PR now adds, edits or deletes ONLY its
# own fragment, so two PRs that each change a queue item merge in either order with no conflict.
# The table people read is rendered from the fragments on demand and is never committed — a
# committed render would be the same shared file again.
#
#   sh scripts/queue.sh render             # the queue as markdown, in order (the old in-progress.md shape)
#   sh scripts/queue.sh list               # one line per fragment: section<TAB>order<TAB>slug<TAB>status<TAB>item
#   sh scripts/queue.sh check              # every fragment is valid (CI)
#   sh scripts/queue.sh check --since SHA  # ...and the PR does not edit the retired in-progress.md
#
# Fragment shape (keys are one line each; the body after the second `---` is the Notes / next step):
#
#   ---
#   order: 40                 # required integer; lower is nearer the top; ties break by file name
#   id: 71                    # optional label shown in the # column (the file name is the unique key)
#   item: What a user can do when this ships
#   area: governance
#   initiative: DevKit front door
#   plan: `governance/live-card-status/plan.md`
#   status: In review
#   ---
#   Exact next step: the file to open, the command to run, the blocker.
#
#   section: blocked  -> also needs `blocked-on:` and `since:` (no status needed)
#   section: parked   -> also needs `why:` and `revisit:` (no status needed)
#   `req:` and `risk:` are accepted for loop drivers and are not rendered.
#
# The directory's README.md is the page around the tables: its `<!-- queue:active -->`,
# `<!-- queue:blocked -->` and `<!-- queue:parked -->` lines are replaced by the rendered tables.
#
# Config: QUEUE_DIR (default docs/agents/in-progress.d), QUEUE_LEGACY (default docs/agents/in-progress.md).
# A repo without QUEUE_DIR has not migrated: render prints QUEUE_LEGACY and check passes.
set -eu
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
DIR="${QUEUE_DIR:-docs/agents/in-progress.d}"
LEGACY="${QUEUE_LEGACY:-docs/agents/in-progress.md}"
TAB="$(printf '\t')"

fragments() {
  for f in "$DIR"/*; do
    [ -f "$f" ] || continue
    case "$(basename "$f")" in README.md|.*) continue;; esac
    printf '%s\n' "$f"
  done
}

# One TSV record per fragment, sorted: section, order, slug, id, item, area, initiative, plan, status,
# notes, blocked-on, since, why, revisit. Values have tabs flattened and the body joined to one line.
records() {
  _files="$(fragments)"
  [ -n "$_files" ] || return 0
  # shellcheck disable=SC2086 # one path per word is intended; fragment names are [a-z0-9-] only
  awk '
    function flush() {
      if (file == "") return
      sec = (k["section"] == "") ? "active" : k["section"]
      rank = (sec == "active") ? 1 : (sec == "blocked") ? 2 : 3
      printf "%d\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", rank, k["order"], slug, k["id"], \
        k["item"], k["area"], k["initiative"], k["plan"], k["status"], body, \
        k["blocked-on"], k["since"], k["why"], k["revisit"]
    }
    FNR == 1 {
      flush(); file = FILENAME; slug = FILENAME; sub(/^.*\//, "", slug); sub(/\.md$/, "", slug)
      delete k; body = ""; fence = 0
    }
    { gsub(/\t/, " ") }
    /^---[ ]*$/ && fence < 2 { fence++; next }
    fence == 1 {
      key = $0; sub(/:.*/, "", key); val = $0; sub(/^[^:]*:[ ]*/, "", val); sub(/[ ]+$/, "", val)
      k[key] = val; next
    }
    fence == 2 {
      line = $0; sub(/^[ ]+/, "", line); sub(/[ ]+$/, "", line)
      if (line != "") body = (body == "") ? line : body " " line
    }
    END { flush() }
  ' $_files | LC_ALL=C sort -t "$TAB" -k1,1n -k2,2n -k3,3
}

cmd_list() {
  records | awk -F '\t' '{ s = ($1 == 1) ? "active" : ($1 == 2) ? "blocked" : "parked"
                           printf "%s\t%s\t%s\t%s\t%s\n", s, $2, $3, $9, $5 }'
}

cmd_render() {
  if [ ! -d "$DIR" ]; then
    [ -f "$LEGACY" ] && cat "$LEGACY"
    return 0
  fi
  _recs="$(mktemp)"; trap 'rm -f "$_recs"' EXIT
  records > "$_recs"
  if [ -f "$DIR/README.md" ]; then _page="$DIR/README.md"; else _page=""; fi
  {
    if [ -n "$_page" ]; then cat "$_page"
    else printf '# In Progress\n\n## Active queue\n\n<!-- queue:active -->\n\n## Blocked / waiting\n\n<!-- queue:blocked -->\n\n## Parked\n\n<!-- queue:parked -->\n'
    fi
  } | awk -v recs="$_recs" '
    function cell(s) { gsub(/\\\|/, "\001", s); gsub(/\|/, "\\|", s); gsub(/\001/, "\\|", s); return s }
    function table(rank,   n, i) {
      if (rank == 1) { print "| # | Item | Area | Initiative | Plan doc | Status | Notes |"; print "|---|------|------|------------|----------|--------|-------|" }
      if (rank == 2) { print "| Item | Blocked on | Since |"; print "|------|-----------|-------|" }
      if (rank == 3) { print "| Item | Why parked | Revisit when |"; print "|------|-----------|--------------|" }
      n = 0
      for (i = 1; i <= nr; i++) {
        if (R[i, 1] != rank) continue
        n++
        if (rank == 1) printf "| %s | %s | %s | %s | %s | %s | %s |\n", cell(R[i, 4]), cell(R[i, 5]), cell(R[i, 6]), cell(R[i, 7]), cell(R[i, 8]), cell(R[i, 9]), cell(R[i, 10])
        if (rank == 2) printf "| %s | %s | %s |\n", cell(R[i, 5]), cell(R[i, 11]), cell(R[i, 12])
        if (rank == 3) printf "| %s | %s | %s |\n", cell(R[i, 5]), cell(R[i, 13]), cell(R[i, 14])
      }
      if (n == 0) print (rank == 1) ? "| | | | | | | |" : "| | | |"
    }
    BEGIN {
      FS = "\t"; nr = 0
      while ((getline line < recs) > 0) { nr++; m = split(line, f, "\t"); for (j = 1; j <= m; j++) R[nr, j] = f[j] }
      FS = " "
    }
    /^<!-- queue:active -->[ ]*$/ { table(1); next }
    /^<!-- queue:blocked -->[ ]*$/ { table(2); next }
    /^<!-- queue:parked -->[ ]*$/ { table(3); next }
    { print }
  '
}

cmd_check() {
  _since=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --since) _since="${2:?--since needs a base}"; shift 2;;
      *) echo "queue.sh check: unknown argument $1" >&2; exit 2;;
    esac
  done
  _fail=0
  if [ -n "$_since" ] && git cat-file -e "$_since:$DIR" 2>/dev/null; then
    if git diff --name-only "$_since" HEAD -- "$LEGACY" | grep -q .; then
      printf 'queue: this PR edits %s, the retired shared table.\n' "$LEGACY"
      printf '       The queue is one file per task now: add or edit %s/<slug>.md instead\n' "$DIR"
      printf '       (shape: the header of scripts/queue.sh), and leave %s as it is on main.\n' "$LEGACY"
      _fail=1
    fi
  fi
  if [ ! -d "$DIR" ]; then
    [ "$_fail" = 0 ] && echo "queue: not migrated ($DIR absent) — nothing to check"
    return "$_fail"
  fi
  for f in "$DIR"/*; do
    [ -e "$f" ] || continue
    _b="$(basename "$f")"
    case "$_b" in README.md|.*) continue;; esac
    if ! printf '%s\n' "$_b" | grep -qE '^[a-z0-9][a-z0-9-]*\.md$'; then
      printf 'queue: %s — a fragment is named <slug>.md, slug lowercase a-z 0-9 and -\n' "$f"; _fail=1
    fi
  done
  _files="$(fragments)"
  if [ -n "$_files" ]; then
    # shellcheck disable=SC2086
    awk '
      function bad(msg) { printf "queue: %s — %s\n", FILENAME, msg; err = 1 }
      function done_file(   sec) {
        if (file == "") return
        if (fence < 2) { bad("needs a --- front-matter block at the top, closed by ---"); return }
        sec = (k["section"] == "") ? "active" : k["section"]
        if (sec != "active" && sec != "blocked" && sec != "parked") bad("section must be active, blocked or parked, not \"" sec "\"")
        if (k["order"] !~ /^-?[0-9]+$/) bad("order must be an integer (lower = nearer the top)")
        if (k["item"] == "") bad("item is required")
        if (sec == "active" && k["status"] == "") bad("status is required")
        if (sec == "blocked" && (k["blocked-on"] == "" || k["since"] == "")) bad("a blocked item needs blocked-on and since")
        if (sec == "parked" && (k["why"] == "" || k["revisit"] == "")) bad("a parked item needs why and revisit")
      }
      FNR == 1 {
        done_file(); file = FILENAME; delete k; fence = 0
        if ($0 !~ /^---[ ]*$/) { fence = -1 }
      }
      fence == -1 { next }
      /^---[ ]*$/ && fence < 2 { fence++; next }
      fence == 1 {
        if ($0 !~ /^[a-z][a-z-]*:/) { bad("front-matter line \"" $0 "\" is not key: value"); next }
        key = $0; sub(/:.*/, "", key); val = $0; sub(/^[^:]*:[ ]*/, "", val); sub(/[ ]+$/, "", val)
        if (key !~ /^(order|id|item|area|initiative|plan|status|section|blocked-on|since|why|revisit|req|risk)$/) bad("unknown key " key)
        if (key in k) bad("key " key " appears twice")
        k[key] = val
      }
      END { done_file(); exit err }
    ' $_files || _fail=1
  fi
  if [ "$_fail" = 0 ]; then
    printf 'queue: %s fragment(s) valid\n' "$(printf '%s' "$_files" | grep -c . || true)"
  fi
  return "$_fail"
}

case "${1:-render}" in
  render) cmd_render;;
  list) cmd_list;;
  check) shift; cmd_check "$@";;
  *) echo "usage: sh scripts/queue.sh render | list | check [--since SHA]" >&2; exit 2;;
esac
