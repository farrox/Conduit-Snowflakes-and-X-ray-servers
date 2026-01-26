# Live Dashboard for CLI Version

The CLI version now includes a live dashboard similar to the Docker version, showing real-time monitoring of your Conduit node.

## Quick Start

### Option 1: Start with Dashboard (Easiest)

```bash
./scripts/start-with-dashboard.sh
```

This will:
1. Start Conduit with stats enabled
2. Open the dashboard in a new terminal window

### Option 2: Manual Start

1. **Start Conduit with stats enabled:**
   ```bash
   ./dist/conduit start \
     --psiphon-config ./psiphon_config.json \
     --max-clients 50 \
     --bandwidth 5 \
     -v \
     --stats-file
   ```

2. **In another terminal, run the dashboard:**
   ```bash
   ./scripts/dashboard.sh
   ```

## Dashboard Features

The dashboard displays:

- **Status**: Online/Offline indicator
- **PID**: Process ID
- **Uptime**: How long Conduit has been running
- **CPU**: CPU usage percentage
- **RAM**: Memory usage
- **Iranians**: Number of connected Iranians
- **Up**: Upload traffic (bytes sent)
- **Down**: Download traffic (bytes received)

The dashboard auto-refreshes every 5 seconds.

## Enabling Stats

For the dashboard to show accurate statistics, start Conduit with the `--stats-file` flag:

```bash
./dist/conduit start \
  --psiphon-config ./psiphon_config.json \
  -v \
  --stats-file
```

This creates a `stats.json` file in the data directory that the dashboard reads.

## Using Optimal Configuration

The optimal configuration script now automatically enables stats:

```bash
./scripts/configure-optimal.sh
```

This creates a launcher that includes `--stats-file`, so the dashboard will work automatically.

## Dashboard vs Docker Version

| Feature | CLI Dashboard | Docker Dashboard |
|---------|---------------|------------------|
| **CPU/RAM** | ✅ Process monitoring | ✅ Container stats |
| **Connected Iranians** | ✅ From stats file | ✅ From logs |
| **Traffic** | ✅ From stats file | ✅ From logs |
| **Auto-refresh** | ✅ Every 5 seconds | ✅ Every 10 seconds |
| **UI** | ✅ Terminal-based | ✅ Terminal-based |

Both provide the same information, just using different methods to gather it.

## Troubleshooting

### "Stats file not found"
- Make sure you started Conduit with `--stats-file` flag
- Wait a few seconds after starting - stats file is created when first stats are recorded
- Check: `ls -la data/stats.json`

### "Conduit is not running"
- Start Conduit first in another terminal
- Or use `./scripts/start-with-dashboard.sh` to start both

### Stats showing 0
- Stats are only updated when there's activity
- Wait for Iranians to connect
- Check that Conduit is connected: Look for "[OK] Connected to Psiphon network" in logs

## Keyboard Shortcuts

- **Ctrl+C**: Exit dashboard
- Dashboard will continue refreshing until you press Ctrl+C

## Example Output

```
  ██████╗ ██████╗ ███╗   ██╗██████╗ ██╗   ██╗██╗████████╗
 ██╔════╝██╔═══██╗████╗  ██║██╔══██╗██║   ██║██║╚══██╔══╝
 ██║     ██║   ██║██╔██╗ ██║██║  ██║██║   ██║██║   ██║   
 ██║     ██║   ██║██║╚██╗██║██║  ██║██║   ██║██║   ██║   
 ╚██████╗╚██████╔╝██║ ╚████║██████╔╝╚██████╔╝██║   ██║   
  ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝  ╚═════╝ ╚═╝   ╚═╝   
              CLI Live Dashboard                  

LIVE DASHBOARD (Press Ctrl+C to Exit)
══════════════════════════════════════════════════════
 STATUS:      ● ONLINE
 PID:         12345
 UPTIME:      5:23
──────────────────────────────────────────────────────
 RESOURCES    | TRAFFIC
──────────────────────────────────────────────────────
 CPU: 2.5%    | Iranians: 15
 RAM: 12.3M    | Up:   1.2MB
              | Down: 3.4MB
══════════════════════════════════════════════════════
📊 Stats: /path/to/data/stats.json
Refreshing every 5 seconds...
```

---

**Enjoy monitoring your Conduit node in real-time!** 🎉
