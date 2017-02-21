#!/bin/bash

# Get current version and the version we're updating to
version=`getsetting softwareversion`
updateto=`cat /home/debian/.fwtmp/sw-version`
re='^([[:alnum:]]+)-r([0-9]+)(-([[:alnum:]]+))?$'
# Match prefix, suffix and release number of current version
if [[ $version =~ $re ]]; then
  version_prefix="${BASH_REMATCH[1]}"
  version_suffix="${BASH_REMATCH[4]}"
  version_release="${BASH_REMATCH[2]}"
else
  echo "Error. Firmware version doesn't match firmware version format."
  exit 1
fi
# Match prefix, suffix and release number of version we're updating to
if [[ $updateto =~ $re ]]; then
  updateto_prefix="${BASH_REMATCH[1]}"
  updateto_suffix="${BASH_REMATCH[4]}"
  updateto_release="${BASH_REMATCH[2]}"
else
  echo "Error. Firmware version doesn't match firmware version format."
  exit 1
fi

# If version suffix and prefix are equal, just update the release numbers
# Otherwise, update all the versions
if [[ "$version_prefix" = "$updateto_prefix" && "$version_suffix" = "$updateto_suffix" ]]; then
  start_release=$version_release
else
  start_release=0
fi

end_release=$updateto_release

if [ $start_release -ge $updateto_release ];then
  echo "No settings to be updated. Release version we're updating to lower than release version installed..."
  exit 1
fi
((start_release=start_release+1))
for i in $(seq $start_release $updateto_release); do
  script_name="$updateto_prefix-r$i"$([ "$updateto_suffix" != "" ] && echo "-$updateto_suffix")".sh"
  source /home/debian/ism-device-scripts/fw-settings-scripts/$script_name
done
