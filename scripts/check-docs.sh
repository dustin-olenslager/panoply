#!/usr/bin/env sh
# check-docs.sh — the landing gate: no code change may land without its worklog line.
#
# Enforces the "same-change update contract" (.agents/rules/documentation.md) mechanically: a change
# to any non-doc file (source, config, schema, scripts, CI) must come with a change to the worklog
# target. A PR is checked ONCE, as a whole: the line may sit in any of its commits (Dustin, 2026-11-09,
# "Once per PR"). What lands on main is checked commit by commit, because a squash-merge leaves one
# commit per PR and a direct push has no PR around it. This is the provider-neutral floor — it binds
# every agent in every tool, because it runs in required CI (scripts/templates/ci-verify.yml) and,
# for convenience, in the pre-commit hook.
#
#   sh scripts/check-docs.sh                   # staged changes, plus what this branch already changed (pre-commit)
#   sh scripts/check-docs.sh --since REF       # the PR as a whole: merge-base(REF, HEAD)..HEAD (CI, pull_request)
#   sh scripts/check-docs.sh --each-commit REF # every non-merge commit in REF..HEAD on its own (CI, push to main)
#
#   DOCS_OFF=1   disable entirely (deliberate exception — say so out loud)
#
# Worklog target: CHANGELOG.md / HISTORY.md if present, else docs/agents/worklog.md.
# Override with DOCS_WORKLOG=<path>. "Doc" files are exempt from the mandatory line; the exempt
# extensions default to `md` and are overridable via DOCS_EXEMPT (space-separated, e.g. `md rst adoc`).
# A repo whose product IS markdown (a docs site, a blog) must set DOCS_EXEMPT to empty so shipped .md
# changes are treated as code. POSIX sh, no runtime deps.
#
# The gate enforces PRESENCE, not CORRECTNESS: a garbage worklog line passes. Correctness is a review
# problem, not an automation problem — the honest limit of any git-native kit.
set -eu

# A declared escape hatch, matching ALGORITHM_OFF / PLAN_HOME_OFF / SPEC_OFF. Every blocking gate
# needs one: without it, an agent hitting a legitimate-but-unusual case has no remedy the kit names,
# so it invents one (`--no-verify`, a fabricated worklog line) instead of declaring the exception.
[ "${DOCS_OFF:-0}" = "1" ] && { echo "check-docs: disabled (DOCS_OFF=1)"; exit 0; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# --- worklog target ---
# Resolved LAZILY, after the diff is known: a missing worklog target is only a problem if a code change
# needs one. A docs-only change in a repo with no worklog file yet is perfectly legal, and refusing it
# blocked a fresh repo from committing its first markdown — the gate demanding a file that the change
# itself has no reason to touch.
WORKLOG="${DOCS_WORKLOG:-}"
if [ -z "$WORKLOG" ]; then
  if [ -f CHANGELOG.md ]; then WORKLOG="CHANGELOG.md"
  elif [ -f HISTORY.md ]; then WORKLOG="HISTORY.md"
  elif [ -f docs/agents/worklog.md ]; then WORKLOG="docs/agents/worklog.md"
  else WORKLOG=""
  fi
fi

# --- exempt (doc) extensions ---
DOCS_EXEMPT="${DOCS_EXEMPT:-md}"

# A file is "code" if its extension is not in DOCS_EXEMPT. Deleted files count too (they are changes).
is_code() {
  case "$1" in docs/audit/*) return 1;; esac
  ext="${1##*.}"
  case " $DOCS_EXEMPT " in
    *" $ext "*) return 1;;   # doc — exempt
    *) return 0;;            # code
  esac
}

# check_files <label>: read newline-delimited paths on stdin; fail if code changed but the worklog did not.
check_files() {
  label="$1"
  changed_code=0; touched_worklog=0
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    [ -n "$WORKLOG" ] && [ "$f" = "$WORKLOG" ] && touched_worklog=1
    is_code "$f" && changed_code=1
  done
  # No code changed -> nothing to document, regardless of whether a worklog exists.
  [ "$changed_code" -eq 1 ] || return 0
  if [ -z "$WORKLOG" ]; then
    echo "check-docs: $label changed code but this repo has no worklog target" >&2
    echo "  add CHANGELOG.md / HISTORY.md / docs/agents/worklog.md, or set DOCS_WORKLOG=<path>." >&2
    return 1
  fi
  if [ "$touched_worklog" -eq 0 ]; then
    echo "check-docs: $label changed code but not $WORKLOG" >&2
    echo "  add a line to $WORKLOG (once per PR is enough; see .agents/rules/documentation.md)" >&2
    return 1
  fi
  return 0
}

fail=0

need_ref() {
  git rev-parse --verify "$1^{commit}" >/dev/null 2>&1 || {
    echo "check-docs: ref '$1' not found — cannot verify doc currency" >&2
    exit 1
  }
}

case "${1:-}" in
  --since)
    ref="${2:?usage: check-docs.sh --since <ref>}"; need_ref "$ref"
    # merge-base, not REF itself: a PR that merged main in after REF must not be charged for main's files.
    base="$(git merge-base "$ref" HEAD)"
    git diff --name-only "$base" HEAD | check_files "this PR (${base%"${base#???????}"}..HEAD)" || fail=1
    ;;
  --each-commit)
    ref="${2:?usage: check-docs.sh --each-commit <ref>}"
    # GitHub sends forty zeros as `before` when the branch is new: there is no range, only HEAD.
    case "$ref" in *[!0]*) need_ref "$ref"; range="$ref..HEAD";; *) range="-1 HEAD";; esac
    # shellcheck disable=SC2086 # $range is deliberately two words in the new-branch case
    for sha in $(git rev-list $range); do
      [ "$(git rev-list --no-walk --count --merges "$sha")" -eq 0 ] || continue
      git show --name-only --format= "$sha" 2>/dev/null | check_files "commit $sha" || fail=1
    done
    ;;
  *)
    # A branch whose earlier commit already carries the worklog line may commit more code without
    # another one; the PR is what gets checked. The base is the remote default branch when known.
    branch_base=""
    for b in "${DOCS_BASE:-}" origin/HEAD origin/main; do
      [ -n "$b" ] && git rev-parse --verify -q "$b^{commit}" >/dev/null 2>&1 && { branch_base="$(git merge-base "$b" HEAD 2>/dev/null || true)"; break; }
    done
    { git diff --cached --name-only 2>/dev/null
      [ -n "$branch_base" ] && git diff --name-only "$branch_base" HEAD 2>/dev/null
      true; } | check_files "staged change" || fail=1
    ;;
esac

[ "$fail" -eq 0 ] && echo "check-docs: OK"
exit "$fail"
