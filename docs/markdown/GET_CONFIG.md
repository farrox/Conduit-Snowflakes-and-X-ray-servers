# Getting Your Psiphon Config - No Email Required!

## Why the GUI Works Without Email

The **iOS GUI app** has the `psiphon_config.json` **embedded in the app bundle** when it's built. That's why you can run it without emailing Psiphon - the config is already included!

## How to Get Config for CLI (3 Easy Ways)

### Option 1: Extract from iOS App (Easiest - No Email!)

If you have the iOS Conduit app installed (even in simulator), you can extract the config:

```bash
# Automatic extraction
./scripts/extract-ios-config.sh

# Or search for it
./scripts/find-psiphon-config.sh
```

This will find and copy the config from:
- iOS Simulator apps (`~/Library/Developer/CoreSimulator/Devices`)
- Xcode DerivedData
- iOS app bundles

### Option 2: Use Embedded Config in Build

Build the CLI with the config embedded (just like the iOS app):

```bash
# First, get the config (Option 1 above, or from Psiphon)
# Then build with embedded config
make build-embedded PSIPHON_CONFIG=./psiphon_config.json
```

Now the binary includes the config - no file needed at runtime!

### Option 3: Email Psiphon (Only if Options 1 & 2 Don't Work)

If you don't have the iOS app and need a fresh config:
- Email: **info@psiphon.ca**
- Subject: Request for Conduit CLI Configuration

## Quick Start (Recommended)

1. **Extract from iOS app** (if you have it):
   ```bash
   ./scripts/extract-ios-config.sh
   ```

2. **Or build with embedded config**:
   ```bash
   # Get config first (extract or email)
   make build-embedded PSIPHON_CONFIG=./psiphon_config.json
   ```

3. **Run without needing the file**:
   ```bash
   ./dist/conduit start  # Config is embedded!
   ```

## Why This Works

The iOS app developers embed the config at **build time**, so users never need to manage it. You can do the same for the CLI by:

1. Extracting the config from the iOS app (if available)
2. Building with `make build-embedded`
3. Distributing the binary with config already included

This makes the CLI as easy to use as the GUI!

## Creating a DMG with Embedded Config

For distribution, create a DMG with embedded config:

```bash
# Get config first
./scripts/extract-ios-config.sh  # or get from Psiphon

# Create DMG with embedded config
./scripts/create-dmg.sh ./psiphon_config.json
```

The DMG will include a binary that works without any config file - just like the iOS app!
