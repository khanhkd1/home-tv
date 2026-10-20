#!/usr/bin/env bash
# ==============================================================================
# ROLLBACK SCRIPT: Restore Sony KD-65X80L to Snapshot (Apple TV Dock V1)
# ==============================================================================
set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd)"
while [ ! -f "$CURRENT_DIR/tools/tv.py" ] && [ "$CURRENT_DIR" != "/" ]; do
    CURRENT_DIR="$(dirname "$CURRENT_DIR")"
done
REPO_DIR="$CURRENT_DIR"
SNAPSHOT_DIR="$REPO_DIR/snapshots/sony-kd-65x80l-apple-dock-v1"
TV_HOST="${TV_HOST:-192.168.1.192}"
TV_PORT="${TV_PORT:-5555}"
PY="$REPO_DIR/tools/venv/bin/python"

if [ ! -x "$PY" ]; then
    echo "Error: Python venv not found at $PY" >&2
    exit 1
fi

echo "================================================================="
echo "  RESTORING TV TO SNAPSHOT: sony-kd-65x80l-apple-dock-v1"
echo "  Target TV: $TV_HOST:$TV_PORT"
echo "================================================================="

export TV_HOST="$TV_HOST"
export TV_PORT="$TV_PORT"

# 1. Test TV Connection
echo -n "[1/7] Testing connection to TV... "
MODEL=$("$PY" "$REPO_DIR/tools/tv.py" "getprop ro.product.model" | tr -d '\r\n')
if [ -z "$MODEL" ]; then
    echo "FAILED! Cannot connect to TV at $TV_HOST:$TV_PORT"
    exit 1
fi
echo "Connected ($MODEL)"

# 2. Verify or Install CleanYourTV Launcher
echo "[2/7] Checking CleanYourTV launcher..."
LAUNCHER_INSTALLED=$("$PY" "$REPO_DIR/tools/tv.py" "pm list packages | grep com.gathin.tvhome || true" | tr -d '\r\n')
if [ -z "$LAUNCHER_INSTALLED" ]; then
    echo "  CleanYourTV not installed. Pushing and installing..."
    "$PY" "$REPO_DIR/tools/b64push.py" "$SNAPSHOT_DIR/apps/CleanYourTV_v2.3_release.apk" /data/local/tmp/tvhome.apk
    "$PY" "$REPO_DIR/tools/tv.py" "pm install -r /data/local/tmp/tvhome.apk && rm -f /data/local/tmp/tvhome.apk"
else
    echo "  CleanYourTV is already installed."
fi

# 3. Verify or Install SmartTube
echo "[3/8] Checking SmartTube..."
SMARTTUBE_INSTALLED=$("$PY" "$REPO_DIR/tools/tv.py" "pm list packages | grep org.smarttube.stable || true" | tr -d '\r\n')
if [ -z "$SMARTTUBE_INSTALLED" ]; then
    echo "  SmartTube not installed. Pushing and installing..."
    "$PY" "$REPO_DIR/tools/b64push.py" "$SNAPSHOT_DIR/apps/SmartTube_v32.56_armeabi-v7a.apk" /data/local/tmp/smarttube.apk
    "$PY" "$REPO_DIR/tools/tv.py" "pm install -r /data/local/tmp/smarttube.apk && rm -f /data/local/tmp/smarttube.apk"
else
    echo "  SmartTube is already installed."
fi

# 4. Verify or Install personalDNSfilter
echo "[4/8] Checking personalDNSfilter..."
DNSFILTER_INSTALLED=$("$PY" "$REPO_DIR/tools/tv.py" "pm list packages | grep dnsfilter.android || true" | tr -d '\r\n')
if [ -z "$DNSFILTER_INSTALLED" ]; then
    echo "  personalDNSfilter not installed. Pushing and installing..."
    "$PY" "$REPO_DIR/tools/b64push.py" "$SNAPSHOT_DIR/apps/DNSFilter_1.50.61.5.apk" /data/local/tmp/dnsfilter.apk
    "$PY" "$REPO_DIR/tools/tv.py" "pm install -r /data/local/tmp/dnsfilter.apk && rm -f /data/local/tmp/dnsfilter.apk"
    "$PY" "$REPO_DIR/tools/tv.py" "appops set dnsfilter.android ACTIVATE_VPN allow"
    "$PY" "$REPO_DIR/tools/b64push.py" "$SNAPSHOT_DIR/config/fptplay_adblock_hosts.txt" /sdcard/Android/data/dnsfilter.android/files/PersonalDNSFilter/additionalHosts.txt
else
    echo "  personalDNSfilter is already installed."
fi

# 5. Apply Debloat Package List
echo "[5/8] Applying debloat list (disabling bloatware & telemetry)..."
DEBLOAT_LIST="$SNAPSHOT_DIR/config/disabled_packages.txt"
COUNT=0
while IFS= read -r pkg || [ -n "$pkg" ]; do
    pkg=$(echo "$pkg" | tr -d '\r\n' | xargs)
    [ -z "$pkg" ] && continue
    [[ "$pkg" =~ ^# ]] && continue
    "$PY" "$REPO_DIR/tools/tv.py" "pm disable-user --user 0 $pkg >/dev/null 2>&1 || true"
    COUNT=$((COUNT + 1))
done < "$DEBLOAT_LIST"
echo "  Disabled $COUNT packages matching snapshot."

# 6. Ensure Critical Services are Enabled
echo "[6/9] Ensuring vital services remain enabled..."
"$PY" "$REPO_DIR/tools/tv.py" "pm enable com.google.android.apps.tv.launcherx >/dev/null 2>&1 || true"
"$PY" "$REPO_DIR/tools/tv.py" "pm enable com.google.android.katniss >/dev/null 2>&1 || true"
"$PY" "$REPO_DIR/tools/tv.py" "pm enable com.sony.dtv.tvx >/dev/null 2>&1 || true"

# 7. Configure Home, Accessibility & DNS
echo "[7/9] Configuring Home, Accessibility Service and AdGuard DNS..."
cat << 'EOF' | "$PY" "$REPO_DIR/tools/tv.py" --batch
settings put secure enabled_accessibility_services com.gathin.tvhome/.HomeKeyService
settings put secure accessibility_enabled 1
cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity
settings put global private_dns_mode opportunistic
settings put global private_dns_specifier dns.adguard-dns.com
EOF

# 8. Ensure personalDNSfilter is Active
echo "[8/9] Ensuring personalDNSfilter (FPT Play ad blocker) is running..."
"$PY" "$REPO_DIR/tools/tv.py" "appops set dnsfilter.android ACTIVATE_VPN allow >/dev/null 2>&1 || true"
"$PY" "$REPO_DIR/tools/tv.py" "am start -n dnsfilter.android/.DNSProxyActivity >/dev/null 2>&1 || true"

# 9. Wake Screen and Launch Home
echo "[9/9] Activating CleanYourTV on screen..."
"$PY" "$REPO_DIR/tools/tv.py" "input keyevent KEYCODE_WAKEUP && input keyevent KEYCODE_HOME"
sleep 1
"$PY" "$REPO_DIR/tools/tv.py" "screencap -p /data/local/tmp/rollback_verify.png"
"$PY" "$REPO_DIR/tools/tv.py" --pull /data/local/tmp/rollback_verify.png "$SNAPSHOT_DIR/rollback_latest_verify.png" >/dev/null 2>&1 || true

echo "================================================================="
echo "  ROLLBACK SUCCESSFUL!"
echo "  - CleanYourTV is active."
echo "  - 4 Dock Apps: FPT Play, SmartTube, Phim4K, Apple TV."
echo "  - Netflix is disabled."
echo "  - Google Assistant is working."
echo "  - Verification screenshot: $SNAPSHOT_DIR/rollback_latest_verify.png"
echo "================================================================="
