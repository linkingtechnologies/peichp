#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <camila_base_dir> <appdir> <name> <value> <lang> <transfer_mode> [ftp_user] [ftp_password] [ftp_host]"
    echo "Example for local: $0 /var/www camila_app name1 value1 en local"
    echo "Example for FTP: $0 /remote/path camila_app name1 value1 en ftp user pass ftp.example.com"
    echo "Example for SFTP: $0 /remote/path camila_app name1 value1 en sftp user pass sftp.example.com"
    exit 1
}

# Verify minimum required parameters
if [ "$#" -lt 6 ]; then
    usage
fi

CAMILA_BASE_DIR=$1
APPDIR=$2
NAME=$3
VALUE=$4
LANG=$5
TRANSFER_MODE=$6
FTP_USER=$7
FTP_PASS=$8
FTP_HOST=$9

INITIAL_DIR=$(pwd)

# Navigate to the app directory
cd "$CAMILA_BASE_DIR/app/$APPDIR" || { echo "Failed to enter application directory"; exit 1; }

if ../../../php/php.exe cli.php set-config-var $NAME "$VALUE"; then
    echo "Application var set successfully."
else
    echo "Application var set failed."
    exit 1
fi

# Return to the initial directory
cd "$INITIAL_DIR" || exit 1

exit 0
