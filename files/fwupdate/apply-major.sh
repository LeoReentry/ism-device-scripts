#!/bin/bash

cd /home/debian
# Remove all non-hidden files
rm -rf *
cd .fwtmp
tar -xzf home.tgz -C /home/debian/
source settings.sh
