# Quick Configuration Guide

## Easiest Way to Set Optimal Config

### For Maximum Users with Your Bandwidth

**Option 1: Interactive (Recommended)**
```bash
./scripts/configure-optimal.sh
```
This will:
- Test your bandwidth automatically (or ask you)
- Calculate optimal max-clients and bandwidth
- Create a launcher script you can double-click

**Option 2: Quick Start**
```bash
./scripts/quick-optimal.sh
```
Auto-detects bandwidth and starts with optimal settings.

**Option 3: Manual**
```bash
# For 50 Mbps connection, 200 max clients, 30 Mbps bandwidth
./dist/conduit start \
  --psiphon-config ./psiphon_config.json \
  --max-clients 200 \
  --bandwidth 30 \
  -v
```

## Quick Reference

| Your Bandwidth | Max Clients | Bandwidth Setting |
|----------------|-------------|-------------------|
| 10 Mbps        | 50          | 6 Mbps            |
| 25 Mbps        | 100         | 15 Mbps           |
| 50 Mbps        | 200         | 30 Mbps           |
| 100+ Mbps      | 1000        | 40 Mbps (max)     |

**Formula**: Use 60% of your bandwidth, aim for ~0.15 Mbps per client.

## After Configuration

Once you run `configure-optimal.sh`, you'll get:
- `Start Conduit (Optimal).command` - Double-click to run with optimal settings

For more details, see [CONFIG_OPTIMAL.md](CONFIG_OPTIMAL.md).
