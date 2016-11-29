#!/bin/bash

# ============================================================
# ============================================================
# Initialization script for Beaglebone
# ============================================================
# ============================================================

if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script"
    exit 1
fi

# ============================================================
# Set general path variables and settings
# ============================================================
SCRIPT=$(readlink -f "$0")
THISPATH=$(dirname "$SCRIPT")
LOGPATH="$THISPATH/log"
SCRIPTPATH="$THISPATH/sub"

# Create folder for logfiles
if [ ! -d "$LOGPATH" ]; then
  mkdir $LOGPATH
fi

# Set path variables as environment variables
export LOGPATH
export SCRIPTPATH
# Disable HDMI but enable eMMC overlay
# sudo sed -i 's/#dtb=am335x-boneblack-emmc-overlay.dtb/dtb=am335x-boneblack-emmc-overlay.dtb/gi' /boot/uEnv.txt


# ============================================================
# Check kernel version
# ============================================================
# If kernel isn't version 3.8.X, we'll have to update it
uname -r | grep -qP "3\.8\.\d{1,}-[\w\d]{1,}"
# If we don't have the desired Kernel version, we'll install it
if [ $? -eq  1 ]; then
  # Update kernel
  source $SCRIPTPATH/kernel.sh
fi

# Ok, kernel is installed
# Check that realtime module is defined as startup module
if ! fgrep -q "uio_pruss" "/etc/modules"; then
  echo "Adding Realtime module."
  sudo sh -c "echo "uio_pruss" >> /etc/modules"
fi

if [ ! -e "$LOGPATH/reboot.log" ]; then
  echo "Some error has occured. Please check that kernel 3.8.X is installed next time."
  touch "$LOGPATH/reboot.log"
  echo "kernel" > $LOGPATH/reboot.log
fi

# ============================================================
# Install TPM and update GCC if necessary
# ============================================================
if ! fgrep -q "tpm" "$LOGPATH/reboot.log"; then
  # Initialize TPM
  source $SCRIPTPATH/tpm.sh
fi

if ! fgrep -q "gcc" "$LOGPATH/reboot.log"; then
  # Initialize TPM
  source $SCRIPTPATH/gcc.sh
fi
