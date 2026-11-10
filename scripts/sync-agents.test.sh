#!/usr/bin/env sh
# Canary for sync-agents.sh's mirror allow-list (.agents/mirrors).
#   sh scripts/sync-agents.test.sh
# Proves: no list = every mirror (the behaviour every adopted repo already has); a list generates
# only what it names and removes the generated rest; --check fails while a switched-off mirror is
# still on disk; a hand-written file at a mirror's path survives; an unknown name is refused.
set -u
KIT="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT INT TERM
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
check() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (got $2, want $3)"; fi; }

R="$T/repo"
mkdir -p "$R/scripts" "$R/.agents/rules"
cp "$KIT/scripts/sync-agents.sh" "$R/scripts/"
printf '# Alpha rule\n\nApplies when: always\n' > "$R/.agents/rules/alpha.md"
cat > "$R/AGENTS.md" <<'DOC'
# AGENTS.md
<!-- MIRROR:start -->
## If you read nothing else
Read AGENTS.md.
<!-- MIRROR:end -->
<!-- PANOPLY:RULES:BEGIN -->
<!-- PANOPLY:RULES:END -->
DOC
sync() { ( cd "$R" && sh scripts/sync-agents.sh "$@" ) >"$T/out" 2>&1; }
has() { [ -e "$R/$1" ] && echo yes || echo no; }
ALL="CLAUDE.md GEMINI.md CONVENTIONS.md .github/copilot-instructions.md .clinerules/00-agents.md .windsurf/rules/00-agents.md .cursor/rules/00-preamble.mdc .cursor/rules/alpha.mdc .agents/rules/alpha.mdc"

echo "1. no .agents/mirrors: every mirror is generated"
sync; check "1a write exits 0" "$?" "0"
for f in $ALL; do check "1b $f exists" "$(has "$f")" "yes"; done
sync --check; check "1c --check passes" "$?" "0"

echo "2. a list keeps only what it names"
printf '# tools in use here\nclaude\ncursor   # per-rule files\n' > "$R/.agents/mirrors"
sync --check; check "2a --check fails while switched-off mirrors are on disk" "$?" "1"
grep -q 'switched off in .agents/mirrors' "$T/out"; check "2b and says why" "$?" "0"
sync; check "2c write exits 0" "$?" "0"
for f in CLAUDE.md .cursor/rules/00-preamble.mdc .cursor/rules/alpha.mdc; do check "2d $f kept" "$(has "$f")" "yes"; done
for f in GEMINI.md CONVENTIONS.md .github/copilot-instructions.md .clinerules .windsurf/rules .agents/rules/alpha.mdc; do
  check "2e $f removed" "$(has "$f")" "no"
done
check "2f the canonical rule is untouched" "$(has .agents/rules/alpha.md)" "yes"
sync --check; check "2g --check passes after the write" "$?" "0"

echo "3. none: only the AGENTS.md index block is left, and a hand-written CLAUDE.md survives"
printf 'none\n' > "$R/.agents/mirrors"
sync; check "3a write exits 0" "$?" "0"
for f in CLAUDE.md .cursor; do check "3b $f removed" "$(has "$f")" "no"; done
printf '@AGENTS.md\n' > "$R/CLAUDE.md"
sync; sync --check; check "3c --check passes with a hand-written CLAUDE.md" "$?" "0"
check "3d hand-written CLAUDE.md is untouched" "$(cat "$R/CLAUDE.md")" "@AGENTS.md"
grep -q 'alpha.*Alpha rule' "$R/AGENTS.md"; check "3e AGENTS.md index is still filled" "$?" "0"
printf '# Beta rule\n' > "$R/.agents/rules/beta.md"
sync --check; check "3f --check still guards the index block" "$?" "1"

echo "4. an empty list means none; an unknown name is refused"
rm "$R/.agents/rules/beta.md"; : > "$R/.agents/mirrors"
sync; check "4a empty file: write exits 0" "$?" "0"
check "4b empty file generates no mirror" "$(has GEMINI.md)" "no"
printf 'claud\n' > "$R/.agents/mirrors"
sync; check "4c unknown name exits 1" "$?" "1"
grep -q "unknown mirror 'claud'" "$T/out"; check "4d and names it" "$?" "0"

printf '\n%s passed, %s failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
