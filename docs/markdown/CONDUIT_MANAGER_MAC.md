# Conduit Manager for macOS (Docker)

A **professional, lightweight, and intelligent** management tool for deploying **Psiphon Conduit** nodes on **macOS** using **Docker**.  
Built to help people access the **open internet reliably**, with **zero configuration hassle**.

## 📝 Credits & Source

This tool is based on the excellent work by [polamgh](https://github.com/polamgh) in the [conduit-manager-mac](https://github.com/polamgh/conduit-manager-mac) project.

**Original Repository:** https://github.com/polamgh/conduit-manager-mac

The script has been integrated into this project with proper attribution. All credit for the Docker-based management interface goes to the original author.

## 🔧 Prerequisites

Before installation, make sure **Docker Desktop for macOS** is installed and running.

- Download Docker Desktop from the official website:  
  https://www.docker.com/products/docker-desktop/
- After installation, **open Docker Desktop** and ensure it is running.

> ⚠️ This tool deploys Psiphon Conduit **inside a Docker container**, so Docker Desktop is required.

## 📦 Quick Install

The script is included in this project. Simply run:

```bash
# Make it executable (if not already)
chmod +x scripts/conduit-manager-mac.sh

# Run it
./scripts/conduit-manager-mac.sh
```

Or download directly from the original source:

```bash
# 1. Download the script
curl -L -o conduit-mac.sh https://raw.githubusercontent.com/polamgh/conduit-manager-mac/main/conduit-mac.sh

# 2. Make it executable
chmod +x conduit-mac.sh

# 3. Run it
./conduit-mac.sh
```

## ✨ Features

- 🍏 **macOS-Optimized UI**  
  Clean, dashboard-style interface designed specifically for the macOS Terminal.

- 🧠 **Smart Logic**  
  Automatically detects whether the service should be installed, started, or restarted.

- 📊 **Live Dashboard**  
  Real-time monitoring of **CPU**, **RAM**, **connected users**, and **traffic usage**.

- 🛡️ **Safety Checks**  
  Verifies **Docker Desktop** status before execution to prevent runtime errors.

- ⚙️ **Easy Reconfiguration**  
  Instantly change **Max Clients** or **Bandwidth limits** via the interactive menu.

- 🚀 **Zero Extra Dependencies**  
  Works out-of-the-box using standard macOS tools and Docker Desktop.

## 📋 Menu Options

| Option                  | Function                                                                 |
| ----------------------- | ------------------------------------------------------------------------ |
| **1. Start / Restart**  | Smart install (if new), start (if stopped), or restart (if running).     |
| **2. Stop Service**     | Safely stops the Conduit container.                                      |
| **3. Live Dashboard**   | Displays real-time resource usage and traffic statistics (auto-refresh). |
| **4. View Raw Logs**    | Streams raw Docker logs for debugging and inspection.                    |
| **5. Reconfigure**      | Reinstalls the container to update client or bandwidth settings.         |

## ⚙️ Configuration Guide

| Setting         | Default | Description                         |
| --------------- | ------- | ----------------------------------- |
| **Max Clients** | 200     | Maximum number of concurrent users. |
| **Bandwidth**   | 5 Mbps  | Speed limit per user connection.    |

## 💻 Hardware Recommendations (Mac)

- **Apple Silicon (M1 / M2 / M3)**  
  Easily handles **400–800+ clients** with excellent efficiency.

- **Intel-based Macs**  
  Recommended to limit between **200–400 clients** to manage heat and performance.

## Comparison with Native CLI

This Docker-based manager provides:
- ✅ **Easier setup** - No need to install Go or build from source
- ✅ **Live dashboard** - Real-time monitoring interface
- ✅ **Automatic updates** - Uses pre-built Docker images
- ✅ **Isolated environment** - Runs in container, doesn't affect system

The native CLI (this project) provides:
- ✅ **More control** - Direct access to all features
- ✅ **Custom builds** - Embed config, optimize for your system
- ✅ **No Docker required** - Runs natively
- ✅ **DMG distribution** - Easy installation for end users

**Choose Docker Manager if:** You want the easiest setup with a nice UI  
**Choose Native CLI if:** You want full control and custom builds

## Links

- **Original Project:** https://github.com/polamgh/conduit-manager-mac
- **Docker Image:** Uses `ghcr.io/ssmirr/conduit/conduit` (as configured in script)
- **This Project:** See [README.md](../../README.md) for native CLI installation

---

**Note:** This Docker-based manager is maintained separately. For issues specific to the Docker manager, please refer to the [original repository](https://github.com/polamgh/conduit-manager-mac).
