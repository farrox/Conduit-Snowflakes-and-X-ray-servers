#!/bin/bash
# Start Conduit with stats enabled and open dashboard
# Usage: ./scripts/start-with-dashboard.sh [max-clients] [bandwidth]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

MAX_CLIENTS=${1:-50}
BANDWIDTH=${2:-5}

# Check if binary exists
if [ ! -f "./dist/conduit" ]; then
    echo "Error: Binary not found. Run 'make build' first."
    exit 1
fi

# Check for config
CONFIG_ARG=""
if [ -f "./psiphon_config.json" ]; then
    CONFIG_ARG="--psiphon-config ./psiphon_config.json"
else
    echo "Warning: psiphon_config.json not found. Using embedded config if available."
fi

echo "Starting Conduit with dashboard..."
echo "  Max Clients: $MAX_CLIENTS"
echo "  Bandwidth:   $BANDWIDTH Mbps"
echo ""

# Start Conduit in background with stats file
./dist/conduit start $CONFIG_ARG \
    --max-clients "$MAX_CLIENTS" \
    --bandwidth "$BANDWIDTH" \
    -v \
    --stats-file > /tmp/conduit.log 2>&1 &

CONDUIT_PID=$!
echo "Conduit started (PID: $CONDUIT_PID)"
echo "Logs: /tmp/conduit.log"
echo ""

# Wait a moment for it to start
sleep 3

# Check if it's still running
if ps -p $CONDUIT_PID > /dev/null 2>&1; then
    echo "✅ Conduit is running"
    echo ""
    echo "Opening dashboard in 2 seconds..."
    sleep 2
    
    # Open dashboard in new terminal window
    osascript <<APPLESCRIPT
tell application "Terminal"
    activate
    do script "cd '$PROJECT_ROOT' && ./scripts/dashboard.sh"
end tell
APPLESCRIPT
    
    echo ""
    echo "Dashboard opened in new terminal window."
    echo ""
    echo "To stop Conduit:"
    echo "  kill $CONDUIT_PID"
    echo ""
    echo "Or press Ctrl+C in the Conduit terminal window."
else
    echo "❌ Conduit failed to start"
    echo "Check logs: /tmp/conduit.log"
    exit 1
fi
