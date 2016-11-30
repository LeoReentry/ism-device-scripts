#!/bin/bash

# This script will install the cryptographic stuff used by the device

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tInstall cryptographic helpers"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

echo "-------- INSTALL CMAKE --------" > $LOGPATH/crypto.log
echo -n "Installing CMAKE..."
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install cmake >> $LOGPATH/crypto.log 2>&1

echo "-------- GIT CLONE --------" >> $LOGPATH/crypto.log
echo -ne "Done!\nDownloading program data..."
cd ~
git clone https://github.com/LeoReentry/ism-device-crypto.git >> $LOGPATH/crypto.log 2>&1

echo "-------- CMAKE --------" >> $LOGPATH/crypto.log
echo -ne "Done!\nPreparing project..."
cd ~/ism-device-crypto
cmake ./ >> $LOGPATH/crypto.log 2>&1

echo "-------- MAKE --------" >> $LOGPATH/crypto.log
echo -ne "Done!\nCompiling project..."
make ./>> $LOGPATH/crypto.log 2>&1
echo -e "Done!\nRebooting..."

# Create alias for the encryption helper
echo "alias deh=~/ism-device-crypto/deh" >> ~/.bash_aliases
# .bash_aliases is already loaded in .bashrc
# We just need to reload the data
source ~/.bash_aliases

# Add finish flag
echo "crypto" >> $LOGPATH/finished
# Reboot
sudo reboot
