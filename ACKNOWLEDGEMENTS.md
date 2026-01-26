# Acknowledgements

This project incorporates and references several excellent community contributions. We are grateful to all the developers who have made tools and resources available to help people access the open internet.

## Community Projects & Tools

### Conduit Manager for macOS (Docker)

**Project:** [conduit-manager-mac](https://github.com/polamgh/conduit-manager-mac)  
**Author:** [polamgh](https://github.com/polamgh)  
**License:** See original repository

A professional, lightweight Docker-based management tool for deploying Psiphon Conduit nodes on macOS. Features include:
- Beautiful macOS-optimized UI
- Live dashboard with real-time monitoring
- Smart start/stop/restart logic
- Easy reconfiguration

The script (`scripts/conduit-manager-mac.sh`) is included in this project with proper attribution. All credit for the Docker-based management interface goes to the original author.

**Original Repository:** https://github.com/polamgh/conduit-manager-mac

### Iran Conduit Firewall

**Project:** [iran-conduit-firewall](https://github.com/SamNet-dev/iran-conduit-firewall)  
**Author:** [SamNet-dev](https://github.com/SamNet-dev)  
**Contributors:** [moridani](https://github.com/moridani) and community

A comprehensive Windows firewall solution for restricting Conduit traffic to specific regions (Iran). Features include:
- Explicit blocking rules (not relying on defaults)
- Full IPv6 support
- Normal and Strict filtering modes
- Auto-elevation and smart detection
- Diagnostic logging

This project is referenced in our [Security & Firewall documentation](docs/markdown/SECURITY_FIREWALL.md) as the recommended solution for Windows users.

**Original Repository:** https://github.com/SamNet-dev/iran-conduit-firewall

### Conduit Manager (Linux)

**Project:** [conduit-manager](https://github.com/SamNet-dev/conduit-manager)  
**Author:** [SamNet-dev](https://github.com/SamNet-dev)  
**License:** MIT License

A powerful, one-click management tool for Psiphon Conduit nodes on Linux. Features include:
- Multi-distro support (Ubuntu, Debian, CentOS, Fedora, Arch, Alpine, openSUSE)
- Auto-start on boot (systemd, OpenRC, SysVinit)
- Live monitoring with CPU/RAM stats
- Interactive management menu
- Live peer connections by country (map view)

This project inspired our Linux installation script and dashboard features. The live peer mapping feature is particularly useful for visualizing geographic distribution of connections.

**Original Repository:** https://github.com/SamNet-dev/conduit-manager

### Conduit Relay (Web Dashboard)

**Project:** [conduit-relay](https://github.com/paradixe/conduit-relay)  
**Author:** [paradixe](https://github.com/paradixe)  
**Contributors:** [arpieb](https://github.com/arpieb), [alexraskin](https://github.com/alexraskin)

A comprehensive web-based dashboard for managing multiple Conduit nodes. Features include:
- Web-based dashboard (Node.js/Express)
- Fleet management (multiple servers)
- Real-time monitoring with charts
- Geographic stats visualization
- Auto-registration via join tokens
- Update system

This project's web dashboard architecture and features inspired our web dashboard integration plans. The join token system and fleet management capabilities are excellent examples of production-ready features.

**Original Repository:** https://github.com/paradixe/conduit-relay

## Core Dependencies

### Psiphon Tunnel Core

**Project:** [psiphon-tunnel-core](https://github.com/Psiphon-Labs/psiphon-tunnel-core)  
**Organization:** [Psiphon Inc.](https://www.psiphon.ca/)

The core networking library that powers Conduit. This project uses the `staging-client` branch which includes inproxy support.

**Repository:** https://github.com/Psiphon-Labs/psiphon-tunnel-core

## How to Contribute

If you've created a tool, script, or resource that helps with Conduit deployment, we'd love to:
1. Link to it in our documentation
2. Include it (with attribution) if it fits our project
3. Reference it as a recommended solution

Please open an issue or pull request with:
- Link to your project
- Brief description
- How it helps Conduit users

## License Compatibility

All integrated projects maintain their original licenses. This project (conduit_emergency) is licensed under GNU General Public License v3.0. Please refer to individual project repositories for their specific license terms.

---

**Thank you to all contributors who help make internet freedom accessible to everyone!**
