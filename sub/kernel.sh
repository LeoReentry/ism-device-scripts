#!/bin/bash

# Kernel update script
# This script will downgrade the Beaglebone Black Kernel to version 3.8
# That gives the Kernel full cape support (aka support for CryptoCape)

cd /opt/scripts/tools

# Print some readable output to shell
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tUpdate Kernel"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =


echo -n "Downloading Kernel Versions... "
# Log
echo "-------- PULL KERNEL VERSIONS --------" > $LOGPATH/kernel.log
git pull -q >> $LOGPATH/kernel.log

echo -ne "Done!\nInstalling Kernel v3.8.X with full cape support. This may take up to 10 minutes... "
# Log
echo "-------- UPDATE KERNEL SCRIPT --------" >> $LOGPATH/kernel.log
# Install kernel
sudo ./update_kernel.sh --bone-channel --stable >> $LOGPATH/kernel.log 2>&1
echo -e "Done!\nRestarting in 10 seconds. Press ^c to cancel."
sleep 10
# Reboot
echo "Restarting now..."
echo "kernel" > $LOGPATH/reboot.log
sudo shutdown -r now
