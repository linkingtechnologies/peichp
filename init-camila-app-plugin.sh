#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <camila_base_dir> <appdir> <plugin> <lang> <transfer_mode> [ftp_user] [ftp_password] [ftp_host]"
    echo "Example for local: $0 /var/www camila_app default en local"
    echo "Example for FTP: $0 /remote/path camila_app default en ftp user pass ftp.example.com"
    echo "Example for SFTP: $0 /remote/path camila_app custom en sftp user pass sftp.example.com"
    exit 1
}

# Verify required parameters
if [ "$#" -lt 5 ]; then
    usage
fi

CAMILA_BASE_DIR=$1
APPDIR=$2
PLUGIN=$3
LANG=$4
TRANSFER_MODE=$5
FTP_USER=$6
FTP_PASS=$7
FTP_HOST=$8

# Full application destination path: <camila_base_dir>/app/<appdir>/plugins/$PLUGIN
DESTINATION="$CAMILA_BASE_DIR/app/$APPDIR/plugins/$PLUGIN"

# Ensure camila_base_dir and app directory exist
if [ ! -d "$CAMILA_BASE_DIR/app/$APPDIR/plugins/$PLUGIN" ]; then
    echo "Creating plugin directory: $DESTINATION"
    mkdir -p "$DESTINATION" || { echo "Failed to create plugin directory"; exit 1; }
fi

# Store the initial directory
INITIAL_DIR=$(pwd)

cd $CAMILA_BASE_DIR/app/$APPDIR

../../../php/php.exe cli.php init-plugin $PLUGIN $LANG
../../../php/php.exe cli.php generate-plugin-docs $PLUGIN $LANG

# Return to the initial directory
cd "$INITIAL_DIR"

echo "Initialization completed successfully."
