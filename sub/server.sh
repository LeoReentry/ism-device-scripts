#!/bin/bash

# Print some readable output to shell
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tInstall device server"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

# Server installation script

echo "-------- UPDATE REPOSITORIES FOR NODEJS --------" > $LOGPATH/server.log
echo -n "Updating repositories... "
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - >> $LOGPATH/server.log

echo "-------- INSTALL NODEJS --------" >> $LOGPATH/server.log
echo -ne "Done!\nInstalling Node.js... "
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install nodejs >> $LOGPATH/server.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during installation. See logfile server.log for details." 1>&2
  exit 1
fi

echo "-------- GIT CLONE --------" >> $LOGPATH/server.log
echo -ne "Done!\nDownloading server data... "
cd $HOMEVAR
git clone https://github.com/LeoReentry/ism-device-server.git >> $LOGPATH/server.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during cloning. See logfile server.log for details." 1>&2
  exit 1
fi

cd ism-device-server
echo "-------- NPM INSTALL --------" >> $LOGPATH/server.log
echo -ne "Done!\nInstalling packages... "
npm install >> $LOGPATH/server.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during package installation. See logfile server.log for details." 1>&2
  exit 1
fi

echo -e "Done!\nNow we need to create a certificate. This will take a while and you will have to answer some questions."
./gencert.sh

echo "Finally, we'll generate some random data for our session secret."
echo SESSION_SECRET=`openssl rand -base64 21` > .env

echo "We're going to add a service for the server to be running as daemon."
sudo cp $FILEPATH/ismserver.service /etc/systemd/system/
# Allow node to use ports lower than 1024 in user mode
sudo setcap 'cap_net_bind_service=+ep' $(readlink -f $(which node))
# Generate node daemon
sudo systemctl daemon-reload
sudo systemctl enable ismserver
echo "Okay, we're done."

# Finish
echo "server" > $LOGPATH/finished
