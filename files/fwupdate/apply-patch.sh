#!/bin/bash

cd /home/debian/ism-device-scripts
git pull -qf
cd cryptocape-init
git pull -qf
cd /home/debian/ism-device-server
git pull -qf

cp -f /home/debian/fwupdate/data/deh /home/debian/ism-device-crypto/
cp -f /home/debian/fwupdate/data/libdevicecrypto.so /home/debian/ism-device-crypto/
cp -f /home/debian/fwupdate/data/statetest /home/debian/ism-device/ismdevice-armhf/statetest
