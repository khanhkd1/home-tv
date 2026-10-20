#!/usr/bin/env bash
# Build and install script for CleanYourTV on Sony KD-65X80L
set -euo pipefail

TV_HOST="${TV_HOST:-192.168.1.192}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PY="$REPO_DIR/tools/venv/bin/python"

echo "=== Building launcher APK inside Docker ARM64 ==="
docker run --rm -v "$REPO_DIR/launcher:/workspace" -v "$REPO_DIR/.docker-android:/root/.android" -w /workspace android-build-arm64 bash -c "chmod +x gradlew && ./gradlew assembleRelease --no-daemon"

APK="$REPO_DIR/launcher/app/build/outputs/apk/release/app-release.apk"
if [ ! -f "$APK" ]; then
    echo "Error: APK not found at $APK" >&2
    exit 1
fi

echo "=== Pushing APK to Sony TV ($TV_HOST) ==="
TV_HOST="$TV_HOST" "$PY" "$REPO_DIR/tools/b64push.py" "$APK" /data/local/tmp/tvhome.apk

echo "=== Installing and activating CleanYourTV ==="
cat << 'EOF' | TV_HOST="$TV_HOST" "$PY" "$REPO_DIR/tools/tv.py" --batch
pm install -r /data/local/tmp/tvhome.apk
rm -f /data/local/tmp/tvhome.apk
pm grant com.gathin.tvhome android.permission.ACCESS_FINE_LOCATION 2>/dev/null; echo location-granted
cmd package compile -m speed -f com.gathin.tvhome
am start -W -n com.gathin.tvhome/.MainActivity
pm enable com.google.android.apps.tv.launcherx
cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity
settings put secure enabled_accessibility_services com.gathin.tvhome/.HomeKeyService
settings put secure accessibility_enabled 1
cmd package resolve-activity --brief -c android.intent.category.HOME -a android.intent.action.MAIN
EOF

echo "Done! CleanYourTV is active on your Sony TV."
