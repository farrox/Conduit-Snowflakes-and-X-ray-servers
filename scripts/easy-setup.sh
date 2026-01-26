#!/bin/bash
# Easy setup script for users who clone the repository
# This automates the entire setup process for Intel Mac users

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "Conduit CLI - Easy Setup for macOS"
echo "=========================================="
echo ""

cd "$PROJECT_ROOT"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "Error: This script is for macOS only"
    exit 1
fi

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Intel Macs
    if [[ $(uname -m) == "x86_64" ]]; then
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Check and install Go 1.24
echo ""
echo "Checking Go installation..."
if ! command -v go &> /dev/null; then
    echo "Go not found. Installing Go 1.24..."
    brew install go@1.24
    
    # Add Go to PATH
    if [[ $(uname -m) == "x86_64" ]]; then
        export PATH="/usr/local/opt/go@1.24/bin:$PATH"
        echo 'export PATH="/usr/local/opt/go@1.24/bin:$PATH"' >> ~/.zprofile
    else
        export PATH="/opt/homebrew/opt/go@1.24/bin:$PATH"
        echo 'export PATH="/opt/homebrew/opt/go@1.24/bin:$PATH"' >> ~/.zprofile
    fi
else
    GO_VERSION=$(go version | grep -oE 'go[0-9]+\.[0-9]+' | sed 's/go//')
    GO_MAJOR=$(echo $GO_VERSION | cut -d. -f1)
    GO_MINOR=$(echo $GO_VERSION | cut -d. -f2)
    
    if [ "$GO_MAJOR" -gt 1 ] || ([ "$GO_MAJOR" -eq 1 ] && [ "$GO_MINOR" -ge 25 ]); then
        echo "Warning: Go $GO_VERSION detected, but Go 1.24.x is required"
        echo "Installing Go 1.24..."
        brew install go@1.24
        
        if [[ $(uname -m) == "x86_64" ]]; then
            export PATH="/usr/local/opt/go@1.24/bin:$PATH"
            echo 'export PATH="/usr/local/opt/go@1.24/bin:$PATH"' >> ~/.zprofile
        else
            export PATH="/opt/homebrew/opt/go@1.24/bin:$PATH"
            echo 'export PATH="/opt/homebrew/opt/go@1.24/bin:$PATH"' >> ~/.zprofile
        fi
    else
        echo "✓ Go $GO_VERSION is installed"
    fi
fi

# Check for Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    echo ""
    echo "Xcode Command Line Tools not found. Installing..."
    xcode-select --install
    echo "Please complete the Xcode installation, then run this script again."
    exit 1
fi

# Run setup
echo ""
echo "Setting up Conduit dependencies..."
make setup

# Check for psiphon config
echo ""
if [ ! -f "$PROJECT_ROOT/psiphon_config.json" ]; then
    echo "⚠️  Psiphon config not found!"
    echo ""
    echo "Checking for existing config files..."
    if [ -f "$PROJECT_ROOT/scripts/check-config.sh" ]; then
        bash "$PROJECT_ROOT/scripts/check-config.sh"
    fi
    
    if [ ! -f "$PROJECT_ROOT/psiphon_config.json" ]; then
        echo ""
        echo "You need a valid psiphon_config.json file to run Conduit."
        echo "Contact Psiphon (info@psiphon.ca) to obtain one."
        echo ""
        echo "For now, I'll build without embedded config."
        echo "You can build with embedded config later using:"
        echo "  make build-embedded PSIPHON_CONFIG=/path/to/psiphon_config.json"
        echo ""
        BUILD_TARGET="build"
    else
        echo "✓ Found psiphon_config.json (after search)"
        echo "Building with embedded config..."
        BUILD_TARGET="build-embedded"
    fi
else
    # Validate it's not the example
    if grep -q "FFFFFFFFFFFFFFFF" "$PROJECT_ROOT/psiphon_config.json" 2>/dev/null; then
        echo "⚠️  Found example config (will not work)"
        echo "You need a real config from Psiphon. Building without embedded config for now."
        BUILD_TARGET="build"
    else
        echo "✓ Found psiphon_config.json"
        echo "Building with embedded config..."
        BUILD_TARGET="build-embedded"
    fi
fi

# Build
echo ""
echo "Building Conduit..."
make $BUILD_TARGET PSIPHON_CONFIG="$PROJECT_ROOT/psiphon_config.json" 2>/dev/null || make build

# Create launcher
echo ""
echo "Creating launcher script..."
cat > "$PROJECT_ROOT/Start Conduit.command" << 'LAUNCHER'
#!/bin/bash
# Launcher for Conduit

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONDUIT="$SCRIPT_DIR/dist/conduit"

if [ ! -f "$CONDUIT" ]; then
    echo "Error: Conduit binary not found at $CONDUIT"
    echo "Please run: make build"
    exit 1
fi

# Check for config
if [ -f "$SCRIPT_DIR/psiphon_config.json" ]; then
    CONFIG_ARG="--psiphon-config $SCRIPT_DIR/psiphon_config.json"
else
    CONFIG_ARG=""
    echo "Warning: psiphon_config.json not found. Using embedded config if available."
fi

# Open Terminal and run
osascript <<APPLESCRIPT
tell application "Terminal"
    activate
    do script "cd '$SCRIPT_DIR' && $CONDUIT start $CONFIG_ARG -v"
end tell
APPLESCRIPT
LAUNCHER

chmod +x "$PROJECT_ROOT/Start Conduit.command"

echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo "To run Conduit:"
echo "  1. Double-click 'Start Conduit.command' in this folder"
echo "  OR"
echo "  2. Open Terminal and run:"
echo "     ./dist/conduit start --psiphon-config ./psiphon_config.json"
echo ""
echo "If you have a psiphon_config.json file, place it in:"
echo "  $PROJECT_ROOT/psiphon_config.json"
echo ""
