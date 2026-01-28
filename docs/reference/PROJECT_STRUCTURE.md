# Project Structure

## Root Directory

```
Conduit-Snowflakes-and-X-ray-servers/
├── README.md                    # Main project documentation
├── Makefile                     # Build system
├── go.mod, go.sum               # Go dependencies
├── main.go                      # Application entry point
├── psiphon_config.example.json  # Example config template
│
├── cmd/                         # CLI commands
│   ├── root.go
│   └── start.go
│
├── internal/                    # Internal packages
│   ├── conduit/                 # Core service logic
│   ├── config/                  # Configuration management
│   └── crypto/                  # Cryptographic operations
│
├── docs/                        # Documentation
│   ├── *.html                   # HTML documentation pages
│   ├── styles.css               # HTML stylesheet
│   └── markdown/                # Markdown documentation
│       ├── README.md            # Documentation index
│       ├── QUICKSTART_MAC.md    # Quick start for Mac users
│       ├── CONFIG_OPTIMAL.md    # Optimal configuration guide
│       ├── GET_CONFIG.md        # Config file guide
│       ├── SECURITY_FIREWALL.md  # Firewall configuration
│       └── ...                  # Other documentation
│
├── scripts/                     # Helper scripts
│   ├── README.md                # Scripts documentation
│   ├── easy-setup.sh            # Automated setup
│   ├── configure-optimal.sh      # Optimal config helper
│   ├── create-dmg.sh            # DMG creation
│   ├── extract-ios-config.sh   # Extract config from iOS
│   ├── find-psiphon-config.sh   # Find config files
│   ├── start_optimized.sh       # Start with optimal settings
│   └── ...                      # Other utility scripts
│
├── Dockerfile                   # Docker build (runtime config)
├── Dockerfile.embedded          # Docker build (embedded config)
├── .dockerignore                # Docker ignore rules
└── .gitignore                   # Git ignore rules
```

## Key Directories

### `/docs/`
- **HTML files**: Web documentation (`index.html`, `quickstart.html`, etc.)
- **markdown/**: All markdown documentation files

### `/scripts/`
- All executable helper scripts
- Setup, configuration, and utility scripts

### `/cmd/`
- CLI command implementations
- Entry points for different commands

### `/internal/`
- Private application code
- Not meant for external use

## Build Outputs

- `/dist/` - Compiled binaries (gitignored)
- `/data/` - Runtime data and keys (gitignored)
- `psiphon-tunnel-core/` - Dependency clone (gitignored)

## Documentation Organization

### Quick Start
- `docs/markdown/QUICKSTART_MAC.md` - For non-technical Mac users
- `docs/markdown/QUICK_START.md` - General quick start
- `docs/markdown/QUICK_CONFIG.md` - Quick config reference

### Installation
- `docs/markdown/INSTALL_MAC.md` - macOS installation
- `docs/markdown/INSTALL-GO.md` - Go installation
- `docs/markdown/SETUP-GUIDE.md` - Detailed setup

### Configuration
- `docs/markdown/GET_CONFIG.md` - Getting config file
- `docs/markdown/CONFIG_OPTIMAL.md` - Optimal settings
- `docs/markdown/OPTIMIZED_SETTINGS.md` - Settings reference

### Security
- `docs/markdown/SECURITY_FIREWALL.md` - Firewall configuration

### Developer
- `docs/markdown/LLM_DEV_GUIDE.md` - Development guide
- `docs/markdown/README_EMERGENCY.md` - Emergency deployment

## Scripts Organization

### Setup & Installation
- `easy-setup.sh` - Automated setup for Mac
- `first-run.sh` - First-run wizard
- `check-config.sh` - Config file checker

### Configuration
- `configure-optimal.sh` - Interactive optimal config
- `quick-optimal.sh` - Quick optimal start
- `start_optimized.sh` - Start with optimal settings

### Distribution
- `create-dmg.sh` - Create macOS DMG installer

### Utilities
- `extract-ios-config.sh` - Extract config from iOS app
- `find-psiphon-config.sh` - Find config files
- `test_bandwidth.sh` - Test bandwidth

### Testing
- `TEST_EMERGENCY_SETUP.sh` - Setup tests
- `TEST_RUN_CLI.sh` - CLI tests
