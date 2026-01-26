# Scripts Directory

This directory contains helper scripts to make Conduit easier to use and distribute.

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
