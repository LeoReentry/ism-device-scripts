#!/bin/bash

# Give the process 5 seconds to exit
sleep 5
# If there still is a process staetest, kill with SIGKILL
while ps -fC statetest; do
  kill -9 `pidof statetest`

cd /home/debian
# Remove all non-hidden files
echo "------------ Removing old files -----------"
rm -rf *
cd .fwtmp
echo "----------- Extracting new files ----------"
tar -xzf home.tgz -C /home/debian/
echo "------ Running user defined settings ------"
source settings.sh
echo "----------------------------------------------------"
echo "------ Firmware Update completed successfully ------"
sudo reboot now
