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

cd $HOMEVAR

if ! fgrep -q "devcode" "$LOGPATH/finished"; then
  echo "-------- GIT CLONE --------" >> $LOGPATH/device.log
  echo -ne "Done!\nDownloading program data... "
  git clone https://github.com/c-armbrust/ismdevice-armhf >> $LOGPATH/device.log 2>&1
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during downloading. See logfile device.log for details." 1>&2
    exit 1
  fi

  echo "-------- WGET LIBRARIES --------" >> $LOGPATH/device.log
  echo -ne "Done!\nDownloading program libraries... "
  wget -a $LOGPATH/device.log -nv https://ismportalstorage.blob.core.windows.net/setupdata/lib.tar -O $HOMEVAR/lib.tar
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during downloading. See logfile device.log for details." 1>&2
    rm $HOMEVAR/lib.tar
    rm -rf $HOMEVAR/ismdevice-armhf
    exit 1
  fi
  echo -ne "Done!\nExtracting libraries... "
  tar -xf $HOMEVAR/lib.tar -C $HOMEVAR/ismdevice-armhf
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during extraction. See logfile device.log for details." 1>&2
    rm $HOMEVAR/lib.tar
    rm -rf $HOMEVAR/ismdevice-armhf
    exit 1
  fi
  echo "devcode" >> $LOGPATH/finished
fi



if ! fgrep -q "ueye" "/etc/modules" && ! fgrep -q "ueye" "$LOGPATH/finished"; then
  echo "-------- INSTALL UEYE SDK --------" >> $LOGPATH/device.log
  echo -ne "Done!\Downloading uEyeSDK... "
  cd $HOMEVAR
  wget -a $LOGPATH/device.log -nv https://ismportalstorage.blob.core.windows.net/setupdata/uEyeSDK-4.80.00-ARM-LINUX-IDS-GNUEABI-HF.tgz
  if [ $? -ne 0 ]; then
    echo -e "\nAn error occured during downloading. See logfile device.log for details." 1>&2
    rm $HOMEVAR/uEyeSDK-4.80.00-ARM-LINUX-IDS-GNUEABI-HF.tgz
    exit 1
  fi

  echo -ne "Done!\nInstalling uEyeSDK... \n"
  # Unpack archive
  cd $HOMEVAR
  sudo tar -xzf uEyeSDK-4.8*.tgz -C / >> $LOGPATH/device.log 2>&1
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
  echo -e "Error!\nPlease copy the uEye SDK tarfile to $HOMEVAR"
  exit 1
fi


cd $HOMEVAR/ismdevice-armhf
echo "-------- CMAKE --------" >> $LOGPATH/device.log
echo -ne "Done!\nPreparing compiler... "
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
echo "Done!"
# Create symlink to library and header file
ln -s -t $HOMEVAR/ismdevice-armhf/lib/ $HOMEVAR/ism-device-crypto/libdevicecrypto.so
ln -s -t $HOMEVAR/ismdevice-armhf/inc/ $HOMEVAR/ism-device-crypto/crypto.h
# Create symlink to executable
ln -s -t /home/debian/bin $HOMEVAR/ismdevice-armhf/statetest

echo "device" >> finished
