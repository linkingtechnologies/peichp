#!/bin/bash

APP_ID=segreteriacampo
LOCALE=it
APP_NAME="ProtezioNET - Segreteria Campo"
APP_TITLE="Segreteria campo"
APP_GROUP="ProtezioNET"
PLUGIN_NAMES="segreteria-campo"
DB_DSN=mysql://utente:password@host:porta/nome_database

./build-worktable-app.sh "remote" "$APP_ID" "$LOCALE" "$APP_NAME" "$APP_TITLE" "$APP_GROUP" "$PLUGIN_NAMES" "$DB_DSN"