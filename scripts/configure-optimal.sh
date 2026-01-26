#!/bin/bash
# Interactive script to configure optimal Conduit settings
# Calculates max-clients and bandwidth based on your available bandwidth

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Conduit Optimal Configuration Helper"
echo "=========================================="
echo ""

# Function to test bandwidth
test_bandwidth() {
    echo "Testing your internet bandwidth..."
    echo ""
    
    # Try Ookla speedtest if available
    if command -v speedtest &> /dev/null; then
        echo "Running Ookla Speedtest..."
        speedtest --accept-license --format=json --progress=no > /tmp/speedtest_result.json 2>&1
        
        # Parse results
        DOWNLOAD=$(cat /tmp/speedtest_result.json 2>/dev/null | python3 -c "
import sys, json
try:
    content = sys.stdin.read()
    lines = content.split('\n')
    json_line = None
    for line in lines:
        if line.strip().startswith('{'):
            json_line = line
            break
    if json_line:
        data = json.loads(json_line)
        dl = round(data.get('download', {}).get('bandwidth', 0) / 1000000, 2)
        print(f'{dl}')
    else:
        print('0')
except:
    print('0')
" 2>/dev/null)
        
        if [ -n "$DOWNLOAD" ] && [ "$DOWNLOAD" != "0" ]; then
            echo "✓ Download speed: ${DOWNLOAD} Mbps"
            echo "$DOWNLOAD"
            return
        fi
    fi
    
    # Fallback: ask user
    echo "Automatic bandwidth test not available."
    echo "Please enter your download speed in Mbps:"
    read -p "Download speed (Mbps): " DOWNLOAD
    echo "$DOWNLOAD"
}

# Function to calculate optimal settings
calculate_optimal() {
    local available_bandwidth=$1
    local max_clients=$2
    
    # Calculate bandwidth per client (aim for ~0.1-0.2 Mbps per client minimum)
    # For max capacity, we want to use 50-70% of available bandwidth
    local recommended_bandwidth=$(echo "$available_bandwidth * 0.6" | bc -l | xargs printf "%.1f")
    
    # If user specified max clients, use that; otherwise calculate
    if [ -z "$max_clients" ] || [ "$max_clients" = "0" ]; then
        # Calculate max clients: aim for ~0.15 Mbps per client
        max_clients=$(echo "$available_bandwidth * 0.6 / 0.15" | bc -l | xargs printf "%.0f")
        
        # Cap at 1000 (maximum allowed)
        if [ "$max_clients" -gt 1000 ]; then
            max_clients=1000
        fi
        
        # Minimum 10 clients
        if [ "$max_clients" -lt 10 ]; then
            max_clients=10
        fi
    fi
    
    # Ensure bandwidth is reasonable
    if (( $(echo "$recommended_bandwidth < 1" | bc -l) )); then
        recommended_bandwidth=1
    fi
    
    # Cap bandwidth at 40 Mbps (per documentation)
    if (( $(echo "$recommended_bandwidth > 40" | bc -l) )); then
        recommended_bandwidth=40
    fi
    
    echo "$max_clients|$recommended_bandwidth"
}

# Main configuration flow
echo "This script will help you configure optimal Conduit settings."
echo ""
echo "Options:"
echo "  1. Auto-detect bandwidth and calculate optimal settings"
echo "  2. Enter bandwidth manually"
echo "  3. Enter both bandwidth and max-clients manually"
echo ""
read -p "Choose option (1-3): " option

case $option in
    1)
        AVAILABLE_BW=$(test_bandwidth)
        if [ -z "$AVAILABLE_BW" ] || [ "$AVAILABLE_BW" = "0" ]; then
            echo "Error: Could not determine bandwidth"
            exit 1
        fi
        RESULT=$(calculate_optimal "$AVAILABLE_BW" "")
        MAX_CLIENTS=$(echo "$RESULT" | cut -d'|' -f1)
        BANDWIDTH=$(echo "$RESULT" | cut -d'|' -f2)
        ;;
    2)
        read -p "Enter your available download bandwidth (Mbps): " AVAILABLE_BW
        if [ -z "$AVAILABLE_BW" ]; then
            echo "Error: Bandwidth required"
            exit 1
        fi
        RESULT=$(calculate_optimal "$AVAILABLE_BW" "")
        MAX_CLIENTS=$(echo "$RESULT" | cut -d'|' -f1)
        BANDWIDTH=$(echo "$RESULT" | cut -d'|' -f2)
        ;;
    3)
        read -p "Enter your available download bandwidth (Mbps): " AVAILABLE_BW
        read -p "Enter max clients (1-1000, or press Enter for auto): " MAX_CLIENTS_INPUT
        if [ -z "$MAX_CLIENTS_INPUT" ]; then
            RESULT=$(calculate_optimal "$AVAILABLE_BW" "")
            MAX_CLIENTS=$(echo "$RESULT" | cut -d'|' -f1)
        else
            MAX_CLIENTS=$MAX_CLIENTS_INPUT
            RESULT=$(calculate_optimal "$AVAILABLE_BW" "$MAX_CLIENTS")
            MAX_CLIENTS=$(echo "$RESULT" | cut -d'|' -f1)
        fi
        BANDWIDTH=$(echo "$RESULT" | cut -d'|' -f2)
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Recommended Optimal Settings:"
echo "=========================================="
echo "  Max Clients: $MAX_CLIENTS"
echo "  Bandwidth:   $BANDWIDTH Mbps"
echo ""
echo "These settings use ~60% of your bandwidth, leaving 40% for your own use."
echo ""

# Ask if user wants to save these settings
read -p "Save these settings to a launcher script? (y/n): " save
if [ "$save" = "y" ] || [ "$save" = "Y" ]; then
    LAUNCHER_FILE="$PROJECT_ROOT/Start Conduit (Optimal).command"
    
    cat > "$LAUNCHER_FILE" << EOF
#!/bin/bash
# Optimal Conduit launcher with pre-configured settings

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
CONDUIT="\${SCRIPT_DIR}/dist/conduit"
CONFIG="\${SCRIPT_DIR}/psiphon_config.json"

if [ ! -f "\$CONDUIT" ]; then
    echo "Error: Conduit binary not found at \$CONDUIT"
    echo "Please run: make build"
    exit 1
fi

if [ ! -f "\$CONFIG" ]; then
    echo "Warning: psiphon_config.json not found"
    echo "Using embedded config if available"
    CONFIG_ARG=""
else
    CONFIG_ARG="--psiphon-config \$CONFIG"
fi

echo "Starting Conduit with optimal settings:"
echo "  Max Clients: $MAX_CLIENTS"
echo "  Bandwidth:   $BANDWIDTH Mbps"
echo "  Stats File:  Enabled (for dashboard)"
echo ""

osascript <<APPLESCRIPT
tell application "Terminal"
    activate
    do script "cd '\$SCRIPT_DIR' && \$CONDUIT start \$CONFIG_ARG --max-clients $MAX_CLIENTS --bandwidth $BANDWIDTH -v --stats-file"
end tell
APPLESCRIPT
EOF
    
    chmod +x "$LAUNCHER_FILE"
    echo ""
    echo "✓ Launcher script created: $LAUNCHER_FILE"
    echo ""
    echo "You can now:"
    echo "  1. Double-click 'Start Conduit (Optimal).command' to run with these settings"
    echo "  2. Or run manually:"
    echo "     ./dist/conduit start --psiphon-config ./psiphon_config.json \\"
    echo "       --max-clients $MAX_CLIENTS --bandwidth $BANDWIDTH -v"
else
    echo ""
    echo "To use these settings, run:"
    echo "  ./dist/conduit start --psiphon-config ./psiphon_config.json \\"
    echo "    --max-clients $MAX_CLIENTS --bandwidth $BANDWIDTH -v --stats-file"
    echo ""
    echo "Then run the dashboard in another terminal:"
    echo "  ./scripts/dashboard.sh"
fi

echo ""
