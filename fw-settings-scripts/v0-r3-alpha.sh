#!/bin/bash

if [ -f /etc/modprobe.d/usb-storage.conf ] && fgrep -q "install usb-storage /bin/true" "/etc/modprobe.d/usb-storage.conf"; then
  echo "[v0-r3-alpha]: usb-storage module already disabled."
else
  # Disable USB mass storage
  sudo sh -c "echo 'install usb-storage /bin/true' > /etc/modprobe.d/usb-storage.conf"
  echo "[v0-r3-alpha]: Disabling module usb-storage... Done!"
fi


if [ -f /etc/modprobe.d/blacklist.conf ] && fgrep -q "blacklist usb-storage" "/etc/modprobe.d/blacklist.conf"; then
  echo "[v0-r3-alpha]: usb-storage module already blacklisted."
else
  # Disable USB mass storage
  sudo sh -c "echo 'blacklist usbhid' >> /etc/modprobe.d/blacklist.conf"
  echo "[v0-r3-alpha]: Blacklisting usb-storage module... Done!"
fi


if [ -f /etc/modprobe.d/blacklist.conf ] && fgrep -q "blacklist usbhid" "/etc/modprobe.d/blacklist.conf"; then
  echo "[v0-r3-alpha]: usbhid module already disabled."
else
  # Disable USB mass storage
  sudo sh -c "echo 'blacklist usbhid' >> /etc/modprobe.d/blacklist.conf"
  echo "[v0-r3-alpha]: Blacklisting usbhid module... Done!"
fi
