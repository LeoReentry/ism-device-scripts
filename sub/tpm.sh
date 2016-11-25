#!/bin/bash

# TPM
# Install tpm tools and TSPI library
echo "---- Install TPM ----"
echo -n "Installing TPM library... "
echo "-------- INSTALL TPM TOOLS AND TSPI LIBRARY --------" > $LOGPATH/tpm.log
sudo apt-get -q -y install libtspi-dev tpm-tools >> $LOGPATH/tpm.log
echo "tpm" >> $LOGPATH/reboot.log
echo "Done!"
