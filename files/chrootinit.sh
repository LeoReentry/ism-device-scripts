#!/bin/bash

# START CHROOT CONFIGURATION

## INSTALL CROSS COMPILERRS
### Add crosstools repository
echo "deb http://emdebian.org/tools/debian/ jessie main" > /etc/apt/sources.list.d/crosstools.list
### Add key for repository
curl http://emdebian.org/tools/debian/emdebian-toolchain-archive.key | sudo apt-key add -
### Install crosstools
sudo dpkg --add-architecture armhf
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y crossbuild-essential-armhf

## COPY REPOISTORIES FROM BEAGLEBONE
sudo sh -c 'echo "deb http://httpredir.debian.org/debian/ jessie main contrib non-free
#deb-src http://httpredir.debian.org/debian/ jessie main contrib non-free

deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
#deb-src http://httpredir.debian.org/debian/ jessie-updates main contrib non-free

deb http://security.debian.org/ jessie/updates main contrib non-free
#deb-src http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list'

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y

## CONFIGURE CC-TOOLCHAIN
### Go to binaries
cd /usr/bin
### Link GCC, G++ and CPP to cross compilers
ln -fs arm-linux-gnueabihf-gcc gcc
ln -fs arm-linux-gnueabihf-g++ g++
ln -fs arm-linux-gnueabihf-cpp cpp

## HOMEDIR
mkdir /home/debian
cd /home/debian

## INSTALL TPM STUFF
sudo DEBIAN_FRONTEND=noninteractive apt-get install -ylibtspi-dev:armhf tpm-tools:armhf
## INSTALL DEVICE STUFF
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libboost-thread-dev:armhf libboost-atomic-dev:armhf libboost-chrono-dev:armhf libboost-random-dev:armhf libboost-regex-dev:armhf libboost-date-time-dev:armhf libboost-log-dev:armhf libboost-locale-dev:armhf libboost-filesystem-dev:armhf
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install libboost-system-dev:armhf libssl-dev:armhf uuid-dev:armhf libcurl4-openssl-dev:armhf libxml++2.6-dev:armhf libglibmm-2.4-dev:armhf
## PRUSSDRV
git clone https://github.com/beagleboard/am335x_pru_package.git
cp am335x_pru_package/pru_sw/app_loader/include/pruss* /usr/include/
cd am335x_pru_package/pru_sw/app_loader/interface/
CROSS_COMPILE= make
cd ../lib/
cp * /usr/lib/arm-linux-gnueabihf/
ldconfig
## uEye
## MAKE SURE THE SDK IS THERE
sshpass -p temppwd scp debian@bbb2:~/uEyeSDK-* /home/debian
cd /home/debian
tar xvf uEyeSDK-* -C /
