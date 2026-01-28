# Security & Firewall Configuration

## Overview

By default, Conduit accepts connections from anywhere in the world. If you want to restrict traffic to specific regions (e.g., only Iran) to prevent unauthorized bandwidth usage, you'll need to configure your firewall.

## Why This Matters

Without firewall restrictions, your Conduit node may accept connections from anywhere, which could:
- Use bandwidth for unintended regions
- Potentially expose you to unwanted traffic
- Reduce available bandwidth for your target region

## Windows Users

**Recommended Solution:** Use the [Iran Conduit Firewall](https://github.com/SamNet-dev/iran-conduit-firewall) project, which provides:

- ✅ **Explicit blocking rules** (not relying on defaults)
- ✅ **Full IPv6 support** (closes IPv6 loopholes)
- ✅ **Two modes**: Normal (UDP Iran-only + TCP Global) or Strict (both restricted)
- ✅ **Auto-elevation** (no manual "Run as Admin" needed)
- ✅ **Smart detection** (finds Conduit executable automatically)
- ✅ **Diagnostic logging** (troubleshooting made easy)

**Installation:**
1. Download from: https://github.com/SamNet-dev/iran-conduit-firewall/releases
2. Run the script - it handles everything automatically
3. Choose Normal or Strict mode based on your needs

**Note:** The project is specifically designed for Iran, but the approach can be adapted for other regions.

## macOS Users

### Option 1: Automated Script (Recommended)

Use our automated Iran-only firewall script:

```bash
sudo ./scripts/iran-firewall-mac.sh
```

**Features:**
- ✅ Automatically fetches 2000+ Iran IP ranges (IPv4 & IPv6)
- ✅ **Normal Mode**: UDP Iran-only, TCP global (keeps node visible)
- ✅ **Strict Mode**: Both UDP & TCP Iran-only
- ✅ Easy enable/disable
- ✅ Uses pfctl (macOS built-in firewall)

### Option 2: Using Little Snitch or Lulu (Third-Party)

These macOS firewall apps provide GUI-based control:
- **Little Snitch**: https://www.obdev.at/products/littlesnitch/
- **Lulu**: https://objective-see.com/products/lulu.html

Configure them to:
1. Allow Conduit connections only from specific IP ranges
2. Block all other connections to Conduit

### Option 3: Network-Level Restrictions

If you have a router with firewall capabilities:
- Configure router firewall rules
- Restrict Conduit traffic at the network level
- This protects all devices on your network

## Linux Users

### Option 1: Automated Script (Recommended)

Use our automated Iran-only firewall script:

```bash
sudo ./scripts/iran-firewall-linux.sh
```

**Features:**
- ✅ Automatically fetches 2000+ Iran IP ranges (IPv4 & IPv6)
- ✅ **Normal Mode**: UDP Iran-only, TCP global (keeps node visible)
- ✅ **Strict Mode**: Both UDP & TCP Iran-only
- ✅ Easy enable/disable
- ✅ Uses iptables

### Option 2: Manual iptables Configuration

If you prefer manual setup:

```bash
# Example: Allow only specific IP ranges
sudo iptables -A INPUT -p tcp --dport [CONDUIT_PORT] -s [ALLOWED_IP_RANGE] -j ACCEPT
sudo iptables -A INPUT -p tcp --dport [CONDUIT_PORT] -j DROP

# For IPv6 (important!)
sudo ip6tables -A INPUT -p tcp --dport [CONDUIT_PORT] -s [ALLOWED_IPV6_RANGE] -j ACCEPT
sudo ip6tables -A INPUT -p tcp --dport [CONDUIT_PORT] -j DROP
```

## Important Considerations

### IPv6 Support
**Critical:** Make sure your firewall rules cover both IPv4 and IPv6. IPv6 can bypass IPv4-only restrictions.

### Normal vs Strict Mode
- **Normal Mode**: UDP restricted to target region, TCP global (keeps node visible to Psiphon network)
- **Strict Mode**: Both TCP and UDP restricted (maximum isolation, may reduce visibility)

### Testing Your Firewall
After configuring firewall rules:
1. Test from allowed IP ranges (should work)
2. Test from blocked IP ranges (should be blocked)
3. Monitor Conduit logs to verify connections are from expected regions

## Getting IP Ranges for Your Region

To restrict to a specific country/region, you'll need their IP ranges:

1. **RIR (Regional Internet Registry) databases**
   - APNIC, ARIN, RIPE, etc.
2. **IP geolocation databases**
   - MaxMind GeoIP
   - IP2Location
3. **Country-specific IP lists**
   - Some countries publish official IP ranges

## Example: Iran IP Ranges

If you're targeting Iran specifically, the [Iran Conduit Firewall](https://github.com/SamNet-dev/iran-conduit-firewall) project automatically fetches and applies Iran's IP ranges (both IPv4 and IPv6).

## Monitoring & Logging

Enable verbose logging in Conduit to monitor connections:

```bash
./dist/conduit start --psiphon-config ./psiphon_config.json -v
```

Check your firewall logs regularly to ensure rules are working correctly.

## References

- **Windows Solution**: [Iran Conduit Firewall](https://github.com/SamNet-dev/iran-conduit-firewall) - Comprehensive Windows firewall solution
- **macOS pfctl**: [Apple's pfctl documentation](https://developer.apple.com/library/archive/documentation/Darwin/Reference/ManPages/man8/pfctl.8.html)
- **Linux iptables**: Standard Linux firewall tool

## Security Best Practices

1. **Use explicit blocking rules** (don't rely on defaults)
2. **Cover both IPv4 and IPv6**
3. **Test your firewall rules** before relying on them
4. **Monitor logs** regularly
5. **Keep firewall rules updated** as IP ranges change
6. **Document your configuration** for troubleshooting

---

**Note**: Firewall configuration is advanced and can affect network connectivity. Test thoroughly in a safe environment before deploying in production.
