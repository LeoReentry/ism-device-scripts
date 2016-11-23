#!/bin/bash

# Initialization script for Beaglebone

# Check if Kernel is in updated version
uname -r | grep -P "4\.4\.\d{1,}-bone-rt-r\d{1,}" > /dev/null
if [ $? -eq  1 ]; then
  # Disable HDMI (enable eMCC overlay so cape is usable)
  sudo sed -i 's/#dtb=am335x-boneblack-emmc-overlay.dtb/dtb=am335x-boneblack-emmc-overlay.dtb/gi' /boot/uEnv.txt
  # Update kernel
  ./kernel.sh
fi
