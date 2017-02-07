#!/bin/bash

# Change to firmware update directory
cd /home/debian/fwupdate
# Extract firmware update data
mkdir data
tar -xf update.tar -C data
cd data
