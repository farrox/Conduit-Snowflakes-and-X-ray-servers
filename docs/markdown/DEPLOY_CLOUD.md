# Deploying Conduit to Cloud Providers

This guide covers deploying Conduit to cloud providers like DigitalOcean, Linode, Hetzner, AWS, Google Cloud, Azure, and others.

## Table of Contents

- [Quick Start](#quick-start)
- [Provider Selection](#provider-selection)
- [Server Setup](#server-setup)
- [Installation Methods](#installation-methods)
- [Systemd Service](#systemd-service)
- [Firewall Configuration](#firewall-configuration)
- [Monitoring](#monitoring)
- [Security Best Practices](#security-best-practices)
- [Provider-Specific Notes](#provider-specific-notes)
- [Troubleshooting](#troubleshooting)

## Quick Start

**Fastest deployment (One-Command Install - Recommended):**
```bash
# 1. Create Ubuntu 22.04 server
# 2. SSH into server
ssh root@your-server-ip

# 3. One command installs everything
curl -sL https://raw.githubusercontent.com/farrox/conduit_emergency/main/scripts/install-linux.sh | sudo bash

# 4. Add your config file
# Upload psiphon_config.json to /opt/conduit/
scp psiphon_config.json root@your-server-ip:/opt/conduit/

# 5. Start the service
sudo systemctl start conduit

# 6. Check status
sudo systemctl status conduit
sudo journalctl -u conduit -f
```

**Alternative: Docker deployment:**
```bash
# 1. Create Ubuntu 22.04 server
# 2. SSH into server
ssh root@your-server-ip

# 3. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# 4. Clone repository
git clone https://github.com/farrox/conduit_emergency.git
cd conduit_emergency

# 5. Build with embedded config
docker build -t conduit \
  --build-arg PSIPHON_CONFIG=psiphon_config.json \
  -f Dockerfile.embedded .

# 6. Run with persistent volume
docker run -d --name conduit \
  -v conduit-data:/home/conduit/data \
  --restart unless-stopped \
  conduit

# 7. Check logs
docker logs -f conduit
```

## Provider Selection

### Recommended Providers

| Provider | Pros | Cons | Best For |
|----------|------|------|----------|
| **DigitalOcean** | Simple, good docs, predictable pricing | Slightly more expensive | Beginners, small-medium nodes |
| **Linode** | Good performance, competitive pricing | Less features than AWS/GCP | Cost-conscious users |
| **Hetzner** | Very cheap, good performance | Limited locations (EU-focused) | Budget deployments |
| **AWS** | Global, scalable, many features | Complex, can be expensive | Enterprise, large scale |
| **Google Cloud** | Good free tier, global | Complex pricing | Developers with credits |
| **Azure** | Enterprise features | Complex, Windows-focused | Enterprise users |

### Server Specifications

**Minimum (for testing):**
- 1 CPU core
- 1 GB RAM
- 10 GB storage
- 1 TB bandwidth/month

**Recommended (production):**
- 2-4 CPU cores
- 4-8 GB RAM
- 20-40 GB storage
- 5+ TB bandwidth/month
- 100+ Mbps network

**High-capacity:**
- 4+ CPU cores
- 8+ GB RAM
- 40+ GB storage
- 10+ TB bandwidth/month
- 1 Gbps network

## Server Setup

### 1. Create Server

Choose Ubuntu 22.04 LTS (recommended) or Debian 12.

**DigitalOcean:**
1. Create Droplet → Ubuntu 22.04
2. Choose size (2GB RAM minimum)
3. Add SSH key
4. Create

**Linode:**
1. Create Linode → Ubuntu 22.04
2. Choose plan (Nanode 1GB minimum)
3. Add SSH key
4. Deploy

**Hetzner:**
1. Create Server → Ubuntu 22.04
2. Choose location (Nuremberg/Falkenstein)
3. Choose size (CX11 minimum)
4. Add SSH key
5. Create

### 2. Initial Server Configuration

```bash
# SSH into server
ssh root@your-server-ip

# Update system
apt update && apt upgrade -y

# Install basic tools
apt install -y curl wget git vim htop ufw

# Create non-root user (optional but recommended)
adduser conduit-user
usermod -aG sudo conduit-user
su - conduit-user
```

### 3. Configure SSH (Security)

```bash
# Edit SSH config
sudo vim /etc/ssh/sshd_config

# Set:
# PermitRootLogin no
# PasswordAuthentication no
# PubkeyAuthentication yes

# Restart SSH
sudo systemctl restart sshd
```

## Installation Methods

### Method 1: Docker (Recommended)

**Advantages:**
- ✅ No Go installation needed
- ✅ Easy updates
- ✅ Isolated environment
- ✅ Works on any Linux distro

**Installation:**

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Add user to docker group (if not root)
sudo usermod -aG docker $USER
newgrp docker

# Clone repository
git clone https://github.com/farrox/conduit_emergency.git
cd conduit_emergency

# Upload your psiphon_config.json
# (use scp from your local machine)
# scp psiphon_config.json user@server:/path/to/conduit_emergency/

# Build with embedded config
docker build -t conduit \
  --build-arg PSIPHON_CONFIG=psiphon_config.json \
  -f Dockerfile.embedded .

# Run with persistent volume
docker run -d --name conduit \
  -v conduit-data:/home/conduit/data \
  --restart unless-stopped \
  conduit start \
  --data-dir /home/conduit/data \
  --max-clients 500 \
  --bandwidth 10

# Check status
docker ps
docker logs -f conduit
```

### Method 2: Native Binary (One-Command Install - Recommended)

**Advantages:**
- ✅ Lower resource usage
- ✅ No Docker overhead
- ✅ Direct process control
- ✅ Automatic systemd service
- ✅ One command installs everything

**Installation (Easiest):**

```bash
# One command installs: Go, builds from source, creates systemd service
curl -sL https://raw.githubusercontent.com/farrox/conduit_emergency/main/scripts/install-linux.sh | sudo bash

# With custom settings
curl -sL https://raw.githubusercontent.com/farrox/conduit_emergency/main/scripts/install-linux.sh | MAX_CLIENTS=500 BANDWIDTH=10 sudo bash

# Add config file
scp psiphon_config.json root@server:/opt/conduit/

# Start service
sudo systemctl start conduit
sudo systemctl status conduit
```

**Manual Installation (if you prefer):**

```bash
# Install Go 1.24.x
wget https://go.dev/dl/go1.24.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.24.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc

# Clone repository
git clone https://github.com/farrox/conduit_emergency.git
cd conduit_emergency

# Setup dependencies
make setup

# Build
make build

# Upload config
# scp psiphon_config.json user@server:/path/to/conduit_emergency/

# Create data directory
mkdir -p data

# Run
./dist/conduit start \
  --psiphon-config ./psiphon_config.json \
  --max-clients 500 \
  --bandwidth 10 \
  --data-dir ./data \
  -v
```

## Systemd Service

Create a systemd service for automatic startup and management.

### For Docker

Create `/etc/systemd/system/conduit.service`:

```ini
[Unit]
Description=Conduit Psiphon Inproxy Node
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start conduit
ExecStop=/usr/bin/docker stop conduit
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

### For Native Binary

Create `/etc/systemd/system/conduit.service`:

```ini
[Unit]
Description=Conduit Psiphon Inproxy Node
After=network.target

[Service]
Type=simple
User=conduit-user
WorkingDirectory=/opt/conduit
ExecStart=/opt/conduit/dist/conduit start \
  --psiphon-config /opt/conduit/psiphon_config.json \
  --max-clients 500 \
  --bandwidth 10 \
  --data-dir /opt/conduit/data \
  -v
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**Enable and start:**

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable service
sudo systemctl enable conduit

# Start service
sudo systemctl start conduit

# Check status
sudo systemctl status conduit

# View logs
sudo journalctl -u conduit -f
```

## Firewall Configuration

### UFW (Ubuntu Firewall)

```bash
# Allow SSH (important - do this first!)
sudo ufw allow 22/tcp

# Allow Conduit traffic (all TCP/UDP)
# Conduit uses dynamic ports, so we allow all
sudo ufw allow from any to any port 1:65535 proto tcp
sudo ufw allow from any to any port 1:65535 proto udp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose
```

### Firewalld (CentOS/RHEL)

```bash
# Allow SSH
sudo firewall-cmd --permanent --add-service=ssh

# Allow all ports (Conduit uses dynamic ports)
sudo firewall-cmd --permanent --add-port=1-65535/tcp
sudo firewall-cmd --permanent --add-port=1-65535/udp

# Reload
sudo firewall-cmd --reload
```

### iptables (Advanced)

```bash
# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow all TCP/UDP (Conduit uses dynamic ports)
iptables -A INPUT -p tcp -j ACCEPT
iptables -A INPUT -p udp -j ACCEPT

# Save rules
iptables-save > /etc/iptables/rules.v4
```

**Note:** Conduit uses dynamic ports assigned by the Psiphon broker. You cannot restrict to specific ports.

## Monitoring

### Basic Monitoring

```bash
# Check if running (Docker)
docker ps | grep conduit
docker stats conduit

# Check if running (Native)
ps aux | grep conduit
top -p $(pgrep conduit)

# Check logs
docker logs -f conduit  # Docker
sudo journalctl -u conduit -f  # Native
```

### Dashboard (CLI Version)

If using native binary, you can use the dashboard script:

```bash
# SSH into server with X11 forwarding (or use tmux/screen)
ssh -X user@server

# Run dashboard
cd /opt/conduit
./scripts/dashboard.sh
```

### Stats File

Enable stats when starting:

```bash
# Add --stats-file flag
./dist/conduit start \
  --psiphon-config ./psiphon_config.json \
  --stats-file \
  ...

# View stats
cat data/stats.json | python3 -m json.tool
```

### External Monitoring

**Prometheus + Grafana:**
- Export stats via HTTP endpoint (custom implementation needed)
- Monitor CPU, RAM, network, connected clients

**Simple Health Check:**
```bash
#!/bin/bash
# health-check.sh
if docker ps | grep -q conduit; then
    echo "OK"
    exit 0
else
    echo "FAIL"
    exit 1
fi
```

## Security Best Practices

### 1. Use Non-Root User

```bash
# Create dedicated user
sudo adduser --system --group conduit-user
sudo mkdir -p /opt/conduit
sudo chown conduit-user:conduit-user /opt/conduit
```

### 2. Secure SSH

- Disable root login
- Use SSH keys only
- Change default SSH port (optional)
- Use fail2ban

```bash
# Install fail2ban
sudo apt install fail2ban

# Configure
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 3. Keep System Updated

```bash
# Set up automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 4. Backup Data Directory

**Critical:** The `data/` directory contains your node's identity key. Losing it means starting with zero reputation.

```bash
# Backup script
#!/bin/bash
# backup-conduit.sh
BACKUP_DIR="/backup/conduit"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/conduit-data-$DATE.tar.gz /opt/conduit/data

# Keep only last 7 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
```

**Add to crontab:**
```bash
# Daily backup at 2 AM
0 2 * * * /path/to/backup-conduit.sh
```

### 5. Limit Resource Usage

```bash
# For systemd service, add resource limits
[Service]
...
MemoryLimit=2G
CPUQuota=200%
```

## Provider-Specific Notes

### DigitalOcean

**Firewall:**
- Use DigitalOcean Cloud Firewall (web UI)
- Allow all TCP/UDP ports
- Or use UFW on the server

**Monitoring:**
- Built-in monitoring in dashboard
- Set up alerts for CPU/RAM

**Backups:**
- Enable automatic snapshots
- Or use droplet backups

### Linode

**Firewall:**
- Use Linode Cloud Firewall (web UI)
- Or use UFW on the server

**Monitoring:**
- Linode Longview (free tier available)
- Or use built-in monitoring

**Backups:**
- Enable Linode Backups
- Or use snapshots

### Hetzner

**Firewall:**
- Use Hetzner Cloud Firewall (web UI)
- Or use UFW on the server

**Locations:**
- Nuremberg (Germany)
- Falkenstein (Germany)
- Helsinki (Finland)
- Ashburn (USA)

**Note:** Hetzner is EU-focused. Good for EU-based nodes.

### AWS

**Security Groups:**
- Create security group
- Allow all TCP/UDP (0.0.0.0/0)
- Attach to EC2 instance

**IAM:**
- Create IAM user with minimal permissions
- Use for programmatic access

**CloudWatch:**
- Monitor CPU, RAM, network
- Set up alarms

### Google Cloud

**Firewall Rules:**
- Create firewall rule
- Allow all TCP/UDP
- Apply to instance

**Cloud Monitoring:**
- Built-in monitoring
- Set up alerts

### Azure

**Network Security Groups:**
- Create NSG
- Allow all TCP/UDP
- Attach to NIC

**Azure Monitor:**
- Built-in monitoring
- Set up alerts

## Troubleshooting

### Conduit Not Starting

```bash
# Check logs
docker logs conduit  # Docker
sudo journalctl -u conduit -n 50  # Native

# Check config file
cat psiphon_config.json | python3 -m json.tool

# Check permissions
ls -la data/
```

### No Connections

- **Wait 24-48 hours:** New nodes need time to build reputation
- **Check firewall:** Ensure ports are open
- **Check logs:** Look for connection errors
- **Verify config:** Ensure config file is valid

### High CPU/RAM Usage

```bash
# Check resource usage
docker stats conduit  # Docker
top -p $(pgrep conduit)  # Native

# Reduce max-clients
--max-clients 200  # Lower from 500

# Reduce bandwidth
--bandwidth 5  # Lower from 10
```

### Connection Drops

- **Check network:** `ping 8.8.8.8`
- **Check DNS:** `nslookup psiphon.ca`
- **Check logs:** Look for errors
- **Restart service:** `sudo systemctl restart conduit`

### Disk Space

```bash
# Check disk usage
df -h

# Clean Docker (if using Docker)
docker system prune -a

# Clean logs
sudo journalctl --vacuum-time=7d
```

## Next Steps

1. ✅ Server created and configured
2. ✅ Conduit installed and running
3. ✅ Systemd service enabled
4. ✅ Firewall configured
5. ✅ Monitoring set up
6. ✅ Backups configured
7. ⏳ Wait 24-48 hours for reputation
8. ⏳ Monitor connections and traffic

## Additional Resources

- [Security & Firewall Guide](SECURITY_FIREWALL.md)
- [Optimal Configuration](CONFIG_OPTIMAL.md)
- [Dashboard Guide](DASHBOARD.md)
- [Main README](../README.md)

---

**Need help?** Check the troubleshooting section or open an issue on GitHub.
