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
  echo "Adding Realtime module."
  sudo sh -c "echo 'uio_pruss' >> /etc/modules"
fi

# ============================================================
# Install TPM
# ============================================================
if ! fgrep -q "tpm" "$LOGPATH/finished"; then
  # Initialize TPM
  source $SCRIPTPATH/tpm.sh
fi

# ============================================================
# Update GCC and G++ from Debian Testing repositories
# ============================================================
if ! fgrep -q "gcc" "$LOGPATH/finished"; then
  # Install GCC and G++
  source $SCRIPTPATH/gcc.sh
fi

# ============================================================
# Install Device Encryption Helper
# ============================================================
if ! fgrep -q "crypto" "$LOGPATH/finished"; then
  # Install crypto stuff
  source $SCRIPTPATH/crypto.sh
fi

# ============================================================
# Reset TPM
# ============================================================
if ! fgrep -q "cape-init" "$LOGPATH/finished"; then
  echo "-------- GIT CLONE cryptocape-init --------" >> $LOGPATH/crypto.log
  cd $HOMEVAR
  git clone https://github.com/cryptotronix/cryptocape-init.git >> crypto.log 2>&1
  cd cryptocape-init
  echo "Ok, we are now clearing the TPM, you might be asked for a password."
  echo -n "This process cannot be reverted. If you already own the TPM, you can cancel this. You might be asked this question again after reboot. Continue (y/n)? "
  read answer
  if [ $answer = "y" ];then
    source ./tpm_clear_own.sh
    owned = cat /sys/class/misc/tpm0/device/owned
    if [ $owned -eq 1 ]; then
      echo "cape-init" >> $LOGPATH/finished
      # Make user debian owner of init functions
      sudo chown debian:debian -R $HOMEVAR/cryptocape-init
    fi
  fi
fi
