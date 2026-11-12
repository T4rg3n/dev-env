#!/bin/bash

# Switches from default s2idle to deep sleep

# grubby reads /boot/grub2/grubenv, which is root-only.
if sudo grubby --info=ALL | grep -q "mem_sleep_default=deep"; then
    echo "Power configuration is already set to deep sleep"
    exit 0
fi

# Set the power configuration to deep sleep
sudo grubby --update-kernel=ALL --args="mem_sleep_default=deep"