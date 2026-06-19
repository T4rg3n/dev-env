#!/bin/bash

# Disable P-Cores while on battery

# Backup original config
sudo cp /etc/intel_lpmd/intel_lpmd_config.xml /etc/intel_lpmd/intel_lpmd_config.xml.bak

# Apply our custom config
CONFIG="$(dirname "$0")/intel_lpmd_config.xml"
if [[ ! -f "$CONFIG" ]]; then
  echo "Error: config file not found at $CONFIG" >&2
  exit 1
fi
sudo cp "$CONFIG" /etc/intel_lpmd/intel_lpmd_config.xml

# Reload intel_lpmd service
sudo systemctl restart intel_lpmd

# Check status
echo "Intel LP-Mode status:"
sudo systemctl status intel_lpmd

echo "Intel LP-Mode configured. P-Cores will idle on Balanced/Power Saver profiles."