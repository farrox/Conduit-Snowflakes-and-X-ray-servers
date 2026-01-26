# Map Feature Analysis - SamNet-dev/conduit-manager

Analysis of the live peer mapping feature from [SamNet-dev/conduit-manager](https://github.com/SamNet-dev/conduit-manager) and how to integrate it into our dashboard.

## 📍 Map Feature Overview

The `show_peers` function in conduit-manager displays **live peer connections by country** using:
- `tcpdump` - Captures network traffic
- `geoiplookup` - Maps IP addresses to countries
- Real-time updates every 14 seconds
- Visual display with country codes and counts

## 🔍 How It Works

### Technical Implementation

```bash
# 1. Capture network traffic for 14 seconds
timeout 14 tcpdump -ni any '(tcp or udp)' 2>/dev/null

# 2. Extract IP addresses (filter out local IPs)
grep ' IP ' | sed -nE 's/.* IP ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(\.[0-9]+)?[ >].*/\1/p' | \
grep -vE "^($local_ip|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.|0\.|169\.254\.)"

# 3. Look up countries for each unique IP
sort -u | xargs -n1 geoiplookup 2>/dev/null

# 4. Parse and format results
awk -F: '/Country Edition/{print $2}' | \
sed 's/Iran, Islamic Republic of/Iran - #FreeIran/' | \
sort | uniq -c | sort -nr | head -20
```

### Key Features

1. **Real-time Capture**: 14-second sampling window
2. **IP Filtering**: Excludes local/private IPs
3. **Country Lookup**: Uses GeoIP database
4. **Visual Display**: Shows count and country name
5. **Special Handling**: Highlights Iran with special formatting
6. **Top 20**: Shows top 20 countries by connection count

## 🎯 Integration Options

### Option 1: CLI Dashboard Enhancement

**Add to `scripts/dashboard.sh`:**

```bash
# New function: show_geo_stats
show_geo_stats() {
    # Check dependencies
    if ! command -v tcpdump &>/dev/null || ! command -v geoiplookup &>/dev/null; then
        echo "⚠️  tcpdump or geoiplookup not found"
        echo "Install: sudo apt install tcpdump geoip-bin"
        return 1
    fi

    # Capture and display
    local iface="any"
    local local_ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')
    
    echo "🌍 Capturing peer connections (14s)..."
    timeout 14 tcpdump -ni $iface '(tcp or udp)' 2>/dev/null | \
        grep ' IP ' | \
        sed -nE 's/.* IP ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(\.[0-9]+)?[ >].*/\1/p' | \
        grep -vE "^($local_ip|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.|0\.|169\.254\.)" | \
        sort -u | \
        xargs -n1 geoiplookup 2>/dev/null | \
        awk -F: '/Country Edition/{print $2}' | \
        sed 's/Iran, Islamic Republic of/Iran/' | \
        sort | uniq -c | sort -rn | head -20
}
```

**Add menu option:**
- Option 3: View peer locations (geo stats)

### Option 2: Web Dashboard Integration

**Add to web dashboard (when implemented):**

1. **New API Endpoint**: `/api/geo-live`
   - Runs tcpdump capture
   - Returns JSON with country counts

2. **New UI Component**: 
   - Map view or country list
   - Real-time updates
   - Visual representation

3. **Chart Integration**:
   - Add to existing geo chart
   - Show live data alongside historical

### Option 3: Standalone Script

**Create `scripts/geo-peers.sh`:**

```bash
#!/bin/bash
# Live peer connections by country
# Usage: ./scripts/geo-peers.sh [duration_seconds]

DURATION=${1:-14}

# Check dependencies
if ! command -v tcpdump &>/dev/null; then
    echo "Error: tcpdump not found"
    exit 1
fi

if ! command -v geoiplookup &>/dev/null; then
    echo "Installing geoip-bin..."
    sudo apt install -y geoip-bin || exit 1
fi

# Capture and display
echo "🌍 Capturing peer connections for ${DURATION}s..."
# ... (implementation)
```

## 📋 Requirements

### Dependencies

1. **tcpdump** - Network packet capture
   ```bash
   sudo apt install tcpdump
   # Requires sudo/root access
   ```

2. **geoip-bin** - IP geolocation
   ```bash
   sudo apt install geoip-bin
   ```

3. **Permissions**:
   - Root/sudo access for tcpdump
   - Network interface access

### Platform Support

- ✅ Linux (all distributions)
- ⚠️ macOS (tcpdump available, may need different interface)
- ❌ Windows (would need WSL or different approach)

## 🎨 UI/UX Considerations

### CLI Display

**Current format (from conduit-manager):**
```
 Peers | Country
 ──────|──────────────────────────────────────
   176 | IR, Iran - #FreeIran
    45 | US, United States
    23 | DE, Germany
```

**Enhanced format (for our dashboard):**
```
══════════════════════════════════════════════════════
 LIVE PEER CONNECTIONS BY COUNTRY
══════════════════════════════════════════════════════
 Last Update: 20:15:30 [LIVE]

 Peers | Country
 ──────|──────────────────────────────────────
   176 | IR, Iran - #FreeIran
    45 | US, United States
    23 | DE, Germany
    12 | GB, United Kingdom
     8 | FR, France
══════════════════════════════════════════════════════
Refreshing every 14s... (Press any key to exit)
```

### Web Dashboard Display

**Options:**
1. **List View** - Similar to CLI, but in web UI
2. **Bar Chart** - Visual bars (like existing geo chart)
3. **Map View** - Interactive world map (requires map library)
4. **Combined** - List + chart

## 🔧 Implementation Plan

### Phase 1: CLI Integration (Quick Win)

1. ✅ Add `show_geo_stats()` function to `dashboard.sh`
2. ✅ Add menu option "View peer locations"
3. ✅ Check dependencies and provide helpful errors
4. ✅ Test on Linux

**Estimated effort**: 1-2 hours

### Phase 2: Standalone Script

1. ✅ Create `scripts/geo-peers.sh`
2. ✅ Make it executable
3. ✅ Add to documentation
4. ✅ Test and refine

**Estimated effort**: 1 hour

### Phase 3: Web Dashboard Integration

1. ⏳ Add API endpoint when web dashboard is built
2. ⏳ Add UI component
3. ⏳ Real-time updates
4. ⏳ Visual enhancements

**Estimated effort**: 2-3 hours (after web dashboard exists)

## 💡 Key Learnings from conduit-manager

1. **14-second sampling** - Good balance between accuracy and responsiveness
2. **IP filtering** - Important to exclude local/private IPs
3. **Special formatting** - Iran gets special treatment (highlights importance)
4. **Top 20 limit** - Keeps display manageable
5. **Real-time feel** - Updates create sense of live activity
6. **Dependency checks** - Graceful handling when tools missing

## 🚀 Quick Implementation

### Add to dashboard.sh

```bash
# Add after get_conduit_stats function
show_geo_peers() {
    # Check dependencies
    if ! command -v tcpdump &>/dev/null || ! command -v geoiplookup &>/dev/null; then
        echo -e "${YELLOW}⚠️  Dependencies missing${NC}"
        echo "Install: sudo apt install tcpdump geoip-bin"
        echo "Or: sudo yum install tcpdump GeoIP"
        return 1
    fi

    # Check if running as root (needed for tcpdump)
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}⚠️  Root access required for tcpdump${NC}"
        echo "Run: sudo ./scripts/dashboard.sh"
        return 1
    fi

    local stop_peers=0
    trap 'stop_peers=1' SIGINT SIGTERM

    while [ $stop_peers -eq 0 ]; do
        clear
        print_header
        echo -e "${CYAN}═══ LIVE PEER CONNECTIONS BY COUNTRY ═══${NC}"
        echo ""
        
        # Capture and display
        local iface="any"
        local local_ip=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7}')
        [ -z "$local_ip" ] && local_ip=$(hostname -I | awk '{print $1}')
        
        echo -e "${YELLOW}Capturing connections (14s)...${NC}"
        echo ""
        
        timeout 14 tcpdump -ni $iface '(tcp or udp)' 2>/dev/null | \
            grep ' IP ' | \
            sed -nE 's/.* IP ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})(\.[0-9]+)?[ >].*/\1/p' | \
            grep -vE "^($local_ip|10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.|0\.|169\.254\.)" | \
            sort -u | \
            xargs -n1 geoiplookup 2>/dev/null | \
            awk -F: '/Country Edition/{print $2}' | \
            sed 's/Iran, Islamic Republic of/Iran - #FreeIran/' | \
            sort | uniq -c | sort -rn | head -20 | \
            while read count country; do
                CODE=$(echo "$country" | cut -d',' -f1)
                NAME=$(echo "$country" | cut -d',' -f2- | sed 's/^ *//' | cut -c1-30)
                if [ "$CODE" = "IR" ]; then
                    printf " ${GREEN}%4d${NC} | ${GREEN}%-2s${NC} | ${GREEN}%-30s${NC}\n" "$count" "$CODE" "$NAME"
                else
                    printf " %4d | %-2s | %-30s\n" "$count" "$CODE" "$NAME"
                fi
            done
        
        echo ""
        echo -e "${CYAN}Press any key to return to menu...${NC}"
        read -t 1 -n 1 -s <> /dev/tty 2>/dev/null && stop_peers=1
    done
    
    trap - SIGINT SIGTERM
}
```

## 📊 Comparison: Our Stats vs Their Map

| Feature | Our Stats.json | Their tcpdump Method |
|---------|----------------|---------------------|
| **Data Source** | Conduit internal stats | Network packet capture |
| **Accuracy** | ✅ Exact (from Conduit) | ⚠️ Approximate (network traffic) |
| **Country Info** | ❌ No | ✅ Yes |
| **Real-time** | ✅ Yes | ✅ Yes |
| **Dependencies** | ✅ None | ⚠️ tcpdump + geoip |
| **Permissions** | ✅ User-level | ⚠️ Root required |
| **Platform** | ✅ All | ⚠️ Linux mainly |

## 🎯 Recommendation

**Best Approach**: Hybrid

1. **Use stats.json for core metrics** (clients, traffic)
2. **Add geo-peers as optional feature** (when dependencies available)
3. **Make it easy to enable/disable**

**Implementation Priority:**
1. ✅ Add standalone script (`geo-peers.sh`) - Easy, useful
2. ✅ Add to CLI dashboard menu - Quick integration
3. ⏳ Add to web dashboard - When web dashboard exists

---

**Status**: Ready to implement Phase 1 (CLI integration)
