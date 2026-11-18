#!/usr/bin/env sh
# check-feature-completeness.test.sh — canary for check-feature-completeness.sh: a UI change with empty fields is
# MISSING, a filled or opted-out body is OK, a non-UI change is OK, and FC_ENFORCE=1 fails.
#
#   sh scripts/check-feature-completeness.test.sh
set -u

HERE="$(cd "$(dirname "$0")" && pwd)"
GATE="$HERE/check-feature-completeness.sh"
SANDBOX="$(mktemp -d 2>/dev/null || mktemp -d -t fc-canary)"
trap 'rm -rf "$SANDBOX"' EXIT INT TERM

pass=0
fail=0
want_in() {
  if printf '%s' "$2" | grep -q "$3"; then pass=$((pass + 1)); printf '  ok   %s\n' "$1"
  else fail=$((fail + 1)); printf '  FAIL %s (missing %s in: %s)\n' "$1" "$3" "$2"; fi
}

printf 'apps/web/components/Thing.tsx\ndocs/x.md\n' > "$SANDBOX/ui.files"
printf 'docs/x.md\npackages/core/src/a.ts\n' > "$SANDBOX/api.files"
printf 'apps/web/components/Thing.test.tsx\n' > "$SANDBOX/test.files"

cat > "$SANDBOX/empty.md" <<'B'
## Feature completeness
- **User-facing:** yes
- **Entry point:**
- **UX states:** empty state (why, one primary action, help link), loading, error, mobile and desktop, Figma frame link
- **Affects:**
- **Tested through the app:**
- **What's new:**
B
out="$(sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/ui.files")"
want_in "1 empty and placeholder fields are MISSING" "$out" "MISSING in the PR body: Entry point, UX states, Affects, Tested through the app, What's new"

cat > "$SANDBOX/full.md" <<'B'
## Feature completeness
- **User-facing:** yes
- **Entry point:** Franchise tab "Comps", 1 click from the franchise panel
- **UX states:** empty state with icon and "Add a comp"; loading skeleton; error banner; checked at 320 and 1440; Figma frame linked
- **Affects:** Activity feed gets a comps line; no permission change; pipeline: after Vote, before Candidate
- **Tested through the app:** opened /franchises, added a comp, saw it in Activity
- **What's new:** changelog.d/comps.md
B
out="$(sh "$GATE" --body "$SANDBOX/full.md" --files "$SANDBOX/ui.files")"
want_in "2 filled fields are OK" "$out" "OK (all fields filled)"

printf '%s\n' '- **User-facing:** no - test helper only' > "$SANDBOX/no.md"
out="$(sh "$GATE" --body "$SANDBOX/no.md" --files "$SANDBOX/ui.files")"
want_in "3 User-facing: no with a reason is OK" "$out" "User-facing: no"

printf '%s\n' '- **User-facing:** no' > "$SANDBOX/noreason.md"
out="$(sh "$GATE" --body "$SANDBOX/noreason.md" --files "$SANDBOX/ui.files")"
want_in "4 User-facing: no without a reason is still checked" "$out" "MISSING"

for r in 'a read API only' 'ok, no screen' 'an internal tool'; do
  printf '%s\n' "- **User-facing:** no - $r" > "$SANDBOX/short.md"
  out="$(FC_ENFORCE=1 sh "$GATE" --body "$SANDBOX/short.md" --files "$SANDBOX/ui.files")"
  want_in "4b a reason starting with a short word is OK ($r)" "$out" "OK (PR states"
done
for d in '—' '–' ':'; do
  printf '%s\n' "User-facing: no $d docs only" > "$SANDBOX/dash.md"
  out="$(LC_ALL=C sh "$GATE" --body "$SANDBOX/dash.md" --files "$SANDBOX/ui.files")"
  want_in "4c '$d' separates the reason, even in a C locale" "$out" "OK (PR states"
done
for e in 'User-facing: no -' 'User-facing: no - ' 'User-facing: no — x'; do
  printf '%s\n' "$e" > "$SANDBOX/empty-reason.md"
  out="$(sh "$GATE" --body "$SANDBOX/empty-reason.md" --files "$SANDBOX/ui.files")"
  want_in "4d an empty or 1-char reason names its line ($e)" "$out" "failing line: User-facing: no"
  want_in "4e ... and asks for the reason, not every field" "$out" "MISSING in the PR body: a reason"
done
{ printf '%s\n' 'User-facing: no'; sed -n '/Entry point/,$p' "$SANDBOX/full.md"; } > "$SANDBOX/nofull.md"
out="$(FC_ENFORCE=1 sh "$GATE" --body "$SANDBOX/nofull.md" --files "$SANDBOX/ui.files")"
want_in "4g a bare 'no' with every field filled is OK" "$out" "OK (all fields filled)"
printf '%s\n' 'User-facing: nothing new here' > "$SANDBOX/notno.md"
out="$(sh "$GATE" --body "$SANDBOX/notno.md" --files "$SANDBOX/ui.files")"
want_in "4f 'no' must be a whole word" "$out" "MISSING in the PR body: Entry point"

out="$(sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/api.files")"
want_in "5 a change with no UI file is OK" "$out" "no user-facing files"

out="$(sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/test.files")"
want_in "6 a UI test file is not a screen" "$out" "no user-facing files"

sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/ui.files" >/dev/null; rc=$?
if [ "$rc" -eq 0 ]; then pass=$((pass + 1)); echo "  ok   7 report-only exits 0"; else fail=$((fail + 1)); echo "  FAIL 7 report-only exit $rc"; fi
FC_ENFORCE=1 sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/ui.files" >/dev/null; rc=$?
if [ "$rc" -eq 1 ]; then pass=$((pass + 1)); echo "  ok   8 FC_ENFORCE=1 exits 1"; else fail=$((fail + 1)); echo "  FAIL 8 enforce exit $rc"; fi

printf 'x' > "$SANDBOX/plain.md"
out="$(sh "$GATE" --body "$SANDBOX/plain.md" --files "$SANDBOX/ui.files")"
want_in "9 a body with no section at all is MISSING" "$out" "MISSING"

printf 'packages/core/src/adapters/task-notice-slack.ts\n' > "$SANDBOX/dm.files"
out="$(sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/dm.files")"
want_in "10 a Slack notice adapter is user-facing" "$out" "MISSING"

printf 'changelog.d/thing.md\npackages/core/src/a.ts\n' > "$SANDBOX/cl.files"
out="$(sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/cl.files")"
want_in "11 a What's new fragment is user-facing" "$out" "MISSING"

printf 'apps/web/src/comp-view.ts\n' > "$SANDBOX/view.files"
out="$(sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/view.files")"
want_in "12 a plain .ts view is not seen by default" "$out" "no user-facing files"
out="$(FC_UI_ADD='-view\.ts$' sh "$GATE" --body "$SANDBOX/empty.md" --files "$SANDBOX/view.files")"
want_in "13 FC_UI_ADD adds a repo's own pattern" "$out" "MISSING"

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
