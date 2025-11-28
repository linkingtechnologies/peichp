#!/bin/bash

#Last supported version
PHP_VERSION="8.3.28"
NGINX_VERSION="1.27.5"

TEMPLATE_NAME="worktable-sqlite-en"

# Set security options to stop the script in case of an error
set -e

main() {
	# Run the command check before proceeding
	check_commands

	# Allowed build types
	VALID_BUILD_TYPES=("win-local-php" "win-local-nginx" "linux-local-php" "linux-local-nginx" "remote")

	# Default values
	DEFAULT_BUILD_TYPE="win-local-nginx"
	DEFAULT_APP_ID="worktable"
	DEFAULT_LOCALE="en"
	DEFAULT_APP_NAME="WorkTable"
	DEFAULT_APP_TITLE="A WorkTable App"
	DEFAULT_APP_GROUP="Camila"
	DEFAULT_PLUGIN_NAMES=""
	DEFAULT_DB_DSN=""

	# Get or prompt BUILD_TYPE
	BUILD_TYPE="${1:-}"
	while [[ -z "$BUILD_TYPE" ]] || ! validate_build_type "$BUILD_TYPE"; do
		BUILD_TYPE=$(prompt_with_default "Enter BUILD_TYPE (win-local-php, win-local-nginx, linux-local-php, linux-local-nginx, remote)" "$DEFAULT_BUILD_TYPE")
		if ! validate_build_type "$BUILD_TYPE"; then
			echo "Invalid BUILD_TYPE. Allowed values: ${VALID_BUILD_TYPES[*]}"
			BUILD_TYPE=""
		fi
	done

	APP_ID="${2:-$(prompt_with_default 'Enter APP_ID' "$DEFAULT_APP_ID")}"
	LOCALE="${3:-$(prompt_with_default 'Enter LOCALE' "$DEFAULT_LOCALE")}"

	# Assign remaining CLI arguments or prompt interactively
	if [ "$#" -ge 4 ]; then
		APP_NAME="${4:-$DEFAULT_APP_NAME}"
		APP_TITLE="${5:-$DEFAULT_APP_TITLE}"
		APP_GROUP="${6:-$DEFAULT_APP_GROUP}"
		PLUGIN_NAMES="${7:-$DEFAULT_PLUGIN_NAMES}"
		DB_DSN="${8:-$DEFAULT_DB_DSN}"
	else
		APP_NAME=$(prompt_with_default 'Enter APP_NAME (optional)' "$DEFAULT_APP_NAME")
		APP_TITLE=$(prompt_with_default 'Enter APP_TITLE (optional)' "$DEFAULT_APP_TITLE")
		APP_GROUP=$(prompt_with_default 'Enter APP_GROUP (optional)' "$DEFAULT_APP_GROUP")
		PLUGIN_NAMES=$(prompt_with_default 'Enter PLUGIN_NAMES (comma-separated, optional)' "$DEFAULT_PLUGIN_NAMES")
		DB_DSN=$(prompt_with_default 'Enter DB_DSN (optional)' "$DEFAULT_DB_DSN")
	fi

	# Export variables
	export BUILD_TYPE
	export APP_ID
	export APP_NAME
	export APP_TITLE
	export APP_GROUP
	export LOCALE
	export PLUGIN_NAMES
	export DB_DSN

	if [ -n "$PLUGIN_NAMES" ]; then
		IFS=',' read -ra PLUGIN_ARRAY <<<"$PLUGIN_NAMES"
	else
		PLUGIN_ARRAY=()
	fi

	SERVER_TYPE=php

	# Summary
	echo "---"
	echo "Configuration:"
	echo "BUILD_TYPE: $BUILD_TYPE"
	echo "APP_ID: $APP_ID"
	echo "LOCALE: $LOCALE"
	echo "APP_NAME: $APP_NAME"
	echo "APP_TITLE: $APP_TITLE"
	echo "APP_GROUP: $APP_GROUP"
	echo "PLUGIN_NAMES: ${PLUGIN_ARRAY[*]:-"<none>"}"
	if [[ -n "$DB_DSN" ]]; then
		echo "DB_DSN: ***"
	fi
	echo "---"

	if [[ "$BUILD_TYPE" == "win-local-nginx" || "$BUILD_TYPE" == "linux-local-nginx" ]]; then
		SERVER_TYPE=nginx
	fi

	if [[ "$SERVER_TYPE" == "nginx" ]]; then
		BUILD_HTML_PATH="build/nginx/html"
		BUILD_PHP_PATH="build/nginx/php"
	elif [[ "$BUILD_TYPE" == "remote" ]]; then
		BUILD_HTML_PATH="build/html"
		BUILD_PHP_PATH="build/php"
		NGINX_VERSION=""
	else
		BUILD_HTML_PATH="build/html"
		BUILD_PHP_PATH="build/php"
		NGINX_VERSION=""
	fi

	ZIP_FILE="${APP_ID}-${BUILD_TYPE}-$(date +%Y-%m-%d).zip"
	TAR_FILE="${APP_ID}-${BUILD_TYPE}-$(date +%Y-%m-%d).tar.gz"

	# Execute the required commands
	echo "Building local PHP server..."
	if [[ "$BUILD_TYPE" == "win-local-php" || "$BUILD_TYPE" == "win-local-nginx" ]]; then
		./build-win-local-php-server.sh $PHP_VERSION $LOCALE $NGINX_VERSION
	elif [[ "$BUILD_TYPE" == "linux-local-php" || "$BUILD_TYPE" == "linux-local-nginx" ]]; then
		export KEEP_BUILD_DIR=1
		./build-linux-local-php-server.sh $PHP_VERSION $LOCALE $NGINX_VERSION
	elif [[ "$BUILD_TYPE" == "remote" ]]; then
		echo "Remote build: no local server required (only HTML/PHP build)."
	fi

	echo "Cleaning up PHP build..."
	./php-cleanup.sh $BUILD_PHP_PATH

	echo "Installing Camila Framework..."
	./install-camila-framework.sh $BUILD_HTML_PATH

	echo "Vendor dir cleanup..."
	cleanup_vendor_dir

	echo "Installing Camila App..."
	./install-camila-app.sh $BUILD_HTML_PATH $APP_ID $TEMPLATE_NAME $LOCALE

	if [ "${#PLUGIN_ARRAY[@]}" -eq 0 ]; then
		echo "No plugins specified — skipping plugin installation."
	fi

	if [ "${#PLUGIN_ARRAY[@]}" -gt 0 ]; then
		# Process each plugin
		echo "Installing plugins (install):"
		for plugin in "${PLUGIN_ARRAY[@]}"; do
			echo "- Installing plugin: $plugin"
			echo "Installing Camila App Plugin..."
			./install-camila-app-plugin.sh $BUILD_HTML_PATH $APP_ID $plugin
		done
	fi

	echo "Initializing Camila App..."
	./init-camila-app.sh $BUILD_HTML_PATH $APP_ID $LOCALE

	if [ "${#PLUGIN_ARRAY[@]}" -gt 0 ]; then
		echo "Initializing plugins..."
		if [[ "$BUILD_TYPE" == "remote" ]]; then
			echo "Copying install.php to build directory..."
			cp ./templates/scripts/php/install.php "$BUILD_HTML_PATH/app/$APP_ID/install.php"
			echo "Injecting LOCALE and PLUGIN_NAMES into install.php..."
			sed -i \
				-e "s|%%LOCALE%%|$LOCALE|g" \
				-e "s|%%PLUGIN_NAMES%%|$PLUGIN_NAMES|g" \
				"$BUILD_HTML_PATH/app/$APP_ID/install.php"
		fi
		for plugin in "${PLUGIN_ARRAY[@]}"; do
			echo "Initializing Camila App Plugin..."
			./init-camila-app-plugin.sh $BUILD_HTML_PATH $APP_ID $plugin $LOCALE
		done
	fi

	echo "Initializing Camila App config vars..."
	./set-camila-app-config-var.sh $BUILD_HTML_PATH $APP_ID CAMILA_APPLICATION_NAME "$APP_NAME" $LOCALE
	./set-camila-app-config-var.sh $BUILD_HTML_PATH $APP_ID CAMILA_APPLICATION_TITLE "$APP_TITLE" $LOCALE
	./set-camila-app-config-var.sh $BUILD_HTML_PATH $APP_ID CAMILA_APPLICATION_GROUP "$APP_GROUP" $LOCALE

	if [[ -n "$DB_DSN" ]]; then
		./set-camila-app-config-var.sh $BUILD_HTML_PATH $APP_ID CAMILA_DB_DSN "$DB_DSN" $LOCALE
		./set-camila-app-config-var.sh $BUILD_HTML_PATH $APP_ID CAMILA_AUTH_DSN "$DB_DSN" $LOCALE
	fi

	# Prepare the temp directory for ZIP packaging
	TEMP_DIR="/tmp/${APP_ID}-$(date +%Y-%m-%d)"
	PWD_DIR="$(pwd)"

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

	# Check if the ZIP file already exists and remove it
	if [ -f "$TAR_FILE" ]; then
		echo "Removing existing TAR.GZ file: $TAR_FILE"
		rm -f "$TAR_FILE"
	fi

	# Copy build contents into the temp directory
	if [[ "$BUILD_TYPE" == "remote" ]]; then
		cp -r build/html/* "$TEMP_DIR/"
	else
		cp -r build/* "$TEMP_DIR/"
	fi

	pushd "$(pwd)"
	cd "${TEMP_DIR}"

	if [[ "$BUILD_TYPE" == "win-local-php" || "$BUILD_TYPE" == "win-local-nginx" ]] ||
		grep -qi "microsoft" /proc/version 2>/dev/null; then

		# Create the ZIP archive with APP_ID as the root directory inside temp
		echo "Creating ZIP archive: $ZIP_FILE"
		if zip -rq "${PWD_DIR}/$ZIP_FILE" "./"; then
			rm -rf "${TEMP_DIR}"
			echo "ZIP archive created successfully: $ZIP_FILE"
		else
			echo "Failed to create ZIP archive." >&2
			exit 1
		fi

	else

		# Create the TAR.GZ archive with APP_ID as the root directory inside temp
		echo "Creating TAR.GZ archive: $TAR_FILE"
		if tar -czf "${PWD_DIR}/${TAR_FILE}" .; then
			rm -rf "${TEMP_DIR}"
			echo "TAR.GZ archive created successfully: $TAR_FILE"
		else
			echo "Failed to create TAR.GZ archive." >&2
			exit 1
		fi
	fi

	popd
	# Completion message
	echo "All tasks completed successfully!"
}

# Function to check required commands
check_commands() {
	local missing=0
	REQUIRED_COMMANDS=("wget" "unzip" "sed" "jq" "git" "zip" "tar")

	echo "Checking required commands..."
	for cmd in "${REQUIRED_COMMANDS[@]}"; do
		if ! command -v "$cmd" &>/dev/null; then
			echo "Error: Required command '$cmd' is not installed."
			missing=1
		fi
	done

	if [ $missing -eq 1 ]; then
		echo "Please install the missing commands and retry."
		exit 1
	fi

	echo "All required commands are installed."
}

# Function to prompt user with default
prompt_with_default() {
	local prompt_text="$1"
	local default_value="$2"
	local user_input

	read -p "$prompt_text [$default_value]: " user_input
	if [ -z "$user_input" ]; then
		echo "$default_value"
	else
		echo "$user_input"
	fi
}

# Function to validate BUILD_TYPE
validate_build_type() {
	local input="$1"
	for valid in "${VALID_BUILD_TYPES[@]}"; do
		if [[ "$input" == "$valid" ]]; then
			return 0
		fi
	done
	return 1
}

cleanup_vendor_dir() {
	local FONT_DIR="$BUILD_HTML_PATH/vendor/mpdf/mpdf/ttfonts"

	# List of font files to delete (not typically needed for Western-language projects)
	local FILES_TO_DELETE=(
		"AboriginalSansREGULAR.ttf"
		"Abyssinica_SIL.ttf"
		"Aegean.otf"
		"Aegyptus.otf"
		"Akkadian.otf"
		"ayar.ttf"
		"damase_v.2.ttf"
		"DBSILBR.ttf"
		"Dhyana-Bold.ttf"
		"Dhyana-Regular.ttf"
		"DhyanaOFL.txt"
		"Garuda-Bold.ttf"
		"Garuda-BoldOblique.ttf"
		"Garuda-Oblique.ttf"
		"Garuda.ttf"
		"GNUFreeFontinfo.txt"
		"Jomolhari-OFL.txt"
		"Jomolhari.ttf"
		"kaputaunicode.ttf"
		"KhmerOFL.txt"
		"KhmerOS.ttf"
		"lannaalif-v1-03.ttf"
		"Lateef font OFL.txt"
		"LateefRegOT.ttf"
		"list.txt"
		"Lohit-Kannada.ttf"
		"LohitKannadaOFL.txt"
		"Padauk-book.ttf"
		"Pothana2000.ttf"
		"Quivira.otf"
		"Sun-ExtA.ttf"
		"Sun-ExtB.ttf"
		"SundaneseUnicode-1.0.5.ttf"
		"SyrCOMEdessa.otf"
		"SyrCOMEdessa_license.txt"
		"TaameyDavidCLM-LICENSE.txt"
		"TaameyDavidCLM-Medium.ttf"
		"TaiHeritagePro.ttf"
		"Tharlon-Regular.ttf"
		"TharlonOFL.txt"
		"UnBatang_0613.ttf"
		"Uthman.otf"
		"XB Riyaz.ttf"
		"XB RiyazBd.ttf"
		"XB RiyazBdIt.ttf"
		"XB RiyazIt.ttf"
		"XW Zar Font Info.txt"
		"ZawgyiOne.ttf"
	)

	echo "Cleaning up unused fonts in $FONT_DIR..."

	# Loop through the file list and delete each one if it exists
	for file in "${FILES_TO_DELETE[@]}"; do
		local path="$FONT_DIR/$file"
		if [ -f "$path" ]; then
			echo "  Deleting $file"
			rm "$path"
		fi
	done

	echo "Font cleanup complete."
}

# Run the script
main "$@"
