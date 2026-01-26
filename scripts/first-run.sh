#!/bin/bash
# First-run setup script - checks config and guides user

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Conduit CLI - First Run Setup"
echo "=========================================="
echo ""

# Check for config
echo "Step 1: Checking for Psiphon configuration..."
echo ""

if [ -f "$PROJECT_ROOT/psiphon_config.json" ]; then
    # Validate it's not the example
    if grep -q "FFFFFFFFFFFFFFFF" "$PROJECT_ROOT/psiphon_config.json" 2>/dev/null; then
        echo "⚠️  Found example config file (will not work)"
        echo ""
        echo "You need a real config from Psiphon. Running config checker..."
        echo ""
        bash "$PROJECT_ROOT/scripts/check-config.sh"
        exit 1
    else
        echo "✅ Valid psiphon_config.json found"
    fi
else
    echo "❌ psiphon_config.json not found"
    echo ""
    echo "Running config checker to help you find it..."
    echo ""
    bash "$PROJECT_ROOT/scripts/check-config.sh"
    
    # Check again after running checker
    if [ ! -f "$PROJECT_ROOT/psiphon_config.json" ]; then
        echo ""
        echo "⚠️  Config file still not found. You'll need to get it from Psiphon."
        echo "   Email: info@psiphon.ca"
        exit 1
    fi
fi

echo ""
echo "Step 2: Checking binary..."
if [ ! -f "$PROJECT_ROOT/dist/conduit" ]; then
    echo "❌ Binary not found. Building..."
    echo ""
    cd "$PROJECT_ROOT"
    if [ ! -d "psiphon-tunnel-core" ]; then
        echo "Running initial setup..."
        make setup
    fi
    make build
    echo ""
fi

if [ -f "$PROJECT_ROOT/dist/conduit" ]; then
    echo "✅ Binary found"
else
    echo "❌ Build failed. Please run: make build"
    exit 1
fi

echo ""
echo "Step 3: Configuration..."
echo ""
echo "Would you like to configure optimal settings now?"
read -p "Run optimal configuration helper? (y/n): " run_config

if [ "$run_config" = "y" ] || [ "$run_config" = "Y" ]; then
    bash "$PROJECT_ROOT/scripts/configure-optimal.sh"
else
    echo ""
    echo "You can configure optimal settings later with:"
    echo "  ./scripts/configure-optimal.sh"
    echo ""
    echo "Or start with defaults:"
    echo "  ./dist/conduit start --psiphon-config ./psiphon_config.json"
fi

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "You're ready to run Conduit!"
echo ""
