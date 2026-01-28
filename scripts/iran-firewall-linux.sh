#!/bin/bash
# Iran-Only Firewall for Psiphon Conduit (Linux)
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

# Chain names
CHAIN_NAME="CONDUIT_IRAN"
IRAN_IP_FILE="/tmp/iran_ips.txt"
IRAN_IPV6_FILE="/tmp/iran_ips_v6.txt"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Detect which firewall tool to use
if command -v iptables &> /dev/null; then
    FIREWALL="iptables"
    echo -e "${GREEN}Detected: iptables${NC}"
else
    echo -e "${RED}Error: iptables not found. Please install iptables.${NC}"
    exit 1
fi

# Banner
clear
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Iran-Only Firewall for Conduit (Linux)${NC}"
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
    
    local ipv4_count=$(wc -l < "$IRAN_IP_FILE")
    local ipv6_count=$(wc -l < "$IRAN_IPV6_FILE")
    
    echo -e "${GREEN}✓ Fetched ${ipv4_count} IPv4 ranges${NC}"
    echo -e "${GREEN}✓ Fetched ${ipv6_count} IPv6 ranges${NC}"
    echo ""
}

# Function to create chains if they don't exist
create_chains() {
    # IPv4
    if ! iptables -L "$CHAIN_NAME" &>/dev/null; then
        iptables -N "$CHAIN_NAME"
        echo -e "${GREEN}✓ Created IPv4 chain: $CHAIN_NAME${NC}"
    fi
    
    # IPv6
    if ! ip6tables -L "$CHAIN_NAME" &>/dev/null; then
        ip6tables -N "$CHAIN_NAME"
        echo -e "${GREEN}✓ Created IPv6 chain: $CHAIN_NAME${NC}"
    fi
}

# Function to clear existing rules
clear_rules() {
    echo -e "${YELLOW}Clearing existing Conduit firewall rules...${NC}"
    
    # Remove jump rules
    iptables -D INPUT -j "$CHAIN_NAME" 2>/dev/null || true
    ip6tables -D INPUT -j "$CHAIN_NAME" 2>/dev/null || true
    
    # Flush chains
    iptables -F "$CHAIN_NAME" 2>/dev/null || true
    ip6tables -F "$CHAIN_NAME" 2>/dev/null || true
    
    # Delete chains
    iptables -X "$CHAIN_NAME" 2>/dev/null || true
    ip6tables -X "$CHAIN_NAME" 2>/dev/null || true
    
    echo -e "${GREEN}✓ Cleared${NC}"
}

# Function to enable Normal mode (UDP Iran-only, TCP global)
enable_normal_mode() {
    echo -e "${GREEN}Enabling Normal Mode (UDP: Iran-only, TCP: Global)${NC}"
    echo ""
    
    fetch_iran_ips
    create_chains
    
    # Allow loopback
    iptables -A "$CHAIN_NAME" -i lo -j ACCEPT
    ip6tables -A "$CHAIN_NAME" -i lo -j ACCEPT
    
    # Allow established connections
    iptables -A "$CHAIN_NAME" -m state --state ESTABLISHED,RELATED -j ACCEPT
    ip6tables -A "$CHAIN_NAME" -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # TCP: Allow all (keeps node visible to Psiphon network)
    iptables -A "$CHAIN_NAME" -p tcp --dport "$CONDUIT_TCP_PORT" -j ACCEPT
    ip6tables -A "$CHAIN_NAME" -p tcp --dport "$CONDUIT_TCP_PORT" -j ACCEPT
    echo -e "${GREEN}✓ TCP: Global access (port $CONDUIT_TCP_PORT)${NC}"
    
    # UDP: Allow only Iran IPs
    local count=0
    while IFS= read -r ip; do
        [ -z "$ip" ] && continue
        iptables -A "$CHAIN_NAME" -p udp --dport "$CONDUIT_UDP_PORT" -s "$ip" -j ACCEPT
        ((count++))
    done < "$IRAN_IP_FILE"
    echo -e "${GREEN}✓ UDP: Iran-only access (${count} IPv4 ranges, port $CONDUIT_UDP_PORT)${NC}"
    
    # IPv6 UDP: Allow only Iran IPs
    if [ -s "$IRAN_IPV6_FILE" ]; then
        count=0
        while IFS= read -r ip; do
            [ -z "$ip" ] && continue
            ip6tables -A "$CHAIN_NAME" -p udp --dport "$CONDUIT_UDP_PORT" -s "$ip" -j ACCEPT
            ((count++))
        done < "$IRAN_IPV6_FILE"
        echo -e "${GREEN}✓ UDP: Iran-only access (${count} IPv6 ranges)${NC}"
    fi
    
    # Drop all other UDP to Conduit port
    iptables -A "$CHAIN_NAME" -p udp --dport "$CONDUIT_UDP_PORT" -j DROP
    ip6tables -A "$CHAIN_NAME" -p udp --dport "$CONDUIT_UDP_PORT" -j DROP
    
    # Activate chains
    iptables -I INPUT 1 -j "$CHAIN_NAME"
    ip6tables -I INPUT 1 -j "$CHAIN_NAME"
    
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
    create_chains
    
    # Allow loopback
    iptables -A "$CHAIN_NAME" -i lo -j ACCEPT
    ip6tables -A "$CHAIN_NAME" -i lo -j ACCEPT
    
    # Allow established connections
    iptables -A "$CHAIN_NAME" -m state --state ESTABLISHED,RELATED -j ACCEPT
    ip6tables -A "$CHAIN_NAME" -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Both TCP and UDP: Allow only Iran IPs (IPv4)
    local tcp_count=0
    local udp_count=0
    while IFS= read -r ip; do
        [ -z "$ip" ] && continue
        iptables -A "$CHAIN_NAME" -p tcp --dport "$CONDUIT_TCP_PORT" -s "$ip" -j ACCEPT
        iptables -A "$CHAIN_NAME" -p udp --dport "$CONDUIT_UDP_PORT" -s "$ip" -j ACCEPT
        ((tcp_count++))
        ((udp_count++))
    done < "$IRAN_IP_FILE"
    
    echo -e "${GREEN}✓ TCP: Iran-only (${tcp_count} IPv4 ranges, port $CONDUIT_TCP_PORT)${NC}"
    echo -e "${GREEN}✓ UDP: Iran-only (${udp_count} IPv4 ranges, port $CONDUIT_UDP_PORT)${NC}"
    
    # Both TCP and UDP: Allow only Iran IPs (IPv6)
    if [ -s "$IRAN_IPV6_FILE" ]; then
        tcp_count=0
        udp_count=0
        while IFS= read -r ip; do
            [ -z "$ip" ] && continue
            ip6tables -A "$CHAIN_NAME" -p tcp --dport "$CONDUIT_TCP_PORT" -s "$ip" -j ACCEPT
            ip6tables -A "$CHAIN_NAME" -p udp --dport "$CONDUIT_UDP_PORT" -s "$ip" -j ACCEPT
            ((tcp_count++))
            ((udp_count++))
        done < "$IRAN_IPV6_FILE"
        echo -e "${GREEN}✓ TCP: Iran-only (${tcp_count} IPv6 ranges)${NC}"
        echo -e "${GREEN}✓ UDP: Iran-only (${udp_count} IPv6 ranges)${NC}"
    fi
    
    # Drop all other traffic to Conduit ports
    iptables -A "$CHAIN_NAME" -p tcp --dport "$CONDUIT_TCP_PORT" -j DROP
    iptables -A "$CHAIN_NAME" -p udp --dport "$CONDUIT_UDP_PORT" -j DROP
    ip6tables -A "$CHAIN_NAME" -p tcp --dport "$CONDUIT_TCP_PORT" -j DROP
    ip6tables -A "$CHAIN_NAME" -p udp --dport "$CONDUIT_UDP_PORT" -j DROP
    
    # Activate chains
    iptables -I INPUT 1 -j "$CHAIN_NAME"
    ip6tables -I INPUT 1 -j "$CHAIN_NAME"
    
    echo ""
    echo -e "${GREEN}✓✓✓ Strict Mode ENABLED ✓✓✓${NC}"
    echo -e "${YELLOW}⚠ Warning: Your node may become less visible to Psiphon's network.${NC}"
    echo -e "${BLUE}Both TCP and UDP are now restricted to Iranian IPs only.${NC}"
}

# Function to disable (remove all rules)
disable_firewall() {
    clear_rules
    echo ""
    echo -e "${GREEN}✓ Iran-only mode DISABLED${NC}"
    echo -e "${BLUE}Conduit now accepts connections from all countries.${NC}"
}

# Function to check status
check_status() {
    echo -e "${YELLOW}Checking firewall status...${NC}"
    echo ""
    
    if iptables -L "$CHAIN_NAME" &>/dev/null; then
        echo -e "${GREEN}Status: ACTIVE${NC}"
        echo ""
        echo "IPv4 Rules:"
        iptables -L "$CHAIN_NAME" -n -v | head -20
        echo ""
        if ip6tables -L "$CHAIN_NAME" &>/dev/null 2>&1; then
            echo "IPv6 Rules:"
            ip6tables -L "$CHAIN_NAME" -n -v | head -20
        fi
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
