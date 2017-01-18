#!/bin/bash

# Print some readable output to shell
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tInstall device software"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
# This script will install the device software

echo "-------- INSTALL DEPENDENCIES --------" > $LOGPATH/device.log
echo -n "Installing Dependencies... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install libboost-all-dev libssl-dev uuid-dev libcurl4-openssl-dev libxml++2.6-dev libglibmm-2.4-dev >> $LOGPATH/device.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during installation. See logfile device.log for details." 1>&2
  exit 1
fi

echo "-------- GIT CLONE --------" >> $LOGPATH/device.log
echo -ne "Done!\nDownloading program data... "
git clone https://github.com/c-armbrust/ismdevice-armhf >> $LOGPATH/device.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during downloading. See logfile device.log for details." 1>&2
  exit 1
fi

echo "-------- INSTALL UEYE SDK --------" >> $LOGPATH/device.log
echo -ne "Done!\nInstalling uEyeSDK... "
if [ -f $HOMEVAR/uEyeSDK-4.8* ] && ! fgrep -q "ueye" "/etc/modules"; then
  # Unpack archive
  cd $HOMEVAR
  sudo tar -xzf uEyeSDK*.tar -C / >> $LOGPATH/device.log 2>&1
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during unpacking. See logfile device.log for details." 1>&2
    exit 1
  fi
  # Setup SDK
  sudo /usr/local/share/ueye/bin/ueyesdk-setup.sh >> $LOGPATH/device.log 2>&1
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during setup. See logfile device.log for details." 1>&2
    exit 1
  fi
  # Start USB daemon
  sudo /etc/init.d/ueyeusbdrc start
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during daemon startup. See logfile device.log for details." 1>&2
    exit 1
  fi
  echo "ueye" >> $LOGPATH/finished
else
  echo -e "Error!\nPlease copy the uEye SDK tarfile to $HOME"
  exit 1
fi


cd $HOMEVAR/ismdevice-armhf
echo "-------- CMAKE --------" >> $LOGPATH/device.log
echo -ne "Done!\Preparing compiler... "
sudo cmake ./ >> $LOGPATH/device.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during cmake execution. See logfile device.log for details.\nPlease make sure all shared libraries are in the lib folder." 1>&2
  exit 1
fi

echo "-------- MAKE --------" >> $LOGPATH/device.log
echo -ne "Done!\nCompiling project... "
sudo make >> $LOGPATH/device.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during compilation. See logfile device.log for details.\nPlease make sure all shared libraries are in the lib folder." 1>&2
  exit 1
fi

# Create symlink to library and header file
ln -s -t $HOMEVAR/ismdevice-armhf/lib/ $HOMEVAR/ism-device-crypto/libdevicecrypto.so
ln -s -t $HOMEVAR/ismdevice-armhf/inc/ $HOMEVAR/ism-device-crypto/crypto.h

echo "device" >> finished
