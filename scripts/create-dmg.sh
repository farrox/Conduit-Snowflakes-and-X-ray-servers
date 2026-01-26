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
https://github.com/farrox/conduit_emergency

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

# Create launcher script
cat > "$DMG_DIR/Start Conduit.command" << 'EOF'
#!/bin/bash
# Launcher script for Conduit

APP_PATH="/Applications/Conduit"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If running from DMG, use DMG version, otherwise use installed version
if [ -f "$SCRIPT_DIR/Conduit" ]; then
    CONDUIT="$SCRIPT_DIR/Conduit"
elif [ -f "$APP_PATH" ]; then
    CONDUIT="$APP_PATH"
else
    echo "Error: Conduit binary not found"
    echo "Please drag Conduit to Applications folder first"
    exit 1
fi

# Open Terminal and run
osascript <<APPLESCRIPT
tell application "Terminal"
    activate
    do script "$CONDUIT start -v"
end tell
APPLESCRIPT
EOF

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
