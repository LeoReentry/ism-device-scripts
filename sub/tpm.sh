#!/bin/bash

# TPM
sudo apt-get -q -y install libtspi-dev tpm-tools
cd /opt/scripts/tools/
sudo ./update_kernel.sh --bone-xenomai-channel --stable
sudo reboot
