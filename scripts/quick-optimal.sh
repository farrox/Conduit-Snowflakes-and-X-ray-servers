#!/bin/bash
# Quick script to start Conduit with optimal settings
# Usage: ./scripts/quick-optimal.sh [bandwidth_mbps] [max_clients]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Default values
BANDWIDTH=${1:-""}
MAX_CLIENTS=${2:-""}

# If not provided, try to auto-detect or use defaults
if [ -z "$BANDWIDTH" ]; then
    # Try to get bandwidth from speedtest if available
    if command -v speedtest &> /dev/null; then
        echo "Testing bandwidth..."
        DOWNLOAD=$(speedtest --accept-license --format=json --progress=no 2>/dev/null | \
            python3 -c "import sys, json; data=json.load(sys.stdin); print(round(data.get('download', {}).get('bandwidth', 0) / 1000000, 2))" 2>/dev/null || echo "0")
        
        if [ -n "$DOWNLOAD" ] && [ "$DOWNLOAD" != "0" ]; then
            # Use 60% of available bandwidth
            BANDWIDTH=$(echo "$DOWNLOAD * 0.6" | bc -l | xargs printf "%.1f")
            echo "Detected bandwidth: ${DOWNLOAD} Mbps → Using ${BANDWIDTH} Mbps (60%)"
        else
            BANDWIDTH=20  # Default fallback
            echo "Using default bandwidth: ${BANDWIDTH} Mbps"
        fi
    else
        BANDWIDTH=20  # Default
        echo "Using default bandwidth: ${BANDWIDTH} Mbps"
    fi
fi

# Calculate max clients if not provided
if [ -z "$MAX_CLIENTS" ]; then
    # Aim for ~0.15 Mbps per client
    MAX_CLIENTS=$(echo "$BANDWIDTH / 0.15" | bc -l | xargs printf "%.0f")
    
    # Cap at 1000
    if [ "$MAX_CLIENTS" -gt 1000 ]; then
        MAX_CLIENTS=1000
    fi
    
    # Minimum 10
    if [ "$MAX_CLIENTS" -lt 10 ]; then
        MAX_CLIENTS=10
    fi
fi

# Ensure bandwidth is capped at 40
if (( $(echo "$BANDWIDTH > 40" | bc -l) )); then
    BANDWIDTH=40
fi

echo ""
echo "Starting Conduit with optimal settings:"
echo "  Max Clients: $MAX_CLIENTS"
echo "  Bandwidth:   $BANDWIDTH Mbps"
echo ""

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

# Start Conduit
./dist/conduit start $CONFIG_ARG \
    --max-clients "$MAX_CLIENTS" \
    --bandwidth "$BANDWIDTH" \
    -v
