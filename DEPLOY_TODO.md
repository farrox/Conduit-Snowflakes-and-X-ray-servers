# Cloud Deployment TODO Checklist

Quick reference checklist for deploying Conduit to cloud providers (DigitalOcean, Linode, Hetzner, AWS, GCP, Azure, etc.).

## Pre-Deployment

- [ ] Choose cloud provider (DigitalOcean/Linode/Hetzner recommended for simplicity)
- [ ] Choose server size (2GB RAM minimum, 4GB+ recommended)
- [ ] Choose server location (closer to target region = better performance)
- [ ] Get `psiphon_config.json` file ready
- [ ] Decide on installation method (Docker recommended)

## Server Setup

- [ ] Create server (Ubuntu 22.04 LTS recommended)
- [ ] Add SSH key to server
- [ ] SSH into server: `ssh root@your-server-ip`
- [ ] Update system: `apt update && apt upgrade -y`
- [ ] Install basic tools: `apt install -y curl wget git vim htop ufw`
- [ ] Create non-root user (optional): `adduser conduit-user && usermod -aG sudo conduit-user`

## Security Configuration

- [ ] Configure SSH security:
  - [ ] Disable root login: `PermitRootLogin no` in `/etc/ssh/sshd_config`
  - [ ] Disable password auth: `PasswordAuthentication no`
  - [ ] Restart SSH: `systemctl restart sshd`
- [ ] Install fail2ban: `apt install fail2ban && systemctl enable fail2ban`
- [ ] Set up automatic security updates: `apt install unattended-upgrades`

## Installation

### Docker Method (Recommended)

- [ ] Install Docker: `curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh`
- [ ] Clone repository: `git clone https://github.com/farrox/conduit_emergency.git`
- [ ] Upload config file: `scp psiphon_config.json user@server:/path/to/conduit_emergency/`
- [ ] Build Docker image: `docker build -t conduit --build-arg PSIPHON_CONFIG=psiphon_config.json -f Dockerfile.embedded .`
- [ ] Run container: `docker run -d --name conduit -v conduit-data:/home/conduit/data --restart unless-stopped conduit`
- [ ] Verify running: `docker ps | grep conduit`
- [ ] Check logs: `docker logs -f conduit`

### Native Binary Method

- [ ] Install Go 1.24.x: `wget https://go.dev/dl/go1.24.0.linux-amd64.tar.gz && sudo tar -C /usr/local -xzf go1.24.0.linux-amd64.tar.gz`
- [ ] Add Go to PATH: `export PATH=$PATH:/usr/local/go/bin && echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc`
- [ ] Clone repository: `git clone https://github.com/farrox/conduit_emergency.git`
- [ ] Setup: `make setup`
- [ ] Build: `make build`
- [ ] Upload config: `scp psiphon_config.json user@server:/path/to/conduit_emergency/`
- [ ] Create data directory: `mkdir -p data`
- [ ] Test run: `./dist/conduit start --psiphon-config ./psiphon_config.json -v`

## Systemd Service

- [ ] Create systemd service file: `/etc/systemd/system/conduit.service`
- [ ] Configure service (see DEPLOY_CLOUD.md for examples)
- [ ] Reload systemd: `systemctl daemon-reload`
- [ ] Enable service: `systemctl enable conduit`
- [ ] Start service: `systemctl start conduit`
- [ ] Check status: `systemctl status conduit`
- [ ] Test auto-restart: `systemctl restart conduit`

## Firewall Configuration

- [ ] **IMPORTANT:** Allow SSH first: `ufw allow 22/tcp`
- [ ] Allow Conduit traffic (all TCP/UDP - Conduit uses dynamic ports):
  - [ ] `ufw allow from any to any port 1:65535 proto tcp`
  - [ ] `ufw allow from any to any port 1:65535 proto udp`
- [ ] Enable firewall: `ufw enable`
- [ ] Verify: `ufw status verbose`
- [ ] **Note:** If using cloud provider firewall (DigitalOcean/Linode), configure there too

## Monitoring Setup

- [ ] Set up basic monitoring:
  - [ ] Docker: `docker stats conduit` (or native: `top -p $(pgrep conduit)`)
  - [ ] Logs: `docker logs -f conduit` (or `journalctl -u conduit -f`)
- [ ] Enable stats file (native only): Add `--stats-file` flag
- [ ] Set up log rotation: Configure `logrotate` or `journald`
- [ ] Optional: Set up external monitoring (Prometheus/Grafana)

## Backup Configuration

- [ ] **CRITICAL:** Set up backup for `data/` directory (contains node identity key)
- [ ] Create backup script (see DEPLOY_CLOUD.md)
- [ ] Test backup: Verify backup file is created
- [ ] Set up cron job: `crontab -e` → Add daily backup
- [ ] Test restore: Verify you can restore from backup
- [ ] Document backup location and restore procedure

## Optimization

- [ ] Test bandwidth: `speedtest-cli` or `curl -o /dev/null http://speedtest.tele2.net/10MB.zip`
- [ ] Calculate optimal settings: Use `configure-optimal.sh` or manual calculation
- [ ] Update Conduit command with optimal `--max-clients` and `--bandwidth`
- [ ] Restart service with new settings: `systemctl restart conduit`

## Verification

- [ ] Conduit is running: `docker ps` or `systemctl status conduit`
- [ ] Logs show connection: Look for `[OK] Connected to Psiphon network`
- [ ] No errors in logs: Check for error messages
- [ ] Firewall allows traffic: Test from external connection
- [ ] Service auto-starts: Reboot server and verify Conduit starts automatically
- [ ] Resource usage is acceptable: Monitor CPU/RAM for 24 hours

## Post-Deployment

- [ ] Wait 24-48 hours for node reputation to build
- [ ] Monitor connections: Check logs for client connections
- [ ] Monitor resource usage: Ensure CPU/RAM are within limits
- [ ] Set up alerts: Configure monitoring alerts (if using external monitoring)
- [ ] Document configuration: Save server details, IP, credentials (securely)
- [ ] Test backup restore: Periodically test that backups work

## Maintenance

- [ ] Weekly: Check logs for errors
- [ ] Weekly: Verify service is running
- [ ] Weekly: Check resource usage
- [ ] Monthly: Update system packages: `apt update && apt upgrade`
- [ ] Monthly: Test backup restore
- [ ] As needed: Update Conduit (rebuild Docker image or recompile)

## Troubleshooting Quick Reference

### Conduit Not Starting
```bash
# Check logs
docker logs conduit  # Docker
journalctl -u conduit -n 50  # Native

# Check config
cat psiphon_config.json | python3 -m json.tool

# Check permissions
ls -la data/
```

### No Connections After 48 Hours
- Check firewall: `ufw status`
- Check logs: Look for connection errors
- Verify config file is valid
- Check network connectivity: `ping 8.8.8.8`

### High Resource Usage
```bash
# Reduce limits
--max-clients 200  # Lower from 500
--bandwidth 5      # Lower from 10
```

### Service Won't Start
```bash
# Check systemd logs
journalctl -u conduit -n 100

# Check permissions
ls -la /opt/conduit/data

# Test manual start
./dist/conduit start --psiphon-config ./psiphon_config.json -v
```

## Quick Commands Reference

```bash
# Docker
docker ps | grep conduit                    # Check if running
docker logs -f conduit                      # View logs
docker restart conduit                       # Restart
docker stats conduit                         # Resource usage

# Native Binary
systemctl status conduit                     # Check status
systemctl restart conduit                    # Restart
journalctl -u conduit -f                     # View logs
ps aux | grep conduit                        # Check process

# Firewall
ufw status verbose                           # Check firewall
ufw allow 22/tcp                             # Allow SSH
ufw enable                                   # Enable firewall

# Monitoring
docker stats conduit                         # Docker stats
top -p $(pgrep conduit)                      # Native stats
df -h                                        # Disk space
free -h                                      # Memory
```

## Provider-Specific Quick Start

### DigitalOcean
1. Create Droplet → Ubuntu 22.04 → 2GB+ RAM
2. Add SSH key
3. Follow Docker installation steps above
4. Configure DigitalOcean Cloud Firewall (web UI)

### Linode
1. Create Linode → Ubuntu 22.04 → Nanode 1GB+
2. Add SSH key
3. Follow Docker installation steps above
4. Configure Linode Cloud Firewall (web UI)

### Hetzner
1. Create Server → Ubuntu 22.04 → CX11+
2. Choose location (Nuremberg/Falkenstein)
3. Add SSH key
4. Follow Docker installation steps above
5. Configure Hetzner Cloud Firewall (web UI)

### AWS
1. Launch EC2 → Ubuntu 22.04 → t3.small+
2. Configure security group (allow all TCP/UDP)
3. Add SSH key
4. Follow Docker installation steps above

### Google Cloud
1. Create VM → Ubuntu 22.04 → e2-small+
2. Configure firewall rules (allow all TCP/UDP)
3. Add SSH key
4. Follow Docker installation steps above

### Azure
1. Create VM → Ubuntu 22.04 → Standard_B1s+
2. Configure NSG (allow all TCP/UDP)
3. Add SSH key
4. Follow Docker installation steps above

---

**Full Documentation:** See [docs/markdown/DEPLOY_CLOUD.md](docs/markdown/DEPLOY_CLOUD.md) for detailed instructions.

**Need Help?** Check the troubleshooting section or open an issue on GitHub.
