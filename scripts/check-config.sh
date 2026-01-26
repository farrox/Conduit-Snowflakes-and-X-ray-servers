#!/bin/bash
# Check for psiphon_config.json and help users get it if missing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CONFIG_FILE="$PROJECT_ROOT/psiphon_config.json"

echo "=========================================="
echo "Psiphon Config Checker"
echo "=========================================="
echo ""

# Check if config exists in project
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ Found psiphon_config.json in project directory"
    echo "   Location: $CONFIG_FILE"
    echo ""
    
    # Validate it's not the example
    if grep -q "FFFFFFFFFFFFFFFF" "$CONFIG_FILE" 2>/dev/null; then
        echo "⚠️  WARNING: This appears to be the example config file!"
        echo "   The example config will NOT work - you need a real config from Psiphon."
        echo ""
        echo "   Contact: info@psiphon.ca to get a valid config file."
        exit 1
    fi
    
    echo "✓ Config file looks valid"
    exit 0
fi

echo "❌ psiphon_config.json not found in project directory"
echo ""

# Search for existing configs
echo "🔍 Searching for existing config files..."
echo ""

FOUND_ANY=0

# Check common locations
LOCATIONS=(
    "$HOME/Downloads/*psiphon*config*"
    "$HOME/Desktop/*psiphon*config*"
    "$HOME/Documents/*psiphon*config*"
    "$HOME/*psiphon*config*"
)

for pattern in "${LOCATIONS[@]}"; do
    for file in $pattern 2>/dev/null; do
        if [ -f "$file" ] && [ "$file" != "$CONFIG_FILE" ]; then
            echo "   ✅ Found: $file"
            FOUND_ANY=1
            
            # Check if it's the example
            if ! grep -q "FFFFFFFFFFFFFFFF" "$file" 2>/dev/null; then
                echo ""
                echo "💡 This looks like a valid config! Copy it?"
                read -p "   Copy to project? (y/n): " copy_it
                if [ "$copy_it" = "y" ] || [ "$copy_it" = "Y" ]; then
                    cp "$file" "$CONFIG_FILE"
                    echo "   ✓ Copied to $CONFIG_FILE"
                    exit 0
                fi
            fi
        fi
    done
done

# Check iOS app locations (if scripts exist)
if [ -f "$PROJECT_ROOT/find-psiphon-config.sh" ]; then
    echo ""
    echo "🔍 Checking iOS app locations..."
    IOS_CONFIG=$(bash "$PROJECT_ROOT/find-psiphon-config.sh" 2>/dev/null | grep "Found:" | head -1 | sed 's/.*Found: //')
    if [ -n "$IOS_CONFIG" ] && [ -f "$IOS_CONFIG" ]; then
        echo "   ✅ Found in iOS app: $IOS_CONFIG"
        FOUND_ANY=1
        echo ""
        echo "💡 Copy from iOS app?"
        read -p "   Copy to project? (y/n): " copy_it
        if [ "$copy_it" = "y" ] || [ "$copy_it" = "Y" ]; then
            cp "$IOS_CONFIG" "$CONFIG_FILE"
            echo "   ✓ Copied to $CONFIG_FILE"
            exit 0
        fi
    fi
fi

if [ "$FOUND_ANY" -eq 0 ]; then
    echo "   No config files found in common locations"
fi

echo ""
echo "=========================================="
echo "How to Get Your Config File"
echo "=========================================="
echo ""
echo "The psiphon_config.json file contains encrypted broker configuration"
echo "that connects you to the Psiphon network. It must be obtained from Psiphon."
echo ""
echo "Options:"
echo ""
echo "1. 📧 Email Psiphon (Recommended)"
echo "   Send an email to: info@psiphon.ca"
echo "   Subject: Request for Conduit CLI Configuration"
echo "   They will provide you with a psiphon_config.json file"
echo ""
echo "2. 🔍 Check Your Email/Backups"
echo "   If you've worked with Psiphon before, check:"
echo "   - Email attachments from Psiphon"
echo "   - Previous project directories"
echo "   - Cloud storage (Dropbox, iCloud, etc.)"
echo ""
echo "3. 📱 Extract from iOS App (If Available)"
echo "   If you have the iOS Conduit app, run:"
echo "   ./find-psiphon-config.sh"
echo ""
echo "Once you have the file, place it here:"
echo "   $CONFIG_FILE"
echo ""
echo "Then run this script again to verify it's valid."
echo ""
