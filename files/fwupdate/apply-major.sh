#!/bin/bash

cd /home/debian
# Remove all non-hidden files
echo "------------ Removing old files -----------"
rm -rf *
cd .fwtmp
echo "----------- Extracting new files ----------"
tar -xzvf home.tgz -C /home/debian/
echo "------ Running user defined settings ------"
source settings.sh
