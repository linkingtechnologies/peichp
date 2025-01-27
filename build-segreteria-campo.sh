#!/bin/bash

# Set security options to stop the script in case of an error
set -e

# Function to check required commands
check_commands() {
    local missing=0
    REQUIRED_COMMANDS=("wget" "unzip" "sed" "jq" "git" "lftp" "sshpass" "sftp" "zip" "tar")

    echo "Checking required commands..."
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "❌ Error: Required command '$cmd' is not installed."
            missing=1
        fi
    done

    if [ $missing -eq 1 ]; then
        echo "Please install the missing commands and retry."
        exit 1
    fi

    echo "✅ All required commands are installed."
}

# Run the command check before proceeding
check_commands

# Variable definitions
PHP_VERSION="8.3.16"
BUILD_HTML_PATH="build/html"
BUILD_PHP_PATH="build/php"
TEMPLATE_NAME="worktable-sqlite-it"
APP_NAME="segreteriacampo"
PLUGIN_NAME="segreteria-campo"
LOCALE="it"
ENVIRONMENT="local"
ZIP_FILE="${PLUGIN_NAME}-$(date +%Y-%m-%d).zip"

# Execute the required commands
echo "Building local PHP server..."
./build-win-local-php-server.sh $PHP_VERSION $LOCALE

echo "Cleaning up PHP build..."
./php-cleanup.sh $BUILD_PHP_PATH

echo "Installing Camila Framework..."
./install-camila-framework.sh $BUILD_HTML_PATH $ENVIRONMENT

echo "Installing Camila App..."
./install-camila-app.sh $BUILD_HTML_PATH $APP_NAME $TEMPLATE_NAME $ENVIRONMENT

echo "Installing Camila App Plugin..."
./install-camila-app-plugin.sh $BUILD_HTML_PATH $APP_NAME $PLUGIN_NAME $ENVIRONMENT

echo "Initializing Camila App..."
./init-camila-app.sh $BUILD_HTML_PATH $APP_NAME $LOCALE $ENVIRONMENT

echo "Initializing Camila App Plugin..."
./init-camila-app-plugin.sh $BUILD_HTML_PATH $APP_NAME $PLUGIN_NAME $LOCALE $ENVIRONMENT

echo "Initializing Camila App config vars..."
./set-camila-app-config-var.sh $BUILD_HTML_PATH $APP_NAME CAMILA_APPLICATION_NAME "ProtezioNET - Segreteria Campo" $LOCALE $ENVIRONMENT
./set-camila-app-config-var.sh $BUILD_HTML_PATH $APP_NAME CAMILA_APPLICATION_TITLE "Segreteria campo" $LOCALE $ENVIRONMENT
./set-camila-app-config-var.sh $BUILD_HTML_PATH $APP_NAME CAMILA_APPLICATION_GROUP "ProtezioNET" $LOCALE $ENVIRONMENT

# Prepare the temp directory for ZIP packaging
TEMP_DIR="${PLUGIN_NAME}-$(date +%Y-%m-%d)"

echo "Preparing temporary directory: $TEMP_DIR"

# Check if the directory exists, and if so, remove its contents
if [ -d "$TEMP_DIR" ]; then
    echo "Cleaning existing directory: $TEMP_DIR"
    rm -rf "$TEMP_DIR"/*
else
    echo "Creating directory: $TEMP_DIR"
    mkdir -p "$TEMP_DIR"
fi

# Check if the ZIP file already exists and remove it
if [ -f "$ZIP_FILE" ]; then
    echo "Removing existing ZIP file: $ZIP_FILE"
    rm -f "$ZIP_FILE"
fi

# Copy build contents into the temp directory
cp -r build/* "$TEMP_DIR/"

# Create the ZIP archive with PLUGIN_NAME as the root directory inside temp
echo "Creating ZIP archive: $ZIP_FILE"
if zip -rq "$ZIP_FILE" "${TEMP_DIR}"; then
    echo "✅ ZIP archive created successfully: $ZIP_FILE"
else
    echo "❌ Failed to create ZIP archive." >&2
    exit 1
fi

# Completion message
echo "All tasks completed successfully!"
