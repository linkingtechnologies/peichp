#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <camila_base_dir> <appdir> <name> <value> <lang> [transfer_mode]"
    echo "Example for local: $0 /var/www camila_app name1 value1 en local"
    exit 1
}

# Verify minimum required parameters
if [ "$#" -lt 5 ]; then
    usage
fi

CAMILA_BASE_DIR=$1
APPDIR=$2
NAME=$3
VALUE=$4
LANG=$5
TRANSFER_MODE=${6:-local}  # Default to 'local' if not specified

INITIAL_DIR=$(pwd)

# Navigate to the app directory
cd "$CAMILA_BASE_DIR/app/$APPDIR" || { echo "Failed to enter application directory"; exit 1; }

echo "Changed directory to $(pwd)"

if [ -f "../../../php/php.exe" ]; then
    PHP_PATH="../../../php/php.exe"
elif [ -f "../../php/php.exe" ]; then
    PHP_PATH="../../php/php.exe"
elif [ -f "../../../nginx/php/php.exe" ]; then
    PHP_PATH="../../../nginx/php/php.exe"
else
    echo "php.exe not found."
    exit 1
fi

echo "php.exe found in: $PHP_PATH"

if $PHP_PATH cli.php set-config-var $NAME "$VALUE"; then
    echo "Application var set successfully."
else
    echo "Application var set failed."
    exit 1
fi

# Return to the initial directory
cd "$INITIAL_DIR" || exit 1

exit 0
