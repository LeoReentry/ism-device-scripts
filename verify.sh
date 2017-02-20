#!/bin/bash

# Change to home directory
cd /home/debian
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
# Empty fwupdate directory
rm -rf fwupdate
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
mkdir fwupdate
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
# Extract fwupdate.tar.gz to fwupdate/
mv fwupdate.tar.gz fwupdate
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
cd fwupdate
tar -xzf fwupdate.tar.gz
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
rm -f fwupdate.tar.gz
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
# Calculate checksum and save it as byte file
sha256sum update.tar | awk '{print $1}' | perl -ne 's/([0-9a-f]{2})/print chr hex $1/gie' > sha256sum
if [ $? -ne 0 ]; then
  echo "Error"
  exit 1
fi
# If no public key file is present, get a public key file
if [ ! -f /home/debian/.ismdata/public.pem ]; then
  wget $(getsetting publicKeyUrl) -O /home/debian/.ismdata/public.pem
  if [ $? -ne 0 ]; then
    rm public.pem
    exit 1
  fi
fi
# Verify signature
openssl pkeyutl -verify -in sha256sum -pubin -inkey /home/debian/.ismdata/public.pem -sigfile sig -pkeyopt digest:sha256
if [ $? -eq 0 ]; then
  exit 0
fi
exit 1
