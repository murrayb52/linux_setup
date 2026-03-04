# Utils
## Grep

Useful for searching the outputs of commands for specific string.
`[command] | grep [search string]`

**Example:** determine what timezones are available for Europe since I couldn't guess them
`timedatectl list-timezones | grep Europe`
# Networking
`lspci`: Lists all PCI devices 
`lshw`: List detailed information about hardware configurations as root user
`ip a`: Show current local ip addresses for each PCI device

# Datetime
`timedatectl list-timezones`: list available timezones
`timedatectl set-timezone Europe/Berlin`: set timezone to Berlin
