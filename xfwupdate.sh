#!/bin/bash

# Change to firmware update directory
cd /home/debian/fwupdate
# Extract firmware update data
rm -rf /home/debian/.fwtmp
mkdir /home/debian/.fwtmp
tar -xf update.tar -C /home/debian/.fwtmp
rm -rf /home/debian/fwupdate
