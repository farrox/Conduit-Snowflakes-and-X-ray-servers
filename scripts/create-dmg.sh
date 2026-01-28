#!/bin/bash
# Create a DMG installer for macOS
# Usage: ./scripts/create-dmg.sh [path/to/psiphon_config.json]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PSIPHON_CONFIG="${1:-$PROJECT_ROOT/psiphon_config.json}"

# Check if config exists
if [ ! -f "$PSIPHON_CONFIG" ]; then
    echo "Error: Psiphon config not found: $PSIPHON_CONFIG"
    echo "Usage: $0 [path/to/psiphon_config.json]"
    echo ""
    echo "You need a valid Psiphon config file. Contact info@psiphon.ca to obtain one."
    exit 1
fi

# Check if Go 1.24 is available
if ! command -v go &> /dev/null; then
    echo "Error: Go is not installed or not in PATH"
    echo "Please install Go 1.24.x first"
    exit 1
fi

GO_VERSION=$(go version | grep -oE 'go[0-9]+\.[0-9]+' | sed 's/go//')
GO_MAJOR=$(echo $GO_VERSION | cut -d. -f1)
GO_MINOR=$(echo $GO_VERSION | cut -d. -f2)

if [ "$GO_MAJOR" -gt 1 ] || ([ "$GO_MAJOR" -eq 1 ] && [ "$GO_MINOR" -ge 25 ]); then
    echo "Error: Go $GO_VERSION detected, but Go 1.24.x is required"
    exit 1
fi

echo "Building Conduit with embedded config..."
cd "$PROJECT_ROOT"

# Ensure setup is done
if [ ! -d "psiphon-tunnel-core" ]; then
    echo "Running initial setup..."
    make setup
fi

# Build with embedded config for Intel Mac
echo "Building for macOS Intel (amd64)..."
GOOS=darwin GOARCH=amd64 make build-embedded PSIPHON_CONFIG="$PSIPHON_CONFIG"

# Create DMG structure
DMG_NAME="Conduit-$(date +%Y%m%d)"
DMG_DIR="$PROJECT_ROOT/dist/$DMG_NAME"
DMG_FILE="$PROJECT_ROOT/dist/${DMG_NAME}.dmg"

echo "Creating DMG structure..."
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy binary
cp "$PROJECT_ROOT/dist/conduit" "$DMG_DIR/Conduit"
chmod +x "$DMG_DIR/Conduit"

# Create Applications symlink
ln -s /Applications "$DMG_DIR/Applications"

# Create README
cat > "$DMG_DIR/README.txt" << 'EOF'
Conduit - Psiphon Proxy Node
============================

QUICK START:
1. Drag "Conduit" to your Applications folder
2. Open Terminal
3. Run: /Applications/Conduit start

Or double-click "Start Conduit.command" to run it automatically.

For more information, see the documentation at:
https://github.com/farrox/Conduit-Snowflakes-and-X-ray-servers

IMPORTANT:
- This binary includes an embedded Psiphon configuration
- Keep this DMG safe - you'll need it if you want to reinstall
- The first run will create keys in ~/.conduit/data/

TROUBLESHOOTING:
If you get "permission denied", run:
  chmod +x /Applications/Conduit

To see what's happening, run with verbose mode:
  /Applications/Conduit start -v
EOF

# Create launcher script (starts Conduit + live dashboard, like Docker manager)
cat > "$DMG_DIR/Start Conduit.command" << 'LAUNCHER'
#!/bin/bash
# Start Conduit with live dashboard (similar to Option 1 Docker manager)
APP_PATH="/Applications/Conduit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONDUIT_DATA="${HOME}/.conduit/data"
LOG_FILE="${CONDUIT_DATA}/conduit.log"
STATS_FILE="${CONDUIT_DATA}/stats.json"

if [ -f "$SCRIPT_DIR/Conduit" ]; then
    CONDUIT="$SCRIPT_DIR/Conduit"
elif [ -f "$APP_PATH" ]; then
    CONDUIT="$APP_PATH"
else
    echo "Error: Conduit binary not found. Drag Conduit to Applications first."
    exit 1
fi

mkdir -p "$CONDUIT_DATA"

# Colors
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

find_pid() { pgrep -f "Conduit start" 2>/dev/null | head -1; }
fmt_bytes() {
    local b=$1
    [ -z "$b" ] || [ "$b" = "0" ] && echo "0B" && return
    if [ "$b" -lt 1024 ]; then echo "${b}B"
    elif [ "$b" -lt 1048576 ]; then echo "$(awk "BEGIN{printf \"%.1f\", $b/1024}")KB"
    elif [ "$b" -lt 1073741824 ]; then echo "$(awk "BEGIN{printf \"%.1f\", $b/1048576}")MB"
    else echo "$(awk "BEGIN{printf \"%.1f\", $b/1073741824}")GB"; fi
}
cpu_ram() {
    local pid=$1
    [ -z "$pid" ] && echo "0%|0B" && return
    ps -p "$pid" -o %cpu,rss 2>/dev/null | tail -1 | awk '{printf "%.1f%%|%.1fM", $1, $2/1024}' || echo "0%|0B"
}
traffic_stats() {
    if [ -f "$STATS_FILE" ] && command -v python3 &>/dev/null; then
        python3 -c "
import json, os
d=json.load(open('$STATS_FILE'))
c=d.get('connectedClients',0)
u=d.get('totalBytesUp',0)
dwn=d.get('totalBytesDown',0)
def f(b):
    if b<1024: return str(b)+'B'
    if b<1048576: return '%.1fKB'%(b/1024)
    if b<1073741824: return '%.1fMB'%(b/1048576)
    return '%.1fGB'%(b/1073741824)
print(c,'|',f(u),'|',f(dwn))
" 2>/dev/null || echo "0|0B|0B"
    else
        local line
        line=$(grep "\[STATS\]" "$LOG_FILE" 2>/dev/null | tail -1)
        if [ -n "$line" ]; then
            local c up down
            c=$(echo "$line" | sed -n 's/.*Connected:[[:space:]]*\([0-9]*\).*/\1/p')
            up=$(echo "$line" | sed -n 's/.*Up:[[:space:]]*\([^|]*\).*/\1/p' | tr -d ' ')
            down=$(echo "$line" | sed -n 's/.*Down:[[:space:]]*\([^|]*\).*/\1/p' | tr -d ' ')
            echo "${c:-0}|${up:-0B}|${down:-0B}"
        else
            echo "0|0B|0B"
        fi
    fi
}

# Start Conduit in background (use -d so stats and log paths are predictable)
"$CONDUIT" start -v --stats-file -d "$CONDUIT_DATA" >> "$LOG_FILE" 2>&1 &
BPID=$!
sleep 2
if ! kill -0 "$BPID" 2>/dev/null; then
    echo "Conduit failed to start. Check: $LOG_FILE"
    exit 1
fi

cleanup() { kill "$BPID" 2>/dev/null; echo -e "\n${CYAN}Dashboard closed. Conduit stopped.${NC}"; exit 0; }
trap cleanup SIGINT SIGTERM

while true; do
    clear
    echo -e "${CYAN}"
    echo "  ██████╗ ██████╗ ███╗   ██╗██████╗ ██╗   ██╗██╗████████╗"
    echo " ██╔════╝██╔═══██╗████╗  ██║██╔══██╗██║   ██║██║╚══██╔══╝"
    echo " ██║     ██║   ██║██╔██╗ ██║██║  ██║██║   ██║██║   ██║   "
    echo " ██║     ██║   ██║██║╚██╗██║██║  ██║██║   ██║██║   ██║   "
    echo " ╚██████╗╚██████╔╝██║ ╚████║██████╔╝╚██████╔╝██║   ██║   "
    echo "  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝   ╚═╝   "
    echo -e "              ${YELLOW}macOS Professional Edition${CYAN}                  "
    echo -e "${NC}"
    echo -e "${BOLD}LIVE DASHBOARD${NC} (Press ${YELLOW}Ctrl+C${NC} to exit)"
    echo "══════════════════════════════════════════════════════"

    PID=$(find_pid)
    if [ -n "$PID" ]; then
        CR=$(cpu_ram "$PID"); CPU=$(echo "$CR"|cut -d'|' -f1); RAM=$(echo "$CR"|cut -d'|' -f2)
        TR=$(traffic_stats "$PID"); CONN=$(echo "$TR"|cut -d'|' -f1); UP=$(echo "$TR"|cut -d'|' -f2); DOWN=$(echo "$TR"|cut -d'|' -f3)
        UPTIME=$(ps -p "$PID" -o etime= 2>/dev/null | tr -d ' ')
        echo -e " STATUS:      ${GREEN}● ONLINE${NC}"
        echo -e " UPTIME:      ${UPTIME:-—}"
        echo "──────────────────────────────────────────────────────"
        printf " %-15s | %-15s \n" "RESOURCES" "TRAFFIC"
        echo "──────────────────────────────────────────────────────"
        printf " CPU: ${YELLOW}%-9s${NC} | Iranians: ${GREEN}%-9s${NC} \n" "$CPU" "$CONN"
        printf " RAM: ${YELLOW}%-9s${NC} | Up:    ${CYAN}%-9s${NC} \n" "$RAM" "$UP"
        printf "              | Down:  ${CYAN}%-9s${NC} \n" "$DOWN"
    else
        echo -e " STATUS:      ${RED}● OFFLINE${NC}"
        echo "──────────────────────────────────────────────────────"
        echo " Conduit is not running."
    fi
    echo "══════════════════════════════════════════════════════"
    echo -e "${YELLOW}Refreshing every 5 seconds...${NC}"
    sleep 5
done
LAUNCHER

chmod +x "$DMG_DIR/Start Conduit.command"

# Create the DMG
echo "Creating DMG file..."
rm -f "$DMG_FILE"

hdiutil create -volname "Conduit" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$DMG_FILE"

echo ""
echo "✓ DMG created successfully: $DMG_FILE"
echo ""
echo "To distribute:"
echo "  1. Test the DMG by mounting it: open $DMG_FILE"
echo "  2. Upload to your website or GitHub releases"
echo "  3. Users can download, mount, and drag to Applications"
