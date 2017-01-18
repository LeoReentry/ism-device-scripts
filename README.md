# Device script collection
This repository has a couple of scripts for device configuration and startup as well as some other stuff that might be helpful.

All scripts must be run as root.

Clone this script with the --recursive option.
```shell
git clone --recursive https://github.com/LeoReentry/ism-device-scripts.git
```

# Device Initialization
To initialize a fresh Debian Installation, run
```shell
cd ism-device-scripts
./init.sh
```

# Device Preparation
If you used an image file, just update some data
```shell
cd ism-device-scripts
./prepare.sh
```

# Prepare Development Chroot
To prepare a chroot for development, run
```shell
cd ism-device-scripts
./prepare.sh
```
This will create a chroot in /ARMHFchroot, if you wish to use a different directory, pass it as a parameter
```shell
./prepare.sh /DifferentChrootDirectory
```
