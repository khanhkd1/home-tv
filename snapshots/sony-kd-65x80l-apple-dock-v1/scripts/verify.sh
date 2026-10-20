#!/usr/bin/env bash
# Quick verification script for Sony KD-65X80L snapshot status
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
while [ ! -f "$CURRENT_DIR/tools/tv.py" ] && [ "$CURRENT_DIR" != "/" ]; do
    CURRENT_DIR="$(dirname "$CURRENT_DIR")"
done
REPO_DIR="$CURRENT_DIR"
SNAPSHOT_DIR="$REPO_DIR/snapshots/sony-kd-65x80l-apple-dock-v1"
TV_HOST="${TV_HOST:-192.168.1.192}"
PY="$REPO_DIR/tools/venv/bin/python"

export TV_HOST="$TV_HOST"

echo "=== Verifying Snapshot Status on TV ($TV_HOST) ==="
"$PY" "$REPO_DIR/tools/tv.py" "pm list packages | grep -E 'com.gathin.tvhome|org.smarttube.stable|net.fptplay.ottbox|com.oxootv.spagreen|com.apple.atve.sony.appletv|dnsfilter.android'"
echo "--- PersonalDNSFilter TUN Status ---"
"$PY" "$REPO_DIR/tools/tv.py" "ip addr show tun0 2>/dev/null | grep 'inet ' || echo 'tun0 down'"
echo "--- Accessibility Services ---"
"$PY" "$REPO_DIR/tools/tv.py" "settings get secure enabled_accessibility_services"
echo "--- Disabled Netflix Packages ---"
"$PY" "$REPO_DIR/tools/tv.py" "pm list packages -d | grep netflix"
echo "--- Capturing Screenshot ---"
"$PY" "$REPO_DIR/tools/tv.py" "screencap -p /data/local/tmp/verify.png"
"$PY" "$REPO_DIR/tools/tv.py" --pull /data/local/tmp/verify.png "$SNAPSHOT_DIR/verify_screen.png"
echo "Screenshot saved to: $SNAPSHOT_DIR/verify_screen.png"
