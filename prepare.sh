#!/bin/bash
# ============================================================
# ============================================================
# This script should be used when the BeagleBone has been
# with one of the provided Snapshots
# ============================================================
# ============================================================

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script"
    exit 1
fi
# Remove all SSH Keys
sudo rm -rf /etc/ssh/ssh_host*
# Generate new RSA 4096 key
sudo ssh-keygen -b 4096 -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
# Generate ED25519 key (256 bits)
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
