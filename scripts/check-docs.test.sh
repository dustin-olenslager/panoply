#!/usr/bin/env sh
# check-docs.test.sh — canary for the docs landing gate.
#
# The gate had no test. It is wired into CI and the pre-commit hook, so a regression in it either
# blocks every commit or lets undocumented code land silently — and nothing would catch either.
#
# Asserts both directions: undocumented code REFUSES, the worklog line in the SAME commit PASSES, docs
# are exempt, and DOCS_OFF lifts it. POSIX sh, no runtime deps.
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
GATE="$HERE/check-docs.sh"
pass=0
fail=0

ok()  { pass=$((pass+1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail+1)); printf '  FAIL %s\n' "$1"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT INT TERM

cmit() { git -C "$1" -c user.email=t@t -c user.name=t commit -q -m "$2"; }

mk_repo() {
  r="$TMP/$1"; mkdir -p "$r/scripts"
  cp "$GATE" "$r/scripts/"
  git -C "$r" init -q
  printf 'seed\n' > "$r/seed.txt"
  git -C "$r" add -A; cmit "$r" "chore: init"
  printf '%s\n' "$r"
}

# --- case 1: code with no worklog line REFUSES --------------------------------
# NOTE: the change must stay STAGED but uncommitted — --staged reads the index, so committing first
# empties the diff and the gate correctly passes. (Getting this wrong is how a canary lies.)
r="$(mk_repo fail-nodocs)"
printf 'a\n' > "$r/src.ts"
git -C "$r" add -A
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then
  bad "code with no worklog line must be refused"
else ok "code with no worklog line is refused"; fi

# --- case 2: the worklog line in the SAME commit PASSES (positive control) ----
r="$(mk_repo pass-same-commit)"
printf 'a\n' > "$r/src.ts"
printf -- '- 2026-10-03 · did a thing\n' > "$r/CHANGELOG.md"
git -C "$r" add -A; cmit "$r" "feat: code with its worklog line"
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then
  ok "code + worklog line in one commit passes"
else bad "the sanctioned same-commit update was refused — the gate is unpassable"; fi

# --- case 3: a docs-only change is exempt -------------------------------------
r="$(mk_repo pass-docs-only)"
printf '# note\n' > "$r/NOTES.md"
git -C "$r" add -A; cmit "$r" "docs: note"
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then
  ok "a docs-only change is exempt"
else bad "a docs-only change must not need a worklog line"; fi

# --- case 4: DOCS_OFF lifts the gate ------------------------------------------
r="$(mk_repo hatch)"
printf 'a\n' > "$r/src.ts"
git -C "$r" add -A
if ( cd "$r" && DOCS_OFF=1 sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then
  ok "DOCS_OFF=1 lifts the gate (declared exception)"
else bad "escape hatch did not lift the gate"; fi

# --- case 5: the hatch is declared in the script's own usage ------------------
if grep -q 'DOCS_OFF=1' "$GATE"; then ok "the hatch is documented in the gate's usage header"
else bad "DOCS_OFF exists but is undocumented — an undeclared hatch is not a hatch"; fi

# case 6: --since judges the WHOLE change, not each commit
# Dustin, 2026-11-11: PRs are squash-merged, so the PR is what lands. A later commit that touches
# code with no worklog line passes when an earlier commit in the range added the line.
r="$(mk_repo pass-whole-pr)"; base="$(git -C "$r" rev-parse HEAD)"
printf 'a\n' > "$r/src.ts"; printf -- '- did a thing\n' > "$r/CHANGELOG.md"
git -C "$r" add -A; cmit "$r" "feat: code with its worklog line"
printf 'b\n' >> "$r/src.ts"
git -C "$r" add -A; cmit "$r" "fix: follow-up, no worklog line of its own"
if ( cd "$r" && sh scripts/check-docs.sh --since "$base" >/dev/null 2>&1 ); then
  ok "--since passes when an earlier commit in the range added the worklog line"
else bad "--since still judges each commit; a follow-up commit was refused"; fi

# case 7: --since still REFUSES a range with code and no worklog line
r="$(mk_repo fail-whole-pr)"; base="$(git -C "$r" rev-parse HEAD)"
printf 'a\n' > "$r/src.ts"; git -C "$r" add -A; cmit "$r" "feat: code"
printf 'b\n' >> "$r/src.ts"; git -C "$r" add -A; cmit "$r" "fix: more code"
if ( cd "$r" && sh scripts/check-docs.sh --since "$base" >/dev/null 2>&1 ); then
  bad "--since accepted a range that never touches the worklog"
else ok "--since refuses a range with code and no worklog line"; fi

# case 8: --since with an unknown ref refuses, never passes silently
if ( cd "$r" && sh scripts/check-docs.sh --since no-such-ref >/dev/null 2>&1 ); then
  bad "--since accepted a ref that does not exist"
else ok "--since refuses a ref that does not exist"; fi

# --- worklog fragments (docs/agents/worklog.d/), Dustin 2026-11-12 -------------
# Fixture helper: a repo already migrated (fragment dir committed with one entry and a frozen worklog.md).
mk_frag_repo() {
  r="$(mk_repo "$1")"; mkdir -p "$r/docs/agents/worklog.d"
  printf -- '- old entry\n' > "$r/docs/agents/worklog.d/2026-01-01-old.md"
  printf -- '- frozen\n' > "$r/docs/agents/worklog.md"
  git -C "$r" add -A; cmit "$r" "chore: migrate"
  printf '%s\n' "$r"
}

# case 9: code + a NEW fragment passes (staged)
r="$(mk_frag_repo frag-add)"
printf 'a\n' > "$r/src.ts"; printf -- '- did a thing\n' > "$r/docs/agents/worklog.d/2026-11-12-thing.md"
git -C "$r" add -A
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then ok "code + a new worklog fragment passes"
else bad "a new fragment was refused"; fi

# case 10: code + only a MODIFIED fragment fails
r="$(mk_frag_repo frag-modify)"
printf 'a\n' > "$r/src.ts"; printf -- '- edited\n' >> "$r/docs/agents/worklog.d/2026-01-01-old.md"
git -C "$r" add -A
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then bad "a modified fragment was accepted as a new entry"
else ok "code + a modified (not added) fragment is refused"; fi

# case 11: code + only a DELETED fragment fails
r="$(mk_frag_repo frag-delete)"
printf 'a\n' > "$r/src.ts"; git -C "$r" rm -q "docs/agents/worklog.d/2026-01-01-old.md"
git -C "$r" add -A
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then bad "a deleted fragment was accepted"
else ok "code + a deleted fragment is refused"; fi

# case 12: migrated repo — appending to the frozen worklog.md no longer counts
r="$(mk_frag_repo frag-frozen)"
printf 'a\n' > "$r/src.ts"; printf -- '- appended\n' >> "$r/docs/agents/worklog.md"
git -C "$r" add -A
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then bad "the frozen worklog.md still satisfies the gate"
else ok "migrated repo: touching the frozen worklog.md is refused"; fi

# case 13: a dotfile / README in the fragment dir is not an entry
r="$(mk_frag_repo frag-keep)"
printf 'a\n' > "$r/src.ts"; : > "$r/docs/agents/worklog.d/.gitkeep"; printf '# r\n' > "$r/docs/agents/worklog.d/README.md"
git -C "$r" add -A
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then bad ".gitkeep/README counted as a worklog entry"
else ok ".gitkeep and README.md are not worklog entries"; fi

# case 14: migrated repo, docs-only change passes
r="$(mk_frag_repo frag-docs)"
printf '# n\n' > "$r/NOTES.md"; git -C "$r" add -A
if ( cd "$r" && sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then ok "migrated repo: a docs-only change is exempt"
else bad "migrated repo refused a docs-only change"; fi

# case 15: --since passes when the PR adds a fragment, refuses when it only edits one
r="$(mk_frag_repo frag-since)"; base="$(git -C "$r" rev-parse HEAD)"
printf 'a\n' > "$r/src.ts"; printf -- '- x\n' > "$r/docs/agents/worklog.d/2026-11-12-x.md"
git -C "$r" add -A; cmit "$r" "feat: code + fragment"
if ( cd "$r" && sh scripts/check-docs.sh --since "$base" >/dev/null 2>&1 ); then ok "--since passes when the PR adds a fragment"
else bad "--since refused a PR that adds a fragment"; fi
r="$(mk_frag_repo frag-since-edit)"; base="$(git -C "$r" rev-parse HEAD)"
printf 'a\n' > "$r/src.ts"; printf -- '- y\n' >> "$r/docs/agents/worklog.d/2026-01-01-old.md"
git -C "$r" add -A; cmit "$r" "feat: code, edits old fragment"
if ( cd "$r" && sh scripts/check-docs.sh --since "$base" >/dev/null 2>&1 ); then bad "--since accepted an edited fragment"
else ok "--since refuses a PR that only edits an existing fragment"; fi

# case 16: DOCS_WORKLOG_DIR moves the fragment dir
r="$(mk_repo frag-customdir)"; mkdir -p "$r/log.d"; : > "$r/log.d/.keep"; git -C "$r" add -A; cmit "$r" "chore: dir"
printf 'a\n' > "$r/src.ts"; printf -- '- z\n' > "$r/log.d/2026-11-12-z.md"; git -C "$r" add -A
if ( cd "$r" && DOCS_WORKLOG_DIR=log.d sh scripts/check-docs.sh --staged >/dev/null 2>&1 ); then ok "DOCS_WORKLOG_DIR relocates the fragment dir"
else bad "DOCS_WORKLOG_DIR was ignored"; fi

printf '\ncheck-docs canary: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
