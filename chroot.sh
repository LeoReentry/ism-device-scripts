#!/bin/bash
if [[ $EUID -ne 0 ]]; then
    echo "You must be root to run this script"
    exit 1
fi

# ============================================================
# Set general path variables and settings
# ============================================================
SCRIPT=$(readlink -f "$0")
THISPATH=$(dirname "$SCRIPT")
LOGPATH="$THISPATH/log"
SCRIPTPATH="$THISPATH/sub"
FILEPATH="$THISPATH/files"

echo -n "Installing debootstrap. This will take a while... "
echo "-------- INSTALL SOFTWARE --------" > $LOGPATH/chroot.log
# Install Debootstrap
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install debootstrap >> $LOGPATH/chroot.log 2>&1
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during installation. See logfile chroot.log for details." 1>&2
  exit 1
fi

# Init debootstrap
echo -ne "Done!\nPreparing bootstrap... "
echo "-------- PREPARE DEBOOTSTRAP --------" >> $LOGPATH/chroot.log
sudo mkdir ${1:-/ARMHFchroot}
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured creating the directory ${1:-/ARMHFchroot}" 1>&2
  exit 1
fi

sudo debootstrap --verbose --include=aptitude,iputils-ping,module-init-tools,ifupdown,iproute,nano,wget,curl,ssh,sudo,udev,cmake,git,sshpass jessie ${1:-/ARMHFchroot} http://ftp.us.debian.org/debian >> $LOGPATH/chroot.log
if [ $? -ne 0 ]; then
  echo -e "\nAn error occured during chroot creation. See logfile chroot.log for details." 1>&2
  exit 1
fi

sudo cp $FILEPATH/chrootinit.sh ${1:-/ARMHFchroot}

echo -ne "Done!\nWe will now enter the changeroot and do some work there. Press ^c to cancel.\n"
sleep 5
echo "Entering changeroot."
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
# Chroot into new system
sudo chroot /${1:-/ARMHFchroot} /chrootinit.sh
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo "Done. Your changeroot is ready. Run"
echo "sudo chroot ${1:-/ARMHFchroot} /bin/bash"
echo "to enter chroot environment."
