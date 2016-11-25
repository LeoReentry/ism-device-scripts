#!/bin/bash

# Initialization script for Beaglebone

# Get path variables
SCRIPT=$(readlink -f "$0")
PATH=$(dirname "$SCRIPT")
LOGPATH="$PATH/log"
SCRIPTPATH="$PATH/sub"
# Set path variables as environment variables
export LOGPATH
export SCRIPTPATH

# Check if Kernel is in updated version
# We want the Kernel that's downgraded to 3.8.X
uname -r | grep -qP "3\.8\.\d{1,}-r\d{1,}"
# If we don't have the desired Kernel version, we'll install it
if [ $? -eq  1 ]; then
  # Update kernel
  $SCRIPTPATH/kernel.sh
fi

# Ok, kernel is installed

# Check that realtime module is defined as startup module
fgrep -q uio_pruss /etc/modules
if [ $? -eq 1 ]; then
  echo "Adding Realtime module..."
  sudo sh -c "echo "uio_pruss" >> /etc/modules"
fi

# Disable HDMI but enable eMMC overlay
sudo sed -i 's/#dtb=am335x-boneblack-emmc-overlay.dtb/dtb=am335x-boneblack-emmc-overlay.dtb/gi' /boot/uEnv.txt
