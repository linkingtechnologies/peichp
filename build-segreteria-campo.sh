#!/bin/bash

APP_ID=segreteriacampo
LOCALE=it
APP_NAME="ProtezioNET - Segreteria Campo"
APP_TITLE="Segreteria campo"
APP_GROUP="ProtezioNET"
PLUGIN_NAMES="segreteria-campo"

./build-worktable-app.sh "win-local-nginx" "$APP_ID" "$LOCALE" "$APP_NAME" "$APP_TITLE" "$APP_GROUP" "$PLUGIN_NAMES" ""