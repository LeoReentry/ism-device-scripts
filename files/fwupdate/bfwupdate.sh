#!/bin/bash

echo "--------- Firmware Update Builder ---------"
echo "Select an option: "
echo "[1] Patch. Patches binaries (statetest, deh, getsetting, libdevicecrypto) and updates repositories."
echo "[2] Minor version. Replaces libraries."
echo "[3] Major version. Replaces entire home folder and changes system settings."
echo -n "Please select an operation [1]: "
read answer
cd /home/debian
if [[ $answer -eq 1 ]]; then
  echo "Creating patch"
  tar --transform='flags=r;s|apply-patch|apply|' -cf patch.tar -C ismdevice-armhf statetest -C ../ism-device-crypto deh libdevicecrypto.so -C ../ism-device-scripts/files/fwupdate apply-patch.sh
  echo "Created file patch.tar"
elif [[ $answer -eq 2 ]]; then
  echo "Compressing home folder..."
  # Create compressed tarball of all non hidden files and folders
  tar -czf home.tgz *
  echo "Creating archive..."
  # Create tar of that and apply script
  tar --transform='flags=r;s|apply-minor|apply|' -cf minor.tar home.tgz -C ism-device-scripts/files/fwupdate apply-minor.sh
  echo "Created file minor.tar"
elif [[ $answer -eq 3 ]]; then
  echo "Compressing home folder..."
  # Create compressed tarball of all non hidden files and folders
  tar -czf home.tgz *
  echo "Please place a settings script called settings.sh in /home/debian... Done? "
  read t
  chmod +x /home/debian/settings.sh
  tar --transform='flags=r;s|apply-minor|apply|' -cf major.tar home.tgz -C ism-device-scripts/files/fwupdate apply-major.sh -C /home/debian settings.sh
else
  echo "Please specify an answer. Allowed values are 1-3."
fi
