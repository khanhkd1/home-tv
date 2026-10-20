#!/usr/bin/env bash
# Helper script to manage personalDNSfilter on Sony Android TV
# Usage:
#   tools/manage_dnsfilter.sh status
#   tools/manage_dnsfilter.sh start
#   tools/manage_dnsfilter.sh stop
#   tools/manage_dnsfilter.sh restart
#   tools/manage_dnsfilter.sh push-rules
#   tools/manage_dnsfilter.sh test

set -euo pipefail

TV_HOST="${TV_HOST:-192.168.1.192}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PYTHON="$REPO_ROOT/tools/venv/bin/python"
TV_PY="$REPO_ROOT/tools/tv.py"

run_tv() {
  TV_HOST="$TV_HOST" "$PYTHON" "$TV_PY" "$1"
}

action="${1:-status}"

case "$action" in
  status)
    echo "=== Checking personalDNSfilter status on TV ($TV_HOST) ==="
    run_tv "ps -ef | grep -i dnsfilter | grep -v grep || true"
    echo "=== TUN interface status ==="
    run_tv "ip addr show tun0 2>/dev/null || echo 'tun0 interface is down'"
    ;;
  start)
    echo "=== Starting personalDNSfilter ==="
    run_tv "am start -n dnsfilter.android/.DNSProxyActivity"
    echo "Done. Waiting for tun0..."
    sleep 2
    run_tv "ip addr show tun0 2>/dev/null || true"
    ;;
  stop)
    echo "=== Stopping personalDNSfilter ==="
    run_tv "am force-stop dnsfilter.android"
    echo "personalDNSfilter stopped."
    ;;
  restart)
    echo "=== Restarting personalDNSfilter ==="
    run_tv "am force-stop dnsfilter.android"
    sleep 1
    run_tv "am start -n dnsfilter.android/.DNSProxyActivity"
    sleep 2
    run_tv "ip addr show tun0 2>/dev/null || true"
    ;;
  push-rules)
    echo "=== Pushing custom rules to personalDNSfilter ==="
    RULES_FILE="$REPO_ROOT/snapshots/sony-kd-65x80l-apple-dock-v1/config/fptplay_adblock_hosts.txt"
    if [ ! -f "$RULES_FILE" ]; then
      echo "Rules file not found at $RULES_FILE"
      exit 1
    fi
    TV_HOST="$TV_HOST" "$PYTHON" "$REPO_ROOT/tools/b64push.py" "$RULES_FILE" "/sdcard/Android/data/dnsfilter.android/files/PersonalDNSFilter/additionalHosts.txt"
    echo "Restarting service to reload rules..."
    run_tv "am force-stop dnsfilter.android && sleep 1 && am start -n dnsfilter.android/.DNSProxyActivity"
    ;;
  test)
    echo "=== Testing DNS resolution on TV ==="
    echo "1. Ad domain (should be 127.0.0.1):"
    run_tv "ping -c 1 d.adsplay.net 2>&1 | head -n 2"
    echo "2. Ad CDN (should be 127.0.0.1):"
    run_tv "ping -c 1 ads-cdn.fptplay.net 2>&1 | head -n 2"
    echo "3. Streaming domain (should be real public IP):"
    run_tv "ping -c 1 fptplay.vn 2>&1 | head -n 2"
    ;;
  *)
    echo "Unknown action: $action"
    echo "Usage: $0 {status|start|stop|restart|push-rules|test}"
    exit 1
    ;;
esac
