#!/bin/bash

# This script will install the cryptographic stuff used by the device

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tInstall cryptographic helpers"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

echo "-------- INSTALL CMAKE --------" > $LOGPATH/crypto.log
echo -n "Installing CMAKE... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install cmake >> $LOGPATH/crypto.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during installation. See logfile crypto.log for details." 1>&2
  exit 1
fi

echo "-------- GIT CLONE --------" >> $LOGPATH/crypto.log
echo -ne "Done!\nDownloading program data... "
cd $HOMEVAR
git clone https://github.com/LeoReentry/ism-device-crypto.git >> $LOGPATH/crypto.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during download. See logfile crypto.log for details." 1>&2
  exit 1
fi

echo "-------- CMAKE --------" >> $LOGPATH/crypto.log
echo -ne "Done!\nPreparing project... "
cd $HOMEVAR/ism-device-crypto
cmake ./ >> $LOGPATH/crypto.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during project generation. See logfile crypto.log for details." 1>&2
  exit 1
fi

echo "-------- MAKE --------" >> $LOGPATH/crypto.log
echo -ne "Done!\nCompiling project... "
sudo make >> $LOGPATH/crypto.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during installation. See logfile crypto.log for details." 1>&2
  exit 1
fi
echo -e "Done!\nWe have to reboot to talk to the TPM... "


# Add finish flag
echo "crypto" >> $LOGPATH/finished
# Make debian user owner of everything we just did so they can use it properly
cd $HOMEVAR
sudo chown -R debian:debian ism-device-crypto/
# Create symlink to executable
sudo ln -s -t /home/debian/bin $HOMEVAR/ism-device-crypto/deh
