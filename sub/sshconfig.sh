#!/bin/bash

# Print some readable output to shell
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tConfigure SSH server"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

echo -n "Installing extra stuff... "
echo "-------- INSTALL COWSAY FORTUNE --------" > $LOGPATH/sshconfig.log
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install cowsay fortune >> $LOGPATH/sshconfig.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during installation. See logfile sshconfig.log for details." 1>&2
  exit 1
fi

echo "-------- UPDATE SSH PAM --------" >> $LOGPATH/sshconfig.log
echo -ne "Done!\nGenerating dynamic Message of the Day... "
# Update PAM file
sudo rm -f /etc/pam.d/sshd
sudo cp $FILEPATH/sshd /etc/pam.d
# Update SSH config file
sudo rm -f /etc/ssh/sshd_config
sudo cp $FILEPATH/sshd_config /etc/ssh
# Remove currently existing greetings
sudo rm -rf /etc/update-motd.d
sudo cp -r $FILEPATH/update-motd.d /etc/
# Remove static MOTD
sudo rm /etc/motd
sudo echo "" | sudo dd of=/run/motd
sudo ln -s -t /etc /run/motd
# Remove banner
# Use dd because we cannot sudo a redirect operator
echo "" | sudo dd of=/etc/issue.net

echo -ne "Done!\nRestarting SSH server... "
sudo systemctl restart sshd.service
echo "Done!"

echo sshconfig >> $LOGPATH/finished
