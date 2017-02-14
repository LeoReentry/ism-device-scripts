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
git pull >> $LOGPATH/kernel.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during kernel download. See logfile kernel.log for details." 1>&2
  exit 1
fi

echo "-------- UPDATE KERNEL SCRIPT --------" >> $LOGPATH/kernel.log
echo -ne "Done!\nInstalling Kernel v3.8.X with full cape support. This may take up to 10 minutes... "
# Install kernel
sudo ./update_kernel.sh --bone-channel --stable >> $LOGPATH/kernel.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during kernel installation. See logfile kernel.log for details." 1>&2
  exit 1
fi
echo "Done!"

# Finish
echo "kernel" > $LOGPATH/finished
# Reboot
echo "Restarting now..."
# Double exit to exit script and SSH
sudo reboot now & exit & exit
# sudo shutdown -r now
