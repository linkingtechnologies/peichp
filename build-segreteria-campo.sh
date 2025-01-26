#!/bin/bash

# Set security options to stop the script in case of an error
set -e

# Variable definitions
PHP_VERSION="8.3.16"
BUILD_PATH="build/html"
TEMPLATE_NAME="worktable-sqlite-it"
APP_NAME="segreteriacampo"
PLUGIN_NAME="segreteria-campo"
LOCALE="it"
ENVIRONMENT="local"

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

# Completion message
echo "All tasks completed successfully!"
