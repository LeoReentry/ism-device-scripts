#!/bin/bash
# git clone --recursive https://github.com/LeoReentry/ism-device-scripts.git
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

# Add home variable manually because sudo changes it to /root
HOMEVAR=/home/debian

# Create folder for logfiles
if [ ! -d "$LOGPATH" ]; then
  mkdir $LOGPATH
fi

# Set path variables as environment variables
export LOGPATH
export SCRIPTPATH
export HOMEVAR
# Disable HDMI but enable eMMC overlay
# sudo sed -i 's/#dtb=am335x-boneblack-emmc-overlay.dtb/dtb=am335x-boneblack-emmc-overlay.dtb/gi' /boot/uEnv.txt


# ============================================================
# Downgrade Kernel to 3.8
# ============================================================
# If kernel isn't version 3.8.X, we'll have to update it
uname -r | grep -qP "3\.8\.\d{1,}-[\w\d]{1,}"
# If we don't have the desired Kernel version, we'll install it
if [ $? -eq  1 ]; then
  # Update kernel
  source $SCRIPTPATH/kernel.sh
# ============================================================
# Add Realtime module to startup modules only if kernel 3.8
# is installed
# ============================================================
elif ! fgrep -q "uio_pruss" "/etc/modules"; then
  echo "Adding Realtime module... Done!"
  sudo sh -c "echo 'uio_pruss' >> /etc/modules"
fi

# ============================================================
# Install TPM
# ============================================================
if ! fgrep -q "tpm" "$LOGPATH/finished"; then
  # Initialize TPM
  source $SCRIPTPATH/tpm.sh
fi


# GCC update currently not needed
# # ============================================================
# # Update GCC and G++ from Debian Testing repositories
# # ============================================================
# if ! fgrep -q "gcc" "$LOGPATH/finished"; then
#   # Install GCC and G++
#   source $SCRIPTPATH/gcc.sh
# fi

# ============================================================
# Install Device Software
# ============================================================
if ! fgrep -q "device" "$LOGPATH/finished"; then
  # Install crypto stuff
  source $SCRIPTPATH/device.sh
fi

# ============================================================
# Install Device Encryption Helper
# ============================================================
if ! fgrep -q "crypto" "$LOGPATH/finished"; then
  # Install crypto stuff
  source $SCRIPTPATH/crypto.sh
fi

# ============================================================
# Do a cleanup of the BBB
# ============================================================
if ! fgrep -q "clean" "$LOGPATH/finished"; then
  # Cleanup
  source $SCRIPTPATH/clean.sh
fi

# ============================================================
# Install NodeJS and get configuration server
# ============================================================
if ! fgrep -q "server" "$LOGPATH/finished"; then
  # Install crypto stuff
  source $SCRIPTPATH/server.sh
fi

# Reboot before talking to TPM
sudo reboot


# ============================================================
# Reset TPM and renew SSH keys
# ============================================================
source $SCRIPTPATH/postflash.sh
