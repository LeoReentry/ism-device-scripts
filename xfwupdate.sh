#!/bin/bash

# Change to firmware update directory
cd /home/debian/fwupdate
# Extract firmware update data
mkdir /home/debian/.fwtmp
tar -xf update.tar -C /home/debian/.fwtmp
rm -rf /home/debian/fwupdate
