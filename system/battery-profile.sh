#!/bin/bash

# Set PCI devices to auto

# Enable and start tuned
sudo systemctl enable --now tuned

# Set the battery profile to balanced
sudo tuned-adm profile balanced-battery

# Activate the profile
tuned-adm active