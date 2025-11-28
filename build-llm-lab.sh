#!/bin/bash

APP_ID=llmlab
LOCALE=en
APP_NAME="LLM Lab"
APP_TITLE="LLM Lab"
APP_GROUP="Camila Framework"
PLUGIN_NAMES="llm-lab"

./build-win-local-llm-server.sh

export KEEP_BUILD_DIR=1
./build-worktable-app.sh "win-local-php" "$APP_ID" "$LOCALE" "$APP_NAME" "$APP_TITLE" "$APP_GROUP" "$PLUGIN_NAMES" ""