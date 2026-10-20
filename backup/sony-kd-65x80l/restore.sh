#!/usr/bin/env bash
# Restore script for Sony KD-65X80L (BRAVIA_VH22)
set -euo pipefail

TV_HOST="${TV_HOST:-192.168.1.192}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PY="$REPO_DIR/tools/venv/bin/python"

if [ ! -x "$PY" ]; then
    PY="python3"
fi

echo "Connecting to Sony TV at $TV_HOST to restore stock state..."

# 1. Re-enable all disabled packages from debloat list if exists
if [ -f "$SCRIPT_DIR/debloated_packages.txt" ]; then
    echo "Re-enabling packages from debloated_packages.txt..."
    grep -vE '^\s*(#|$)' "$SCRIPT_DIR/debloated_packages.txt" | awk '{print "pm enable " $1}' | TV_HOST="$TV_HOST" "$PY" "$REPO_DIR/tools/tv.py" --batch
fi

# 2. Re-enable stock Google TV Launcher and setup wizard
cat << 'EOF' | TV_HOST="$TV_HOST" "$PY" "$REPO_DIR/tools/tv.py" --batch
pm enable com.google.android.apps.tv.launcherx
pm enable com.google.android.tungsten.setupwraith
cmd package set-home-activity --user 0 com.google.android.apps.tv.launcherx/com.google.android.apps.tv.launcherx.home.HomeActivity
settings put global window_animation_scale 1.0
settings put global transition_animation_scale 1.0
settings put global animator_duration_scale 1.0
settings put global private_dns_mode opportunistic
pm list packages -d
EOF

echo "Restore complete! Stock Google TV Launcher is now active."
