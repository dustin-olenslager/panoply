#!/usr/bin/env bash
# One-time: put the template under version control and publish it, so degit has something to fetch
# and semver tags become the version anchor. Run once from the template root.
# Idempotent enough to re-read before running; it stops if a repo already exists.
set -euo pipefail

REPO_SLUG="dustin-olenslager/panoply"
AUTHOR_NAME="the owner"
AUTHOR_EMAIL="94700316+dustin-olenslager@users.noreply.github.com"

cd "$(dirname "$0")/.." 2>/dev/null || cd "$(pwd)"

if [ -d .git ]; then
  echo "A git repo already exists here. Nothing to init." >&2
  exit 1
fi

# Never publish settings.local.json or personal overrides.
if [ ! -f .gitignore ] || ! grep -q 'settings.local.json' .gitignore 2>/dev/null; then
  {
    echo ".claude/settings.local.json"
    echo "CLAUDE.local.md"
    echo ".claude-kit-tmp/"
  } >> .gitignore
fi

git init
# Author every commit as the operator, per the global identity rule. Repo-local, not --global.
git config user.name  "$AUTHOR_NAME"
git config user.email "$AUTHOR_EMAIL"

git add -A
git commit -m "chore: seed panoply kit"

# Requires an authenticated gh CLI. Private by default.
gh repo create "$REPO_SLUG" --private --source=. --push

# Version anchor. degit and CHANGELOG.md both key off these tags.
git tag -a v1.0.0 -m "v1.0.0 — initial kit"
git push origin v1.0.0

echo
echo "Done. Fetch it anywhere with:  npx degit $REPO_SLUG <dest>"
echo "Tag the next governance change (see CHANGELOG.md) with:  git tag -a vX.Y.Z -m '…' && git push origin vX.Y.Z"
