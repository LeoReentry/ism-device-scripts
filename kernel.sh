#!/bin/bash

# Kernel update script
echo "Updating Kernel..."
cd /opt/scripts/tools
echo "Downloading Kernel Versions..."
git pull > /dev/null
echo "Installing Kernel v4.4.X mainline + Realtime"
sudo ./update_kernel.sh --lts-4_4 --bone-rt-channel > /dev/null
echo "Done. Restarting in 10 seconds. Press ^c to cancel."
sleep 10
sudo shutdown -r now
