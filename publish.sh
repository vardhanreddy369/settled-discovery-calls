#!/bin/bash
# Publish the discovery-call booking page to GitHub Pages.
#
#   ./publish.sh              # commit any change and push
#   ./publish.sh "message"    # with your own commit message
#
# Uses a deploy key scoped to this one repo, because `gh auth token` comes back
# empty from cron (no keychain session) — the same trap the outreach board hit.
set -euo pipefail
cd "$(dirname "$0")"

KEY="$HOME/.ssh/settled_calls_deploy"
[ -f "$KEY" ] || { echo "missing deploy key at $KEY"; exit 1; }
export GIT_SSH_COMMAND="ssh -i $KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

# The page is public. Nobody else's address is allowed to ride along.
# URLs are stripped first: a Google Fonts href carries "wght@400", which is not
# an email but matches a naive pattern.
strays() {
  sed -E 's#https?://[^"'"'"' )]+##g' index.html \
    | grep -oE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' \
    | grep -vx 'sr849057@ucf.edu' | sort -u
}
if [ -n "$(strays)" ]; then
  echo "refusing to publish: an address other than sr849057@ucf.edu is on the page"
  strays
  exit 1
fi

git add -A
if git diff --cached --quiet; then
  echo "nothing changed"
else
  git -c user.email="sr849057@ucf.edu" -c user.name="Sri Vardhan Reddy Gutta" \
      commit -q -m "${1:-Update the booking page}"
fi
git push -q origin main
echo "published: https://vardhanreddy369.github.io/settled-discovery-calls/"
