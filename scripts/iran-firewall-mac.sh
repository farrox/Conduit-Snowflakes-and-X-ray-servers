#!/bin/bash
# Iran-Only Firewall for Psiphon Conduit (macOS)
# Maximizes bandwidth for Iranian users by blocking non-Iran IPs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Conduit ports (adjust if needed)
CONDUIT_UDP_PORT=9876
CONDUIT_TCP_PORT=9876

# Configuration files
PF_ANCHOR="conduit_iran"
PF_RULES_FILE="/tmp/conduit_iran.conf"
IRAN_IP_FILE="/tmp/iran_ips.txt"
IRAN_IPV6_FILE="/tmp/iran_ips_v6.txt"
IRAN_TABLE_FILE="/tmp/iran_ips_table.txt"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Banner
clear
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Iran-Only Firewall for Conduit (macOS)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to fetch Iran IP ranges
fetch_iran_ips() {
    echo -e "${YELLOW}Fetching Iran IP ranges...${NC}"
    
    # Fetch IPv4 ranges
    curl -s "https://www.ipdeny.com/ipblocks/data/countries/ir.zone" > "$IRAN_IP_FILE" 2>/dev/null || {
        echo -e "${RED}Failed to fetch IPv4 ranges. Using backup source...${NC}"
        curl -s "https://raw.githubusercontent.com/herrbischoff/country-ip-blocks/master/ipv4/ir.cidr" > "$IRAN_IP_FILE" || {
            echo -e "${RED}All sources failed. Cannot continue.${NC}"
            exit 1
        }
    }
    
    # Fetch IPv6 ranges
    curl -s "https://www.ipdeny.com/ipv6/ipaddresses/blocks/ir.zone" > "$IRAN_IPV6_FILE" 2>/dev/null || {
        echo -e "${YELLOW}IPv6 ranges unavailable, continuing with IPv4 only...${NC}"
        touch "$IRAN_IPV6_FILE"
    }
    
    # Combine for pfctl table format
    cat "$IRAN_IP_FILE" "$IRAN_IPV6_FILE" > "$IRAN_TABLE_FILE"
    
    local ipv4_count=$(wc -l < "$IRAN_IP_FILE" | tr -d ' ')
    local ipv6_count=$(wc -l < "$IRAN_IPV6_FILE" | tr -d ' ')
    
    echo -e "${GREEN}✓ Fetched ${ipv4_count} IPv4 ranges${NC}"
    echo -e "${GREEN}✓ Fetched ${ipv6_count} IPv6 ranges${NC}"
    echo ""
}

# Function to enable Normal mode (UDP Iran-only, TCP global)
enable_normal_mode() {
    echo -e "${GREEN}Enabling Normal Mode (UDP: Iran-only, TCP: Global)${NC}"
    echo ""
    
    fetch_iran_ips
    
    # Create pfctl rules
    cat > "$PF_RULES_FILE" << EOF
# Conduit Iran-Only Firewall - Normal Mode
# UDP: Iran-only, TCP: Global (keeps node visible)

# Define table with Iran IPs
table <iran_ips> persist file "$IRAN_TABLE_FILE"

# Allow loopback
pass quick on lo0

# Allow established connections
pass quick proto tcp from any to any flags S/SA keep state
pass quick proto udp from any to any keep state

# TCP: Allow all (keeps node visible to Psiphon network)
pass in quick proto tcp from any to any port $CONDUIT_TCP_PORT

# UDP: Allow only Iran IPs
pass in quick proto udp from <iran_ips> to any port $CONDUIT_UDP_PORT

# Block all other UDP to Conduit port
block drop in quick proto udp from any to any port $CONDUIT_UDP_PORT

EOF
    
    # Load rules into pfctl anchor
    if pfctl -a "$PF_ANCHOR" -f "$PF_RULES_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ Rules loaded into pfctl${NC}"
    else
        echo -e "${RED}Failed to load rules. Trying to enable pf first...${NC}"
        pfctl -e 2>/dev/null || true
        pfctl -a "$PF_ANCHOR" -f "$PF_RULES_FILE"
    fi
    
    # Make sure pf is enabled
    pfctl -e 2>/dev/null || true
    
    echo ""
    echo -e "${GREEN}✓✓✓ Normal Mode ENABLED ✓✓✓${NC}"
    echo -e "${BLUE}Your Conduit node is now optimized for Iranian users.${NC}"
    echo -e "${BLUE}TCP keeps your node visible, UDP saves bandwidth.${NC}"
}

# Function to enable Strict mode (both UDP and TCP Iran-only)
enable_strict_mode() {
    echo -e "${GREEN}Enabling Strict Mode (UDP + TCP: Iran-only)${NC}"
    echo ""
    
    fetch_iran_ips
    
    # Create pfctl rules
    cat > "$PF_RULES_FILE" << EOF
# Conduit Iran-Only Firewall - Strict Mode
# Both UDP and TCP: Iran-only

# Define table with Iran IPs
table <iran_ips> persist file "$IRAN_TABLE_FILE"

# Allow loopback
pass quick on lo0

# Allow established connections
pass quick proto tcp from any to any flags S/SA keep state
pass quick proto udp from any to any keep state

# TCP: Allow only Iran IPs
pass in quick proto tcp from <iran_ips> to any port $CONDUIT_TCP_PORT

# UDP: Allow only Iran IPs
pass in quick proto udp from <iran_ips> to any port $CONDUIT_UDP_PORT

# Block all other traffic to Conduit ports
block drop in quick proto tcp from any to any port $CONDUIT_TCP_PORT
block drop in quick proto udp from any to any port $CONDUIT_UDP_PORT

EOF
    
    # Load rules into pfctl anchor
    if pfctl -a "$PF_ANCHOR" -f "$PF_RULES_FILE" 2>/dev/null; then
        echo -e "${GREEN}✓ Rules loaded into pfctl${NC}"
    else
        echo -e "${RED}Failed to load rules. Trying to enable pf first...${NC}"
        pfctl -e 2>/dev/null || true
        pfctl -a "$PF_ANCHOR" -f "$PF_RULES_FILE"
    fi
    
    # Make sure pf is enabled
    pfctl -e 2>/dev/null || true
    
    echo ""
    echo -e "${GREEN}✓✓✓ Strict Mode ENABLED ✓✓✓${NC}"
    echo -e "${YELLOW}⚠ Warning: Your node may become less visible to Psiphon's network.${NC}"
    echo -e "${BLUE}Both TCP and UDP are now restricted to Iranian IPs only.${NC}"
}

# Function to disable (remove all rules)
disable_firewall() {
    echo -e "${YELLOW}Disabling Iran-only firewall...${NC}"
    
    # Flush the anchor
    pfctl -a "$PF_ANCHOR" -F all 2>/dev/null || true
    
    # Clean up files
    rm -f "$PF_RULES_FILE" "$IRAN_IP_FILE" "$IRAN_IPV6_FILE" "$IRAN_TABLE_FILE"
    
    echo ""
    echo -e "${GREEN}✓ Iran-only mode DISABLED${NC}"
    echo -e "${BLUE}Conduit now accepts connections from all countries.${NC}"
}

# Function to check status
check_status() {
    echo -e "${YELLOW}Checking firewall status...${NC}"
    echo ""
    
    if pfctl -a "$PF_ANCHOR" -s rules 2>/dev/null | grep -q .; then
        echo -e "${GREEN}Status: ACTIVE${NC}"
        echo ""
        echo "Active Rules:"
        pfctl -a "$PF_ANCHOR" -s rules
        echo ""
        echo "Iran IPs Table:"
        pfctl -a "$PF_ANCHOR" -t iran_ips -T show | head -20
        local count=$(pfctl -a "$PF_ANCHOR" -t iran_ips -T show | wc -l | tr -d ' ')
        echo ""
        echo "Total Iran IP ranges loaded: $count"
    else
        echo -e "${RED}Status: INACTIVE${NC}"
        echo "No Iran-only firewall rules are currently active."
    fi
}

# Main menu
show_menu() {
    echo ""
    echo -e "${BLUE}====== MAIN MENU ======${NC}"
    echo "1. 🟢 Enable Normal Mode (UDP: Iran, TCP: Global)"
    echo "2. 🔒 Enable Strict Mode (UDP + TCP: Iran only)"
    echo "3. 🔴 Disable Iran-only mode"
    echo "4. 📊 Check status"
    echo "0. 🚪 Exit"
    echo ""
    read -p "Choose option: " choice
    
    case $choice in
        1)
            enable_normal_mode
            read -p "Press Enter to continue..."
            show_menu
            ;;
        2)
            enable_strict_mode
            read -p "Press Enter to continue..."
            show_menu
            ;;
        3)
            disable_firewall
            read -p "Press Enter to continue..."
            show_menu
            ;;
        4)
            check_status
            read -p "Press Enter to continue..."
            show_menu
            ;;
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option${NC}"
            sleep 1
            show_menu
            ;;
    esac
}

# Start
show_menu
