#!/usr/bin/env sh
# queue.test.sh — canary for queue.sh (the one-file-per-task queue).
#
# Why this exists: the point of the fragment queue is that two PRs which each change a queue item merge
# in either order with no conflict, and that every reader still sees the same ordered table. Both are
# asserted here with real git merges, alongside the check's refusals (bad front matter, an edit to the
# frozen in-progress.md after migration) and its passes (valid fragments, an unmigrated repo), so
# "detects correctly" is distinguishable from "blocks nothing" and from "blocks everything".
#
# Helpers that mkrepo calls write to STDERR only: mkrepo's stdout IS the fixture path.
#
#   sh scripts/queue.test.sh
set -u

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOOL="$ROOT/scripts/queue.sh"

TMP="$(mktemp -d 2>/dev/null || mktemp -d -t queue-canary)"
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0
ok()  { pass=$((pass + 1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL %s\n' "$1"; }

mkrepo() {
  d="$TMP/$1"
  mkdir -p "$d/scripts" "$d/docs/agents"
  git -C "$d" init -q 2>/dev/null || { printf 'cannot init git repo\n' >&2; exit 2; }
  git -C "$d" config user.email canary@example.invalid
  git -C "$d" config user.name canary
  git -C "$d" config commit.gpgsign false
  git -C "$d" config core.hooksPath /dev/null
  git -C "$d" symbolic-ref HEAD refs/heads/main
  cp "$TOOL" "$d/scripts/queue.sh"
  printf 'base\n' > "$d/README.md"
  git -C "$d" add -A >/dev/null 2>&1 && git -C "$d" commit -qm base >/dev/null 2>&1
  printf '%s\n' "$d"
}

frag() { # frag <repo> <slug> <order> <item> <status> [notes]
  mkdir -p "$1/docs/agents/in-progress.d"
  printf -- '---\norder: %s\nitem: %s\narea: core\ninitiative: Thing\nplan: `core/%s/plan.md`\nstatus: %s\n---\n%s\n' \
    "$3" "$4" "$2" "$5" "${6:-Next: do it.}" > "$1/docs/agents/in-progress.d/$2.md"
}

page() {
  mkdir -p "$1/docs/agents/in-progress.d"
  printf '# In Progress\n\n## Active queue\n\n<!-- queue:active -->\n\n## Blocked / waiting\n\n<!-- queue:blocked -->\n\n## Parked\n\n<!-- queue:parked -->\n' \
    > "$1/docs/agents/in-progress.d/README.md"
}

commit() { git -C "$1" add -A >/dev/null 2>&1 && git -C "$1" commit -qm "$2" >/dev/null 2>&1; }

# 1. Unmigrated repo: render is the legacy file, check passes.
r="$(mkrepo unmigrated)"
printf '# In Progress\n\n| # | Item |\n|---|---|\n| 1 | legacy row |\n' > "$r/docs/agents/in-progress.md"
commit "$r" legacy
if ( cd "$r" && sh scripts/queue.sh render ) | grep -q 'legacy row'; then ok "unmigrated: render prints in-progress.md"
else bad "unmigrated: render did not print the legacy table"; fi
if ( cd "$r" && sh scripts/queue.sh check --since HEAD ) >/dev/null 2>&1; then ok "unmigrated: check passes"
else bad "unmigrated: check failed"; fi

# 2. Render: order sorts, ties break by slug, sections land in their tables, pipes are escaped.
r="$(mkrepo render)"
page "$r"
frag "$r" zeta 20 "Zeta item" "In review"
frag "$r" alpha 20 "Alpha item" "In progress" "Uses a | pipe."
frag "$r" first 5 "First item" "Not started"
printf -- '---\norder: 10\nsection: blocked\nitem: Waiting item\nblocked-on: a go\nsince: 2026-11-20\n---\n' > "$r/docs/agents/in-progress.d/waiting.md"
out="$( cd "$r" && sh scripts/queue.sh render )"
rows="$(printf '%s\n' "$out" | grep -oE '^\| +\| (First|Alpha|Zeta) item' | grep -oE '(First|Alpha|Zeta)' | tr '\n' ' ')"
if [ "$rows" = "First Alpha Zeta " ]; then ok "render orders by order, then slug"
else bad "render order was '$rows', wanted 'First Alpha Zeta '"; fi
if printf '%s\n' "$out" | grep -qF '| Waiting item | a go | 2026-11-20 |'; then ok "blocked item renders in the blocked table"
else bad "blocked item missing from the blocked table"; fi
if printf '%s\n' "$out" | grep -qF 'Uses a \| pipe.'; then ok "a | in a value is escaped"
else bad "a | in a value was not escaped"; fi
if printf '%s\n' "$out" | grep -qxF '| | | |'; then ok "an empty section renders a placeholder row"
else bad "the empty parked section has no placeholder row"; fi
if ( cd "$r" && sh scripts/queue.sh list ) | grep -qE "^active	5	first	Not started	First item$"; then ok "list prints section, order, slug, status, item"
else bad "list output wrong: $( cd "$r" && sh scripts/queue.sh list | head -1 )"; fi
if ( cd "$r" && sh scripts/queue.sh check ) >/dev/null 2>&1; then ok "valid fragments pass the check"
else bad "valid fragments failed: $( cd "$r" && sh scripts/queue.sh check 2>&1 )"; fi

# 3. Check refusals.
refuse() { # refuse <label> <file name> <content>
  rr="$(mkrepo "refuse-$(printf '%s' "$1" | tr -c 'a-z0-9' '-')")"
  page "$rr"
  printf -- "$3" > "$rr/docs/agents/in-progress.d/$2"
  if ( cd "$rr" && sh scripts/queue.sh check ) >/dev/null 2>&1; then bad "check accepted: $1"
  else ok "check refuses: $1"; fi
}
refuse "no front matter" "a.md" 'just text\n'
refuse "unclosed front matter" "a.md" '---\norder: 1\nitem: x\nstatus: y\n'
refuse "order not an integer" "a.md" '---\norder: top\nitem: x\nstatus: y\n---\n'
refuse "missing item" "a.md" '---\norder: 1\nstatus: y\n---\n'
refuse "missing status" "a.md" '---\norder: 1\nitem: x\n---\n'
refuse "unknown key" "a.md" '---\norder: 1\nitem: x\nstatus: y\nstatsu: z\n---\n'
refuse "repeated key" "a.md" '---\norder: 1\nitem: x\nitem: z\nstatus: y\n---\n'
refuse "unknown section" "a.md" '---\norder: 1\nsection: later\nitem: x\nstatus: y\n---\n'
refuse "blocked without blocked-on" "a.md" '---\norder: 1\nsection: blocked\nitem: x\nsince: today\n---\n'
refuse "upper-case file name" "Big.md" '---\norder: 1\nitem: x\nstatus: y\n---\n'

# 4. After migration, a PR that edits the frozen in-progress.md is refused; one that adds a fragment passes.
r="$(mkrepo frozen)"
page "$r"
frag "$r" one 10 "One" "In progress"
printf 'moved\n' > "$r/docs/agents/in-progress.md"
commit "$r" migrated
base="$(git -C "$r" rev-parse HEAD)"
git -C "$r" checkout -qb edits-table
printf 'moved\n| 2 | sneaky row |\n' > "$r/docs/agents/in-progress.md"
commit "$r" "row in table"
if ( cd "$r" && sh scripts/queue.sh check --since "$base" ) >/dev/null 2>&1; then bad "a PR editing the frozen table passed"
else ok "a PR editing the frozen in-progress.md is refused"; fi
git -C "$r" checkout -q main && git -C "$r" checkout -qb adds-fragment
frag "$r" two 20 "Two" "Not started"
commit "$r" "fragment"
if ( cd "$r" && sh scripts/queue.sh check --since "$base" ) >/dev/null 2>&1; then ok "a PR adding a fragment passes"
else bad "a PR adding a fragment failed"; fi

# 5. The migration PR itself (folder absent at the base) may replace in-progress.md.
r="$(mkrepo migration)"
printf '| 1 | row |\n' > "$r/docs/agents/in-progress.md"
commit "$r" legacy
base="$(git -C "$r" rev-parse HEAD)"
page "$r"; frag "$r" row 10 "row" "In progress"; printf 'moved\n' > "$r/docs/agents/in-progress.md"
commit "$r" migrate
if ( cd "$r" && sh scripts/queue.sh check --since "$base" ) >/dev/null 2>&1; then ok "the migrating PR may replace in-progress.md"
else bad "the migrating PR was refused"; fi

# 6. Two PRs that each add or edit a different queue item merge in either order with no conflict.
r="$(mkrepo merge)"
page "$r"
frag "$r" shared-a 10 "A" "In progress"
frag "$r" shared-b 20 "B" "In progress"
commit "$r" base-queue
git -C "$r" checkout -qb pr1
frag "$r" shared-a 10 "A" "In review" "Next: merge."
frag "$r" new-one 15 "New one" "Not started"
commit "$r" pr1
git -C "$r" checkout -q main && git -C "$r" checkout -qb pr2
frag "$r" shared-b 20 "B" "Live" "Next: watch."
frag "$r" new-two 15 "New two" "Not started"
commit "$r" pr2
git -C "$r" checkout -q main
if git -C "$r" merge -q --no-edit pr1 >/dev/null 2>&1 && git -C "$r" merge -q --no-edit pr2 >/dev/null 2>&1; then
  ok "pr1 then pr2 merge with no conflict"
else bad "pr1 then pr2 conflicted"; git -C "$r" merge --abort >/dev/null 2>&1; fi
one="$( cd "$r" && sh scripts/queue.sh render )"
git -C "$r" reset -q --hard "$(git -C "$r" rev-parse pr1~1)"
if git -C "$r" merge -q --no-edit pr2 >/dev/null 2>&1 && git -C "$r" merge -q --no-edit pr1 >/dev/null 2>&1; then
  ok "pr2 then pr1 merge with no conflict"
else bad "pr2 then pr1 conflicted"; fi
two="$( cd "$r" && sh scripts/queue.sh render )"
if [ "$one" = "$two" ]; then ok "either merge order renders the same queue"
else bad "the two merge orders render different queues"; fi

printf '\nqueue canary: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
