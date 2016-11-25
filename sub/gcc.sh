#!/bin/bash

# Install GCC 6
echo "---- Update GCC and G++ ----"
echo -n "Add Debian testing... "
sudo sh -c "echo 'deb http://ftp.us.debian.org/debian testing main contrib non-free' >> /etc/apt/sources.list"
sudo sh -c 'echo "Package: *
Pin: release a=testing
Pin-Priority: 100" >> /etc/apt/preferences'
echo -ne "Done!\nUpdate repositories... "
sudo apt-get -q update > /dev/null
# Log
echo "-------- INSTALL GCC AND G++ --------" > $LOGPATH/gcc.log
echo -ne "Done!\nInstalling GCC... "
sudo apt-get -q -y install -t testing gcc >> $LOGPATH/gcc.log
echo -ne "Done!\nInstalling G++... "
sudo apt-get -q -y install -t testing g++ >> $LOGPATH/gcc.log
echo "Done!"
# Reboot
echo "gcc" >> $LOGPATH/reboot.log
sudo reboot
