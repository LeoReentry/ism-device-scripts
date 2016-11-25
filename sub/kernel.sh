#!/bin/bash

# Kernel update script
# This script will downgrade the Beaglebone Black Kernel to version 3.8
# That gives the Kernel full cape support (aka support for CryptoCape)

cd /opt/scripts/tools
echo "Downloading Kernel Versions..."
# Log
echo "-------- PULL KERNEL VERSIONS --------" > $LOGPATH/kernel.log
git pull >> ../log/kernel.log

echo "Installing Kernel v3.8.X with full cape support..."
# Log
echo "-------- UPDATE KERNEL SCRIPT --------" > $LOGPATH/kernel.log
# Install kernel
sudo ./update_kernel.sh --bone-channel --stable > $LOGPATH/kernel.log
echo "Done. Restarting in 10 seconds. Press ^c to cancel."
sleep 10
# Reboot
echo "kernel" > $LOGPATH/reboot.log
sudo shutdown -r now
