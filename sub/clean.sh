#!/bin/bash

# This script will do some clean up

printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tCleanup"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

echo "-------- REMOVE APACHE2 --------" > $LOGPATH/clean.log
echo -n "Removing Apache2... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y purge apache2 apache2-utils apache2-data apache2-bin >> $LOGPATH/clean.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during removing. See logfile clean.log for details." 1>&2
  exit 1
fi

echo "-------- REMOVE X11 --------" >> $LOGPATH/clean.log
echo -ne "Done!\nRemoving X Window System... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y purge libx11-6 >> $LOGPATH/clean.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during removing. See logfile clean.log for details." 1>&2
  exit 1
fi

echo "-------- REMOVE AVAHI --------" >> $LOGPATH/clean.log
echo -ne "Done!\nRemoving Avahi... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y purge avahi-daemon >> $LOGPATH/clean.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during removing. See logfile clean.log for details." 1>&2
  exit 1
fi

echo "-------- AUTOREMOVE --------" >> $LOGPATH/clean.log
echo -ne "Done!\nRemoving unused packages... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove --purge >> $LOGPATH/clean.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during removing. See logfile clean.log for details." 1>&2
  exit 1
fi

echo "-------- REMOVE CLOUD9 --------" >> $LOGPATH/clean.log
echo -ne "Done!\nRemoving Cloud9... "
sudo systemctl stop cloud9.service >> $LOGPATH/clean.log 2>&1            #stop working copy
sudo systemctl stop cloud9.socket >> $LOGPATH/clean.log 2>&1             #stop working copy
sudo systemctl disable cloud9.service >> $LOGPATH/clean.log 2>&1         #disable autorun
sudo systemctl disable cloud9.socket >> $LOGPATH/clean.log 2>&1          #disable autorun
sudo rm -rf /var/lib/cloud9 >> $LOGPATH/clean.log 2>&1                   #installed binaries and such
sudo rm -rf /opt/cloud9 >> $LOGPATH/clean.log 2>&1                       #source download and build directory
sudo rm /etc/default/cloud9 >> $LOGPATH/clean.log 2>&1                   #environment variables
sudo rm /lib/systemd/system/cloud9.* >> $LOGPATH/clean.log 2>&1          #systemd scripts
sudo systemctl daemon-reload >> $LOGPATH/clean.log 2>&1                  #restart/reload systemctl deamon
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y purge c9-core-installer >> $LOGPATH/clean.log 2>&1

echo "-------- REMOVE BONESCRIPT --------" >> $LOGPATH/clean.log
echo -ne "Done!\nRemoving Bonescript... "
sudo systemctl stop bonescript-autorun.service >> $LOGPATH/clean.log 2>&1          #stop currently running copy
sudo systemctl stop bonescript.service >> $LOGPATH/clean.log 2>&1
sudo systemctl stop bonescript.socket >> $LOGPATH/clean.log 2>&1
sudo systemctl disable bonescript-autorun.service >> $LOGPATH/clean.log 2>&1       #purge autorun scripts
sudo systemctl disable bonescript.service >> $LOGPATH/clean.log 2>&1
sudo systemctl disable bonescript.socket >> $LOGPATH/clean.log 2>&1
sudo rm /lib/systemd/system/bonescript* >> $LOGPATH/clean.log 2>&1                 #startup scripts
sudo rm -rf /usr/local/lib/node_modules/bonescript >> $LOGPATH/clean.log 2>&1      #binaries
sudo systemctl daemon-reload >> $LOGPATH/clean.log 2>&1                            #restart/reload systemctl deamon
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y purge bonescript >> $LOGPATH/clean.log 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y purge bone101 >> $LOGPATH/clean.log 2>&1


echo "-------- REMOVE NODE-RED --------" >> $LOGPATH/clean.log
echo -ne "Done!\nRemoving Node-RED... "
sudo systemctl stop node-red.service >> $LOGPATH/clean.log 2>&1
sudo systemctl stop node-red.socket >> $LOGPATH/clean.log 2>&1
sudo systemctl disable node-red.service >> $LOGPATH/clean.log 2>&1
sudo systemctl disable node-red.socket >> $LOGPATH/clean.log 2>&1
sudo npm remove -g node-red >> $LOGPATH/clean.log 2>&1
sudo systemctl daemon-reload >> $LOGPATH/clean.log 2>&1
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y purge bb-node-red-installer >> $LOGPATH/clean.log 2>&1

echo -e "Done!\nCleanup finished!"
echo "clean" >> $LOGPATH/finished
