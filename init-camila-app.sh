#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <camila_base_dir> <appdir> <lang> [transfer_mode]"
    echo "Example for local: $0 /var/www camila_app en local"
    exit 1
}

# Verify minimum required parameters
if [ "$#" -lt 3 ]; then
    usage
fi

CAMILA_BASE_DIR=$1
APPDIR=$2
LANG=$3
TRANSFER_MODE=${4:-local}  # Default to 'local' if not specified

INITIAL_DIR=$(pwd)

# Navigate to the app directory
cd "$CAMILA_BASE_DIR/app/$APPDIR" || { echo "Failed to enter application directory"; exit 1; }

echo "Changed directory to $(pwd)"

if grep -qi microsoft /proc/version 2>/dev/null; then
    echo "Environment detected: WSL"
    PHP_BASENAME="php.exe"

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
else

    echo "Environment detected: native Linux"
    PHP_BASENAME="php"

	if [ -f "../../../php/bin/php" ]; then
	    PHP_PATH="../../../php/bin/php"
	elif [ -f "../../php/bin/php" ]; then
	    PHP_PATH="../../php/bin/php"
	elif [ -f "../../../nginx/php/bin/php" ]; then
	    PHP_PATH="../../../nginx/php/bin/php"
	else
	    echo "php not found."
	    exit 1
	fi

fi

echo "php.exe found in: $PHP_PATH"

# Initialize the application

if $PHP_PATH cli.php init-app $LANG; then
    echo "Application initialization completed successfully."
else
    echo "Application initialization failed."
    exit 1
fi

# Return to the initial directory
cd "$INITIAL_DIR" || exit 1

exit 0
