#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <camila_base_dir> <appdir> <lang> <transfer_mode> [ftp_user] [ftp_password] [ftp_host]"
    echo "Example for local: $0 /var/www camila_app en local"
    echo "Example for FTP: $0 /remote/path camila_app en ftp user pass ftp.example.com"
    echo "Example for SFTP: $0 /remote/path camila_app en sftp user pass sftp.example.com"
    exit 1
}

# Verify minimum required parameters
if [ "$#" -lt 4 ]; then
    usage
fi

CAMILA_BASE_DIR=$1
APPDIR=$2
LANG=$3
TRANSFER_MODE=$4
FTP_USER=$5
FTP_PASS=$6
FTP_HOST=$7

INITIAL_DIR=$(pwd)

# Navigate to the app directory
cd "$CAMILA_BASE_DIR/app/$APPDIR" || { echo "Failed to enter application directory"; exit 1; }

# Initialize the application
if ../../../php/php.exe cli.php init-app $LANG; then
    echo "Application initialization completed successfully."
else
    echo "Application initialization failed."
    exit 1
fi

# Return to the initial directory
cd "$INITIAL_DIR" || exit 1

exit 0
