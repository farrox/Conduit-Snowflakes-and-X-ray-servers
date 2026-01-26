# Optimal Configuration Guide

This guide helps you configure Conduit with optimal settings for maximum users and your available bandwidth.

## Quick Start

### Option 1: Interactive Configuration (Easiest)

Run the interactive configuration helper:

```bash
./scripts/configure-optimal.sh
```

This script will:
1. Test your bandwidth (or ask you to enter it)
2. Calculate optimal max-clients and bandwidth settings
3. Create a launcher script with your optimal settings

### Option 2: Quick Start with Auto-Detection

For a quick start with automatic bandwidth detection:

```bash
./scripts/quick-optimal.sh
```

Or specify your bandwidth:

```bash
./scripts/quick-optimal.sh 50    # 50 Mbps bandwidth
./scripts/quick-optimal.sh 100 500  # 100 Mbps, 500 max clients
```

### Option 3: Manual Configuration

Run Conduit with your chosen settings:

```bash
./dist/conduit start \
  --psiphon-config ./psiphon_config.json \
  --max-clients 1000 \
  --bandwidth 20 \
  -v
```

## Understanding the Settings

### Max Clients (1-1000)
- **Maximum**: 1000 (hard limit)
- **Recommended**: Based on your bandwidth
- **Calculation**: Aim for ~0.15 Mbps per client
  - Example: 30 Mbps bandwidth → ~200 max clients

### Bandwidth (1-40 Mbps, or -1 for unlimited)
- **Maximum**: 40 Mbps per peer (documented limit)
- **Recommended**: 50-70% of your available bandwidth
  - Leaves 30-50% for your own use
  - Ensures stable performance
- **Example**: 100 Mbps connection → Use 50-60 Mbps

## Configuration Examples

### High-Bandwidth Connection (100+ Mbps)
```bash
./dist/conduit start \
  --psiphon-config ./psiphon_config.json \
  --max-clients 1000 \
  --bandwidth 40 \
  -v
```

### Medium Connection (30-50 Mbps)
```bash
./dist/conduit start \
  --psiphon-config ./psiphon_config.json \
  --max-clients 200 \
  --bandwidth 20 \
  -v
```

### Low-Bandwidth Connection (10-20 Mbps)
```bash
./dist/conduit start \
  --psiphon-config ./psiphon_config.json \
  --max-clients 50 \
  --bandwidth 6 \
  -v
```

## Optimal Settings Formula

The configuration scripts use this formula:

1. **Bandwidth**: Use 60% of your available bandwidth
   - Leaves 40% for your own use
   - Capped at 40 Mbps maximum

2. **Max Clients**: Calculate based on bandwidth
   - Target: ~0.15 Mbps per client
   - Formula: `max_clients = (bandwidth * 0.6) / 0.15`
   - Capped at 1000 maximum
   - Minimum 10 clients

### Example Calculation

For a 50 Mbps connection:
- **Bandwidth**: 50 × 0.6 = 30 Mbps (capped at 40, so 30 Mbps)
- **Max Clients**: 30 / 0.15 = 200 clients

## Testing Your Bandwidth

### Using Ookla Speedtest (Recommended)

```bash
# Install speedtest (if not installed)
brew install speedtest-cli

# Test bandwidth
speedtest --accept-license --format=json --progress=no
```

The configuration scripts will automatically use this if available.

### Manual Testing

Use online speed test tools and enter the result when prompted.

## Creating a Persistent Launcher

After running `configure-optimal.sh`, you'll get a launcher script:
- **File**: `Start Conduit (Optimal).command`
- **Usage**: Double-click to run with optimal settings
- **Location**: Project root directory

## Advanced: Building with Embedded Config

For distribution, you can build with optimal settings embedded:

```bash
# First, create a wrapper script or modify the binary
# Then build with embedded config
make build-embedded PSIPHON_CONFIG=./psiphon_config.json
```

Note: The max-clients and bandwidth are CLI flags, not config file settings. They must be passed at runtime.

## Troubleshooting

### "Bandwidth too low"
- Minimum bandwidth: 1 Mbps
- If you have less, consider upgrading your connection

### "Max clients too high"
- Maximum: 1000
- If you need more, you'll need to run multiple instances

### Performance Issues
- Reduce max-clients if experiencing slowdowns
- Reduce bandwidth allocation if your own usage is affected
- Monitor with `-v` or `-vv` flags for detailed logs

## Best Practices

1. **Start Conservative**: Begin with 50% of bandwidth, increase if stable
2. **Monitor Performance**: Use verbose logging (`-v`) to monitor
3. **Leave Headroom**: Always reserve 30-40% bandwidth for your own use
4. **Test Regularly**: Re-test bandwidth periodically as it may change
5. **Adjust Based on Usage**: If you notice slowdowns, reduce the allocation

## Quick Reference

| Your Bandwidth | Recommended Settings |
|----------------|---------------------|
| 10 Mbps        | 50 clients, 6 Mbps  |
| 25 Mbps        | 100 clients, 15 Mbps |
| 50 Mbps        | 200 clients, 30 Mbps |
| 100+ Mbps      | 1000 clients, 40 Mbps (max) |
