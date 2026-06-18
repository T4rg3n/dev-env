#!/bin/bash

# udev rule to force NVMe + WiFi into runtime autosuspend 
sudo tee /etc/udev/rules.d/99-powersave.rules << 'EOF'
# WD SN850 NVMe - force runtime autosuspend
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x15b7", ATTR{device}=="0x5030", ATTR{power/control}="auto"
# Intel AX210 WiFi - force runtime autosuspend
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x2725", ATTR{power/control}="auto"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger