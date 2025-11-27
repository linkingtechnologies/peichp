#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <camila_base_dir> <appdir> <plugin> <lang> [transfer_mode]"
    echo "Example for local: $0 /var/www camila_app default en local"
    exit 1
}

# Verify required parameters
if [ "$#" -lt 4 ]; then
    usage
fi

CAMILA_BASE_DIR=$1
APPDIR=$2
PLUGIN=$3
LANG=$4
TRANSFER_MODE=${5:-local}  # Default to 'local' if not specified

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

$PHP_PATH cli.php init-plugin $PLUGIN $LANG
$PHP_PATH cli.php generate-plugin-docs $PLUGIN $LANG

# Return to the initial directory
cd "$INITIAL_DIR"

echo "Initialization completed successfully."
