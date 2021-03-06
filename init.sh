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
LOGPATH="/home/debian/.ismdata/initlogs"
SCRIPTPATH="$THISPATH/sub"
FILEPATH="$THISPATH/files"

# Add home variable manually because sudo changes it to /root
HOMEVAR=/home/debian

# Create folder for logfiles
if [ ! -d "$LOGPATH" ]; then
  mkdir -p $LOGPATH
fi

# Set path variables as environment variables
export LOGPATH
export SCRIPTPATH
export HOMEVAR
# Disable HDMI but enable eMMC overlay
# sudo sed -i 's/#dtb=am335x-boneblack-emmc-overlay.dtb/dtb=am335x-boneblack-emmc-overlay.dtb/gi' /boot/uEnv.txt

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tUpdate Repositories"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y update >> $LOGPATH/update.log 2>&1
# ============================================================
# Downgrade Kernel to 3.8
# ============================================================
# If kernel isn't version 3.8.X, we'll have to update it
uname -r | grep -qP "3\.8\.\d{1,}-[\w\d]{1,}"
# If we don't have the desired Kernel version, we'll install it
if [ $? -eq  1 ] && ! fgrep -q "kernel" "$LOGPATH/finished"; then
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
# Install Device Encryption Helper
# ============================================================
if ! fgrep -q "crypto" "$LOGPATH/finished"; then
  # Install crypto stuff
  source $SCRIPTPATH/crypto.sh
fi

# ============================================================
# Install Device Software
# ============================================================
if ! fgrep -q "device" "$LOGPATH/finished"; then
  # Install crypto stuff
  source $SCRIPTPATH/device.sh
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
  # Install device server
  source $SCRIPTPATH/server.sh
fi

# ============================================================
# Configure SSH server
# ============================================================
if ! fgrep -q "sshconfig" "$LOGPATH/finished"; then
  # Configure ssh
  source $SCRIPTPATH/sshconfig.sh
fi

# ============================================================
# Enable unattended Upgrades
# ============================================================
if ! fgrep -q "unattended" "$LOGPATH/finished"; then
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
  echo -e "\t\tEnable automatic updates"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

  echo -n "Install package... "
  # Enable unattended Upgrades
  sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install unattended-upgrades > $LOGPATH/unattended.log 2>&1
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during installation. See logfile unattended.log for details." 1>&2
    exit 1
  fi
  echo -ne "Done!\nConfiguring... "
  sudo dpkg-reconfigure -plow unattended-upgrades
  echo "Done!"
  echo "unattended" >> $LOGPATH/finished
fi

# ============================================================
# openSSL must be from testing
# ============================================================
if ! fgrep -q "openssl" "$LOGPATH/finished"; then
  echo -n "Installing latest version of openssl... "
  echo "deb http://httpredir.debian.org/debian testing main contrib non-free" >> /etc/apt/sources.list
  echo "Package: *
Pin: release a=testing
Pin-Priority: 100

Package: openssl
Pin: release a=testing
Pin-Priority: 900
  " > /etc/apt/preferences
  sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y update > $LOGPATH/openssl.log 2>&1
  sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install openssl >> $LOGPATH/openssl.log 2>&1
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during installation of openSSL. See logfile openssl.log for details." 1>&2
    exit 1
  fi
  echo -e "Done!"
  echo "openssl" >> $LOGPATH/finished
fi

# ============================================================
# Reboot
# ============================================================
if ! fgrep -q "reboot" "$LOGPATH/finished"; then
  # Make standard user owner of everything
  sudo chown 1000:1000 -R $HOMEVAR
  # Generate symlinks to executables
  sudo ln -s -t /home/debian/bin $FILEPATH/getsetting
  sudo ln -s -t /home/debian/bin $FILEPATH/setsetting
  sudo ln -s -t /home/debian/bin $FILEPATH/fwupdate/build-firmware-update
  # Clean up
  rm -f $HOMEVAR/lib.tar
  rm -f $HOMEVAR/uEyeSDK-*
  cd $HOMEVAR

  # Disable USB mass storage
  sudo sh -c "echo 'install usb-storage /bin/true' > /etc/modprobe.d/usb-storage.conf"
  # Disable USB HIDs and Storage in blacklist
  sudo sh -c "echo 'blacklist usbhid' > /etc/modprobe.d/blacklist.conf"
  sudo sh -c "echo 'blacklist usb-storage' >> /etc/modprobe.d/blacklist.conf"
  # Regenerate initramfs
  update-initramfs -u -k $(uname -r)

  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
  echo -e "\t\tREBOOT"
  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
  echo "We'll reboot now. Please wait a while, we'll be back shortly."
  # Reboot before talking to TPM
  echo "reboot" >> $LOGPATH/finished
  sudo shutdown -r now & exit & exit
fi


# ============================================================
# Reset TPM and renew SSH keys
# ============================================================
source $SCRIPTPATH/postflash.sh
