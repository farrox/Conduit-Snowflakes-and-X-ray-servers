# Installing Conduit on macOS (Intel)

This guide makes it as easy as possible to run Conduit on your Intel-based Mac.

## Option 1: Download DMG (Easiest - Recommended)

If a DMG file is available for download:

1. **Download the DMG** from the website or GitHub releases
2. **Double-click the DMG** to mount it
3. **Drag "Conduit" to your Applications folder**
4. **Double-click "Start Conduit.command"** — starts Conduit and opens a **live dashboard** (same style as the Docker manager: CPU, RAM, connected users, traffic, auto-refresh)

That's it! The binary includes everything needed.

### Running from Applications

After installing, you can run Conduit from Terminal:

```bash
/Applications/Conduit start
```

Or with verbose output:

```bash
/Applications/Conduit start -v
```

## Option 2: Clone Repository (For Developers)

If you've cloned the repository:

### Quick Setup (Automated)

1. **Open Terminal** and navigate to the project:
   ```bash
   cd /path/to/conduit_emergency
   ```

2. **Run the easy setup script**:
   ```bash
   chmod +x scripts/easy-setup.sh
   ./scripts/easy-setup.sh
   ```

This script will:
- Install Homebrew (if needed)
- Install Go 1.24 (if needed)
- Set up all dependencies
- Build the binary
- Create a launcher script

3. **Double-click "Start Conduit.command"** in the project folder

### Manual Setup

If you prefer to do it manually:

1. **Install Homebrew** (if not installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Go 1.24**:
   ```bash
   brew install go@1.24
   export PATH="/usr/local/opt/go@1.24/bin:$PATH"
   echo 'export PATH="/usr/local/opt/go@1.24/bin:$PATH"' >> ~/.zprofile
   ```

3. **Set up and build**:
   ```bash
   cd /path/to/conduit_emergency
   make setup
   make build
   ```

4. **Run**:
   ```bash
   ./dist/conduit start --psiphon-config ./psiphon_config.json
   ```

## Getting Your Psiphon Config

**Important:** You need a valid Psiphon configuration file to run Conduit.

1. Contact **info@psiphon.ca** to request a configuration file
2. Save it as `psiphon_config.json` in your project folder (or Applications folder if using DMG)

The example config (`psiphon_config.example.json`) will NOT work - it's just a template.

## Building a DMG (For Distribution)

If you want to create a DMG for distribution:

1. **Get a valid psiphon_config.json** file
2. **Run the DMG creation script**:
   ```bash
   chmod +x scripts/create-dmg.sh
   ./scripts/create-dmg.sh /path/to/psiphon_config.json
   ```

The DMG will be created in `dist/` with:
- The Conduit binary (with embedded config)
- A launcher script
- README instructions
- Applications folder link

## Troubleshooting

### "Permission denied"
```bash
chmod +x /Applications/Conduit
```

### "Command not found: make"
Install Xcode Command Line Tools:
```bash
xcode-select --install
```

### "Go not found" or "Wrong Go version"
```bash
brew install go@1.24
export PATH="/usr/local/opt/go@1.24/bin:$PATH"
```

### "Binary not found"
Make sure you've built it:
```bash
cd /path/to/conduit_emergency
make build
```

### DMG won't open
Right-click the DMG → Open → Open (to bypass Gatekeeper)

## Next Steps

- See [README.md](README.md) for usage options
- See [docs/](docs/) for HTML documentation
- Run with `-v` flag to see verbose output: `./dist/conduit start -v`
