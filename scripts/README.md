# Scripts Directory

This directory contains helper scripts to make Conduit easier to use and distribute.

## Docker-Based Manager

### `conduit-manager-mac.sh`
**Professional Docker-based management tool for macOS** with beautiful UI and live dashboard.

- **Source:** Based on [conduit-manager-mac](https://github.com/polamgh/conduit-manager-mac) by [polamgh](https://github.com/polamgh)
- **Features:** Live dashboard, smart start/stop, easy reconfiguration
- **Requirements:** Docker Desktop for macOS
- **Usage:** `./scripts/conduit-manager-mac.sh`

See [docs/markdown/CONDUIT_MANAGER_MAC.md](../docs/markdown/CONDUIT_MANAGER_MAC.md) for full documentation.

## For End Users

### `easy-setup.sh`
Automated setup script for users who clone the repository. This script:
- Installs Homebrew (if needed)
- Installs Go 1.24 (if needed)
- Sets up all dependencies
- Builds the binary
- Creates a launcher script

**Usage:**
```bash
chmod +x scripts/easy-setup.sh
./scripts/easy-setup.sh
```

## For Developers/Distributors

### `create-dmg.sh`
Creates a macOS DMG installer with embedded configuration. The DMG includes:
- The Conduit binary (with embedded psiphon config)
- A launcher script ("Start Conduit.command")
- README instructions
- Applications folder link

**Usage:**
```bash
chmod +x scripts/create-dmg.sh
./scripts/create-dmg.sh /path/to/psiphon_config.json
```

The DMG will be created in `dist/` directory.

**Requirements:**
- macOS (for DMG creation)
- Go 1.24.x installed
- Valid psiphon_config.json file
- `make setup` must have been run at least once

## Making Scripts Executable

All scripts should be executable. If they're not, run:
```bash
chmod +x scripts/*.sh
```
