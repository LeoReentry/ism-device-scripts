#!/bin/bash
# ============================================================
# ============================================================
# This script should be used when the BeagleBone has been
# with one of the provided Snapshots
# ============================================================
# ============================================================

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

# Add home variable manually because sudo changes it to /root
HOMEVAR=/home/debian

# Set redo to true to indicate every step should be done even
# though it's already been logged as completed
redo=true

source $SCRIPTPATH/postflash.sh
