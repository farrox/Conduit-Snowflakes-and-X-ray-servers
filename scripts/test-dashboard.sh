#!/bin/bash
# Test the dashboard functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "=========================================="
echo "Dashboard Test"
echo "=========================================="
echo ""

# Source dashboard functions
source "$SCRIPT_DIR/dashboard.sh" 2>/dev/null || {
    echo "Loading dashboard functions..."
}

# Find conduit process
CONDUIT_PID=$(ps aux | grep "[.]/dist/conduit start" | grep -v grep | awk '{print $2}' | head -1)

if [ -z "$CONDUIT_PID" ]; then
    echo "❌ Conduit is not running"
    echo ""
    echo "Start Conduit first:"
    echo "  ./dist/conduit start --psiphon-config ./psiphon_config.json -v --stats-file"
    exit 1
fi

echo "✅ Found Conduit process (PID: $CONDUIT_PID)"
echo ""

# Test process stats
echo "Testing process stats..."
CPU_RAM=$(ps -p $CONDUIT_PID -o %cpu,rss 2>/dev/null | tail -1)
CPU=$(echo "$CPU_RAM" | awk '{printf "%.1f%%", $1}')
RAM_KB=$(echo "$CPU_RAM" | awk '{print $2}')
RAM_MB=$(echo "scale=1; $RAM_KB / 1024" | bc)
echo "  CPU: $CPU"
echo "  RAM: ${RAM_MB}M"
echo ""

# Test stats file
echo "Testing stats file..."
if [ -f "data/stats.json" ]; then
    echo "  ✅ Stats file exists"
    if command -v python3 &> /dev/null; then
        CONN=$(python3 -c "import json; print(json.load(open('data/stats.json')).get('connectedClients', 0))" 2>/dev/null || echo "0")
        UP=$(python3 -c "import json; print(json.load(open('data/stats.json')).get('totalBytesUp', 0))" 2>/dev/null || echo "0")
        DOWN=$(python3 -c "import json; print(json.load(open('data/stats.json')).get('totalBytesDown', 0))" 2>/dev/null || echo "0")
        echo "  Connected Iranians: $CONN"
        echo "  Bytes Up: $UP"
        echo "  Bytes Down: $DOWN"
    fi
else
    echo "  ⚠️  Stats file not created yet"
    echo "  (Will be created when first stats are recorded)"
fi

echo ""
echo "=========================================="
echo "✅ Dashboard Test Complete"
echo "=========================================="
echo ""
echo "To view live dashboard:"
echo "  ./scripts/dashboard.sh"
echo ""
