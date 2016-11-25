#!/bin/bash

# TPM

# Print some readable output to shell
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tInstall TPM"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

# Install tpm tools and TSPI library
echo -n "Installing TPM library... "
echo "-------- INSTALL TPM TOOLS AND TSPI LIBRARY --------" > $LOGPATH/tpm.log
sudo apt-get -q -y install libtspi-dev tpm-tools >> $LOGPATH/tpm.log
echo "tpm" >> $LOGPATH/reboot.log
echo "Done!"
