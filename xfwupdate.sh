#!/bin/bash

# Change to firmware update directory
cd /home/debian/fwupdate
# Extract firmware update data
rm -rf /home/debian/.fwtmp
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
mkdir /home/debian/.fwtmp
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
tar -xf update.tar -C /home/debian/.fwtmp
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
rm -rf /home/debian/fwupdate
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
exit 0
