#!/bin/bash

# Install GCC 6
# Print some readable output to shell
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tUpdate GCC and G++"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =


echo -n "Add Debian testing... "
sudo sh -c "echo 'deb http://ftp.us.debian.org/debian testing main contrib non-free' >> /etc/apt/sources.list"
sudo sh -c 'echo "Package: *
Pin: release a=testing
Pin-Priority: 100" >> /etc/apt/preferences'

echo -ne "Done!\nThe following operations may take some time to finish. Please don't cancel the script.\nUpdating repositories... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q update > /dev/null
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during repository update. See logfile gcc.log for details." 1>&2
  exit 1
fi


echo "-------- INSTALL GCC --------" > $LOGPATH/gcc.log
echo -ne "Done!\nInstalling GCC... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install -t testing gcc >> $LOGPATH/gcc.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during installtion. See logfile gcc.log for details." 1>&2
  exit 1
fi

echo "-------- INSTALL G++ --------" >> $LOGPATH/gcc.log
echo -ne "Done!\nInstalling G++... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install -t testing g++ >> $LOGPATH/gcc.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during installtion. See logfile gcc.log for details." 1>&2
  exit 1
fi
echo  "Done!"

# Finish
echo "gcc" >> $LOGPATH/finished
