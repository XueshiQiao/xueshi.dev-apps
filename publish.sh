#!/bin/bash
# Publishes apps.json: pushes this repository to GitHub, asks jsDelivr to
# refresh its copy, then checks that every address the apps read returns the
# revision that was just pushed.
#
# Usage: ./publish.sh        (after committing the change to apps.json)
set -euo pipefail
cd "$(dirname "$0")"

if [ -n "$(git status --porcelain)" ]; then
  echo "There are uncommitted changes. Commit them first." >&2
  exit 1
fi
jq -e '.schema == 1 and (.revision | type == "number") and (.apps | length > 0)' apps.json > /dev/null \
  || { echo "apps.json is not a valid list." >&2; exit 1; }
revision=$(jq .revision apps.json)

git push origin main

# owner/repository, read from the remote so it is not written down twice
slug=$(git remote get-url origin | sed -E 's#.*github\.com[:/]##; s#\.git$##')

# jsDelivr keeps a branch's files for up to 12 hours unless told to refresh.
curl -fsS --max-time 30 "https://purge.jsdelivr.net/gh/$slug@main/apps.json" > /dev/null \
  && echo "jsDelivr: refresh requested" || echo "jsDelivr: refresh request failed (it will catch up within 12 hours)"

addresses=(
  "https://raw.githubusercontent.com/$slug/main/apps.json"
  "https://cdn.jsdelivr.net/gh/$slug@main/apps.json"
  "https://fastly.jsdelivr.net/gh/$slug@main/apps.json"
  "https://gcore.jsdelivr.net/gh/$slug@main/apps.json"
)
echo "Checking that every address serves revision $revision (they can take a minute to catch up)..."
late=0
for address in "${addresses[@]}"; do
  host=$(echo "$address" | sed -E 's#https://([^/]+)/.*#\1#')
  got=""
  for attempt in 1 2 3 4 5 6; do
    got=$(curl -fsSL --max-time 20 "$address?t=$(date +%s)" 2>/dev/null | jq -r '.revision' 2>/dev/null || true)
    [ "$got" = "$revision" ] && break
    sleep 10
  done
  if [ "$got" = "$revision" ]; then
    echo "  ok    $host"
  else
    echo "  late  $host (serves revision ${got:-nothing})"
    late=1
  fi
done
[ "$late" = 0 ] && echo "Published revision $revision everywhere." \
  || echo "Pushed. Some addresses still serve an older revision; apps use the newest one they can reach."
