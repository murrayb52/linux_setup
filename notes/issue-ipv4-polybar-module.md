# Issue: Polybar IPv4 Display Script

## Problem
The IPv4 address was not displaying correctly in the polybar. The script was using `hostname -I` which returns all IP addresses including IPv6, causing formatting issues.

## Root Cause
The original script used:
```bash
IP=$(hostname -I | awk '{print $1}')
```

This approach has limitations:
- Returns multiple IPs on systems with multiple interfaces
- Can include IPv6 addresses
- Not reliable for getting the primary network interface IP

## Solution
Updated the script to use a more robust method that finds the IP address of the interface with the default route:

```bash
#!/bin/bash
# Get IPv4 address of the interface with default route
IP=$(ip -4 route get 8.8.8.8 2>/dev/null | grep -oP 'src \K[\d.]+')

if [ -z "$IP" ]; then
    echo "No Connection"
else
    echo "$IP"
fi
```

### How It Works
1. **`ip -4 route get 8.8.8.8`** - Queries how to reach Google's DNS (8.8.8.8), forcing IPv4 only
2. **`grep -oP 'src \K[\d.]+`** - Extracts the source IP address used for that route
3. If no IP is found (no internet connection), displays "No Connection"

This method:
- Always returns IPv4 (due to `-4` flag)
- Gets the IP of the interface that has internet access
- Works reliably across different network configurations

## Script Location
`~/.config/polybar/scripts/ipv4.sh`

## Prevention
The [[restore.sh]] script ensures all polybar scripts have execute permissions:
```bash
find "$DOTFILES_DIR/.config/polybar" -type f -name "*.sh" -exec chmod +x {} \;
```

## Related Notes
- [[issue-polybar-not-showing]] - Polybar startup issues
- [[setup_notes]] - Main setup documentation
