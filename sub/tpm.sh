#!/bin/bash

# TPM

# Print some readable output to shell
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =
echo -e "\t\tInstall TPM"
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' =

# Install tpm tools and TSPI library
echo -n "Installing TPM library. This may take a while... "
echo "-------- INSTALL TPM TOOLS AND TSPI LIBRARY --------" > $LOGPATH/tpm.log
sudo DEBIAN_FRONTEND=noninteractive apt-get -q -y install libtspi-dev tpm-tools >> $LOGPATH/tpm.log
echo "tpm" >> $LOGPATH/reboot.log
echo "Done!"
