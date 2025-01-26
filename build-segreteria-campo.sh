#!/bin/bash

# Set security options to stop the script in case of an error
set -e

# Check if required commands are installed
REQUIRED_COMMANDS=("wget" "unzip" "sed" "jq" "git" "lftp" "sshpass" "sftp" "zip")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed."
    echo "If you are using WSL (Ubuntu/Debian), install it by running:"
    echo "  sudo apt update && sudo apt install -y $cmd"
    exit 1
  fi
done


# Variable definitions
PHP_VERSION="8.3.16"
BUILD_PATH="build/html"
TEMPLATE_NAME="worktable-sqlite-it"
APP_NAME="segreteriacampo"
PLUGIN_NAME="segreteria-campo"
LOCALE="it"
ENVIRONMENT="local"
ZIP_FILE="${PLUGIN_NAME}-$(date +%Y-%m-%d).zip"

# Execute the required commands
echo "Building local PHP server..."
./build-win-local-php-server.sh $PHP_VERSION

echo "Installing Camila Framework..."
./install-camila-framework.sh $BUILD_PATH $ENVIRONMENT

echo "Installing Camila App..."
./install-camila-app.sh $BUILD_PATH $APP_NAME $TEMPLATE_NAME $ENVIRONMENT

echo "Installing Camila App Plugin..."
./install-camila-app-plugin.sh $BUILD_PATH $APP_NAME $PLUGIN_NAME $ENVIRONMENT

echo "Initializing Camila App..."
./init-camila-app.sh $BUILD_PATH $APP_NAME $LOCALE $ENVIRONMENT

echo "Initializing Camila App Plugin..."
./init-camila-app-plugin.sh $BUILD_PATH $APP_NAME $PLUGIN_NAME $LOCALE $ENVIRONMENT


echo "Creating ZIP archive: $ZIP_FILE"
if zip -r "$ZIP_FILE" build/; then
    echo "✅ Archive created successfully: $ZIP_FILE"
else
    echo "❌ Failed to create archive." >&2
    exit 1
fi
# Completion message
echo "All tasks completed successfully!"