#!/usr/bin/env bash
set -euo pipefail

mkdir -p /tmp/obsidian-config /tmp/obsidian-cache /gallery/staged
rm -f /gallery/staged/*.png

Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp &
xvfb_pid=$!
trap 'kill "$xvfb_pid" 2>/dev/null || true; wait "$xvfb_pid" 2>/dev/null || true' EXIT

for _ in {1..50}; do
  if xdotool getdisplaygeometry >/dev/null 2>&1; then
    npm run capture
    node /workspace/tools/gallery/verify-obsidian-lock.mjs
    exit $?
  fi
  sleep 0.1
done

echo "Xvfb did not become ready" >&2
exit 1
