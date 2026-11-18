#!/usr/bin/env sh
# check-feature-completeness.sh — flags a user-facing PR whose body leaves the Feature completeness
# fields empty (.agents/rules/feature-completeness.md).
#
# Report-only: it prints `MISSING` and exits 0. FC_ENFORCE=1 makes a MISSING exit 1.
# PRESENCE ONLY: it cannot tell whether an entry point is sensible or an empty state is good; that is review's job.
#
#   sh scripts/check-feature-completeness.sh --body FILE --files FILE
#   sh scripts/check-feature-completeness.sh --body FILE --since <base-sha>   # files from git diff
#   FC_UI_ADD=<ere> extra files that make a PR user-facing, added to the defaults. A repo that renders views from plain
#                   .ts sets it, e.g. backlot: apps/web/src/([a-z-]+-(view|panel)|shell|styles)\.ts$
#   FC_UI_RE=<ere>  replaces the defaults entirely (default: views, plus the non-view patterns below)
#
# User-facing by default: a view file (.tsx .jsx .vue .svelte .css .scss, app/**/page.*); a non-view channel a user
# receives (a file named for notice, notification, email, mail, slack, sms or push); and a What's new fragment
# (changelog.d/*.md), because a repo that writes one has already said the change is visible to users.
#
# A PR is user-facing when a changed non-test file matches FC_UI_RE and the body does not say `User-facing: no - <reason>`.
# A field is filled when it has text after its label that is not the template placeholder, `tbd` or `todo`.
set -u

BODY=""
FILES=""
SINCE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --body) BODY="${2:-}"; shift 2 ;;
    --files) FILES="${2:-}"; shift 2 ;;
    --since) SINCE="${2:-}"; shift 2 ;;
    *) echo "check-feature-completeness: unknown argument '$1'" >&2; exit 2 ;;
  esac
done
[ -n "$BODY" ] && [ -r "$BODY" ] || { echo "check-feature-completeness: --body FILE is required" >&2; exit 2; }

UI_RE="${FC_UI_RE:-\.(tsx|jsx|vue|svelte|css|scss)$|(^|/)app/.*page\.[a-z]+$|(^|/)changelog\.d/[^/]+\.md$|(notice|notif|notify|e?mail|slack|sms|push)[a-z-]*\.(ts|tsx|js|py|html|mjml)$}"
[ -n "${FC_UI_ADD:-}" ] && UI_RE="$UI_RE|$FC_UI_ADD"
NOT_UI_RE="${FC_NOT_UI_RE:-(\.|/)(test|spec|stories|e2e)(\.|/)|__tests__/|/tests?/}"

if [ -z "$FILES" ]; then
  [ -n "$SINCE" ] || { echo "check-feature-completeness: --files FILE or --since SHA is required" >&2; exit 2; }
  FILES="$(mktemp)" || exit 2
  trap 'rm -f "$FILES"' EXIT INT TERM
  git diff --name-only "$SINCE"...HEAD > "$FILES" || { echo "check-feature-completeness: cannot diff against '$SINCE'" >&2; exit 2; }
fi

ui_files="$(grep -E -e "$UI_RE" "$FILES" | grep -vE -e "$NOT_UI_RE" || true)"
if [ -z "$ui_files" ]; then
  echo "check-feature-completeness: OK (no user-facing files changed)"
  exit 0
fi

# Alternation, not a bracket: in a C locale [–—] matches single bytes of the UTF-8 dash and never the whole dash.
NO_RE='user-facing[[:space:]]*:[[:space:]]*no([^[:alnum:]]|$)'
REASON_RE='user-facing[[:space:]]*:[[:space:]]*no[[:space:]]*(-|:|–|—)[[:space:]]*[[:alnum:]][^[:cntrl:]]*[[:alnum:]]'
if tr -d '*_`' < "$BODY" | grep -qiE -e "$REASON_RE"; then
  echo "check-feature-completeness: OK (PR states User-facing: no, with a reason)"
  exit 0
fi

fail() {
  echo "check-feature-completeness: $1"
  [ -n "${GITHUB_ACTIONS:-}" ] && echo "::warning title=Feature completeness::$1"
  [ "${FC_ENFORCE:-0}" = "1" ] && exit 1
  exit 0
}

# Text after "<label>:" plus following lines, up to the next "- label:" bullet or heading.
field_text() {
  tr -d '*_`\r' < "$BODY" | awk -v want="$(printf '%s' "$1" | tr 'A-Z' 'a-z')" '
    {
      line = tolower($0)
      if (!on && line ~ "^[[:space:]>*-]*(#+[[:space:]]*)?" want "[[:space:]]*:") {
        on = 1
        sub(/^[^:]*:/, "")
        print
        next
      }
      if (on) {
        if ($0 ~ /^[[:space:]>]*[-*][[:space:]]+[A-Za-z'"'"' ]+:/ || $0 ~ /^#/) exit
        print
      }
    }'
}

filled() {
  text="$(field_text "$1" | sed 's/<!--.*-->//g' | tr '\n' ' ' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
  [ -n "$text" ] || return 1
  case "$(printf '%s' "$text" | tr 'A-Z' 'a-z')" in
    tbd|todo|"-"|n/a|"yes / no - reason") return 1 ;;
    "the nav item, page or tab that leads here"*) return 1 ;;
    "empty state (why, one primary action, help link), loading"*) return 1 ;;
    "screens, nav, permissions, notifications, data, pipeline stages;"*) return 1 ;;
    "how you ran it from the entry point"*) return 1 ;;
    "the \"what's new\" entry added"*) return 1 ;;
  esac
  return 0
}

missing=""
for f in "Entry point" "UX states" "Affects" "Tested through the app" "What's new"; do
  filled "$f" || missing="$missing, $f"
done
missing="${missing#, }"

no_line="$(tr -d '*_`\r' < "$BODY" | grep -iE -e "$NO_RE" | head -1 | sed 's/^[[:space:]]*//')"
if [ -n "$missing" ] && [ -n "$no_line" ]; then
  echo "check-feature-completeness: failing line: $no_line"
  fail "MISSING in the PR body: a reason of 3+ characters after 'User-facing: no -'. A user-facing PR fills each Feature completeness line, or says 'User-facing: no - <reason>'. Rule: .agents/rules/feature-completeness.md"
fi
[ -z "$missing" ] || fail "MISSING in the PR body: $missing. A user-facing PR fills each Feature completeness line, or says 'User-facing: no - <reason>'. Rule: .agents/rules/feature-completeness.md"
echo "check-feature-completeness: OK (all fields filled)"
exit 0
