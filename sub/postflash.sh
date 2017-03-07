#!/bin/bash

rm -rf $HOMEVAR/.deh/
# ============================================================
# Renew SSH keys
# ============================================================
if [ "$redo" = true ] || ! fgrep -q "ssh" "$LOGPATH/finished"; then
  source $SCRIPTPATH/ssh.sh
fi

# ============================================================
# Reset TPM
# ============================================================
if [ "$redo" = true ] || ! fgrep -q "cape-init" "$LOGPATH/finished"; then
  echo "-------- GIT CLONE cryptocape-init --------" >> $LOGPATH/crypto.log
  cd $THISPATH/cryptocape-init
  echo "Ok, we are now clearing the TPM, you might be asked for a password."
  echo -n "This process cannot be reverted. If you already own the TPM, you can cancel this. You might be asked this question again after reboot. Continue (y/n)? "
  read answer
  if [ $answer = "y" ];then
    source ./tpm_clear_own.sh
    owned=`cat /sys/class/misc/tpm0/device/owned`
    if [ $owned -eq 1 ]; then
      echo "cape-init" >> $LOGPATH/finished
      # Make user debian owner of init functions
      sudo chown debian:debian -R $HOMEVAR/ism-device-scripts/cryptocape-init
    fi
  fi
fi
