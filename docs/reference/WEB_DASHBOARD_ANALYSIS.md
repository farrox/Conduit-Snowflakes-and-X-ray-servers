# Web Dashboard Analysis & Integration Plan

Analysis of the web dashboard from `/Users/ed/Developer/conduit-relay` and plan to integrate it into our project.

## 📊 Dashboard Overview

### Architecture
- **Backend**: Node.js/Express (ES modules)
- **Frontend**: Vanilla JavaScript + Chart.js
- **Database**: SQLite (sql.js)
- **Authentication**: Session-based password auth
- **Remote Management**: SSH2 library for server control

### Key Features

1. **Multi-Server Fleet Management**
   - Monitor multiple Conduit nodes from one dashboard
   - SSH-based remote control
   - Auto-registration via join token

2. **Real-Time Monitoring**
   - Live stats (clients, traffic, uptime)
   - Historical charts (24h traffic/clients)
   - Geographic distribution (geo stats)

3. **Server Control**
   - Start/Stop/Restart individual nodes
   - Bulk control (all servers)
   - Edit server settings (name, bandwidth limits)

4. **Bandwidth Management**
   - Monthly bandwidth tracking
   - Auto-stop at limits
   - Depletion estimates

5. **Update System**
   - Check for updates
   - Update all servers from dashboard
   - Self-update dashboard

6. **Setup Wizard**
   - First-run guidance
   - Join command display
   - Settings management

## 🔍 Technical Details

### Backend (server.js)

**Dependencies:**
```json
{
  "dotenv": "^17.2.3",
  "express": "^5.2.1",
  "express-session": "^1.19.0",
  "sql.js": "^1.13.0",
  "ssh2": "^1.17.0"
}
```

**Key Components:**

1. **SSH Connection Pooling**
   - Reuses SSH connections
   - Keepalive for reliability
   - Automatic cleanup

2. **Stats Collection**
   - Parses systemd status
   - Parses journalctl logs
   - Extracts stats from `[STATS]` log lines
   - Cumulative tracking with offset system

3. **Database Schema**
   - `stats` table: Historical stats per server
   - `offsets` table: Cumulative offsets (handles service restarts)
   - `geo_stats` table: Geographic distribution

4. **API Endpoints**
   - `/api/stats` - Current stats for all servers
   - `/api/history` - Historical data
   - `/api/geo` - Geographic stats
   - `/api/bandwidth` - Monthly bandwidth usage
   - `/api/control/:action` - Control all servers
   - `/api/control/:server/:action` - Control specific server
   - `/api/servers` - CRUD operations for servers
   - `/api/version` - Version checking
   - `/api/update` - Update servers
   - `/api/update-dashboard` - Self-update
   - `/join/:token` - Auto-registration endpoint

5. **Join Token System**
   - Generates bash script for auto-registration
   - Sets up SSH keys automatically
   - Configures sudoers
   - Registers server via API

### Frontend (index.html)

**Features:**
- Dark theme UI
- Real-time updates (10s intervals)
- Chart.js for visualizations
- Graceful DOM updates (only changes)
- Responsive design

**Charts:**
- Traffic chart (24h, line chart)
- Clients chart (24h, line chart)
- Geo chart (bar chart, top 15 countries)

**Components:**
- Summary bar (total nodes, clients, upload, download)
- Node cards (per-server stats)
- Bandwidth section (collapsible)
- Update banners
- Setup wizard modal
- Settings modal

### Configuration

**Environment Variables (.env):**
```
PORT=3000
DASHBOARD_PASSWORD=changeme
SESSION_SECRET=random-secret-here
SSH_KEY_PATH=~/.ssh/id_ed25519
JOIN_TOKEN=optional-hex-token
```

**Servers Config (servers.json):**
```json
[
  {
    "name": "server1",
    "host": "1.2.3.4",
    "user": "conduitmon",
    "bandwidthLimit": 10995116277760
  }
]
```

## 🎯 Integration Plan

### Phase 1: Basic Dashboard (Single Node)

**Goal**: Get web dashboard working for single local node

**Tasks:**
1. Copy dashboard directory structure
2. Adapt server.js for single-node mode
3. Remove SSH dependency (use local stats)
4. Use our stats.json file instead of SSH parsing
5. Simplify to local monitoring only
6. Test with our CLI version

**Changes Needed:**
- Remove SSH2 dependency
- Read from `data/stats.json` instead of SSH
- Parse our stats format
- Single server mode (no fleet management)
- Local process monitoring

### Phase 2: Multi-Node Support

**Goal**: Add fleet management capabilities

**Tasks:**
1. Add SSH support back
2. Implement server management
3. Add join token system
4. Test with multiple servers

### Phase 3: Enhanced Features

**Goal**: Add advanced features

**Tasks:**
1. Geo stats integration
2. Bandwidth limits
3. Update system
4. Advanced charts

## 📝 Implementation Steps

### Step 1: Create Dashboard Directory

```bash
mkdir -p dashboard/public
mkdir -p dashboard/data
```

### Step 2: Copy and Adapt Files

1. Copy `server.js` → adapt for our use case
2. Copy `index.html` → adapt styling/branding
3. Copy `login.html` → keep as-is
4. Copy `package.json` → update dependencies

### Step 3: Adapt Backend

**Key Changes:**
- Remove SSH for single-node mode
- Read from `data/stats.json`
- Use our stats format
- Local process monitoring
- Keep SQLite for history

### Step 4: Adapt Frontend

**Key Changes:**
- Update branding
- Simplify for single node
- Keep charts
- Remove fleet-specific UI (temporarily)

### Step 5: Integration with Our Project

**Options:**
1. **Standalone**: Separate dashboard service
2. **Integrated**: Part of main project
3. **Optional**: Can be installed separately

**Recommendation**: Make it optional but easy to install

## 🔧 Technical Adaptations Needed

### Stats Format

**Their format (from journalctl):**
```
[STATS] Connecting: 5 | Connected: 15 | Up: 1.2MB | Down: 3.4MB | Uptime: 5:23
```

**Our format (from stats.json):**
```json
{
  "connectedClients": 15,
  "totalBytesUp": 1258291,
  "totalBytesDown": 3565158,
  "startTime": "2026-01-25T20:00:00Z"
}
```

**Adaptation:**
- Parse our JSON format
- Calculate uptime from startTime
- Format bytes for display

### Process Monitoring

**Their method:**
- SSH to remote server
- Run `systemctl status conduit`
- Parse output

**Our method (single-node):**
- Read local `data/stats.json`
- Check process with `ps`
- Parse our stats format

### Service Control

**Their method:**
- SSH + `systemctl {action} conduit`

**Our method (single-node):**
- Direct process control
- Or systemd if available
- Or signal-based control

## 🚀 Quick Start Integration

### Minimal Version (Single Node)

1. **Copy dashboard files**
2. **Create simplified server.js**:
   - Remove SSH
   - Read from `data/stats.json`
   - Local process monitoring
   - Keep SQLite for history

3. **Update package.json**:
   - Remove `ssh2` dependency
   - Keep others

4. **Create installation script**:
   - Install Node.js if needed
   - Install npm dependencies
   - Create systemd service
   - Generate .env file

5. **Integration with our scripts**:
   - Add `--stats-file` automatically
   - Start dashboard alongside Conduit
   - Or separate service

## 📦 File Structure

```
Conduit-Snowflakes-and-X-ray-servers/
├── dashboard/
│   ├── server.js          # Backend (adapted)
│   ├── package.json       # Dependencies
│   ├── .env.example       # Config template
│   ├── public/
│   │   ├── index.html     # Main dashboard
│   │   └── login.html     # Login page
│   ├── data/
│   │   └── stats.db       # SQLite database
│   └── servers.json       # Server config (optional)
├── scripts/
│   ├── install-dashboard.sh  # Dashboard installer
│   └── start-with-dashboard.sh  # Start both
└── ...
```

## 🎨 UI Customization

**Current Theme:**
- Dark background (#0a0a0a)
- Green accent (#22c55e)
- Modern, minimal design

**Our Branding:**
- Keep dark theme
- Adjust colors to match our style
- Update logo/branding
- Keep professional look

## 🔐 Security Considerations

1. **Password**: Strong default, user must change
2. **Session**: Secure session management
3. **SSH Keys**: Proper key management
4. **HTTPS**: SSL support (Let's Encrypt)
5. **Access Control**: IP restrictions (optional)

## 📊 Comparison: CLI vs Web Dashboard

| Feature | CLI Dashboard | Web Dashboard |
|---------|---------------|---------------|
| **Access** | Local terminal | Browser (remote) |
| **Multi-Node** | ❌ Single node | ✅ Fleet management |
| **Charts** | ❌ Text only | ✅ Visual charts |
| **History** | ❌ Current only | ✅ 24h+ history |
| **Geo Stats** | ❌ No | ✅ Yes |
| **Control** | ❌ Manual | ✅ Web UI |
| **Updates** | ❌ Manual | ✅ Auto-update |
| **Setup** | ✅ Simple | ⚠️ Requires Node.js |

## 🎯 Recommended Approach

### Option 1: Standalone Dashboard (Recommended)

**Pros:**
- Separate from main project
- Optional installation
- Can be updated independently
- Works with any Conduit setup

**Cons:**
- Requires Node.js
- Additional service to manage

### Option 2: Integrated Dashboard

**Pros:**
- Single installation
- Always available
- Better integration

**Cons:**
- Adds Node.js dependency
- More complex build

### Option 3: Hybrid

**Pros:**
- CLI dashboard for quick checks
- Web dashboard for detailed monitoring
- Best of both worlds

**Cons:**
- Two systems to maintain

## 📋 Next Steps

1. ✅ **Analysis complete** - This document
2. ⏳ **Create minimal dashboard** - Single-node version
3. ⏳ **Test integration** - With our stats.json
4. ⏳ **Add installation script** - Easy setup
5. ⏳ **Documentation** - Usage guide
6. ⏳ **Multi-node support** - Fleet management
7. ⏳ **Advanced features** - Geo stats, updates

---

**Status**: Ready to implement Phase 1 (Basic Dashboard)
