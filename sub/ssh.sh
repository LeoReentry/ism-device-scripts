#!/bin/bash

echo -n "Removing all SSH keys... "
echo "-------- REMOVE SSH KEYS --------" >> $LOGPATH/ssh.log
# Remove all SSH Keys
sudo rm -rf /etc/ssh/ssh_host*
echo -ne "Done!\nRegenerating SSH keys... "
# Generate new RSA 4096 key
sudo ssh-keygen -b 4096 -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""
# Generate ED25519 key (256 bits)
sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""

echo -ne "Done!\n"
echo ssh >> $LOGPATH/finished
