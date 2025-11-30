#!/bin/bash

APP_ID=worktable
LOCALE=en
APP_NAME="WorkTable"
APP_TITLE="A WorkTable App"
APP_GROUP="Camila"
PLUGIN_NAMES=""

./build-worktable-app.sh "docker-nginx" "$APP_ID" "$LOCALE" "$APP_NAME" "$APP_TITLE" "$APP_GROUP" "$PLUGIN_NAMES" ""