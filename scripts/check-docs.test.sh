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

# --- once per PR: a PR is checked as a whole (Dustin, 2026-11-09, "Once per PR") ----------------
# mk_pr <name>: a repo whose `main` branch is the base and whose `pr` branch is checked out.
mk_pr() { r="$(mk_repo "$1")"; git -C "$r" branch -M main; git -C "$r" checkout -q -b pr; printf '%s\n' "$r"; }

# case 6: code in one commit, its worklog line in a later commit of the same PR PASSES.
r="$(mk_pr pr-line-later)"
printf 'a\n' > "$r/src.ts"; git -C "$r" add -A; cmit "$r" "feat: code"
printf -- '- line\n' > "$r/CHANGELOG.md"; git -C "$r" add -A; cmit "$r" "docs: worklog"
if ( cd "$r" && sh scripts/check-docs.sh --since main >/dev/null 2>&1 ); then
  ok "a PR with its worklog line in any one commit passes"
else bad "--since must check the PR as a whole, not commit by commit"; fi

# case 7: a PR that changes code and never touches the worklog REFUSES.
r="$(mk_pr pr-no-line)"
printf 'a\n' > "$r/src.ts"; git -C "$r" add -A; cmit "$r" "feat: code"
printf 'b\n' > "$r/other.ts"; git -C "$r" add -A; cmit "$r" "feat: more code"
if ( cd "$r" && sh scripts/check-docs.sh --since main >/dev/null 2>&1 ); then
  bad "a PR with code and no worklog line anywhere must be refused"
else ok "a PR with code and no worklog line anywhere is refused"; fi

# case 8: main merged into the PR is not charged to the PR (the diff starts at the merge-base).
r="$(mk_pr pr-merged-main)"
printf '# n\n' > "$r/NOTES.md"; git -C "$r" add -A; cmit "$r" "docs: note"
git -C "$r" checkout -q main; printf 'm\n' > "$r/main.ts"; git -C "$r" add -A; cmit "$r" "feat: main moved"
git -C "$r" checkout -q pr; git -C "$r" -c user.email=t@t -c user.name=t merge -q --no-edit main
if ( cd "$r" && sh scripts/check-docs.sh --since main >/dev/null 2>&1 ); then
  ok "code that arrived by merging main in is not charged to the PR"
else bad "--since charged the PR for main's own changes"; fi

# case 9: --each-commit (pushes to main) stays strict: a code commit without its own line REFUSES.
r="$(mk_pr each-strict)"
printf 'a\n' > "$r/src.ts"; git -C "$r" add -A; cmit "$r" "feat: code"
printf -- '- line\n' > "$r/CHANGELOG.md"; git -C "$r" add -A; cmit "$r" "docs: worklog"
if ( cd "$r" && sh scripts/check-docs.sh --each-commit main >/dev/null 2>&1 ); then
  bad "--each-commit must refuse a code commit without its own worklog line"
else ok "--each-commit refuses a code commit without its own worklog line"; fi

# case 10: --each-commit passes when every code commit carries its line (one squash per PR).
r="$(mk_pr each-pass)"
printf 'a\n' > "$r/src.ts"; printf -- '- line\n' > "$r/CHANGELOG.md"; git -C "$r" add -A; cmit "$r" "feat: squashed PR"
if ( cd "$r" && sh scripts/check-docs.sh --each-commit main >/dev/null 2>&1 ); then
  ok "--each-commit passes a squash commit that carries its line"
else bad "--each-commit refused a commit that carries its line"; fi

# case 10b: a new branch (`before` = forty zeros) checks HEAD alone instead of failing on the ref.
if ( cd "$r" && sh scripts/check-docs.sh --each-commit 0000000000000000000000000000000000000000 >/dev/null 2>&1 ); then
  ok "--each-commit with an all-zero before checks HEAD alone"
else bad "--each-commit must accept GitHub's all-zero before for a new branch"; fi

# case 11: pre-commit on a branch whose earlier commit has the line lets more code be committed.
r="$(mk_pr staged-branch)"
printf 'a\n' > "$r/src.ts"; printf -- '- line\n' > "$r/CHANGELOG.md"; git -C "$r" add -A; cmit "$r" "feat: first"
printf 'b\n' > "$r/more.ts"; git -C "$r" add -A
if ( cd "$r" && DOCS_BASE=main sh scripts/check-docs.sh >/dev/null 2>&1 ); then
  ok "pre-commit passes more code on a branch that already has its line"
else bad "pre-commit demanded a second worklog line on the same branch"; fi

printf '\ncheck-docs canary: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ] || exit 1
exit 0
