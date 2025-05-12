#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <camila_base_dir> <appdir> <template> [transfer_mode]"
    echo "Example for local: $0 /var/www camila_app default local"
    exit 1
}

# Verify required parameters
if [ "$#" -lt 3 ]; then
    usage
fi

# Check if required commands are installed
REQUIRED_COMMANDS=("wget" "unzip" "sed" "jq" "git")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed."
    echo "If you are using WSL (Ubuntu/Debian), install it by running:"
    echo "  sudo apt update && sudo apt install -y $cmd"
    exit 1
  fi
done

CAMILA_BASE_DIR=$1
APPDIR=$2
TEMPLATE=$3
LOCALE=$4
TRANSFER_MODE=${5:-local}  # Default to 'local' if not specified

# Full application destination path: <camila_base_dir>/app/<appdir>
DESTINATION="$CAMILA_BASE_DIR/app/$APPDIR"

# Ensure camila_base_dir and app directory exist
if [ ! -d "$CAMILA_BASE_DIR/app" ]; then
    echo "Creating base app directory: $CAMILA_BASE_DIR/app"
    mkdir -p "$CAMILA_BASE_DIR/app" || { echo "Failed to create base app directory"; exit 1; }
fi

# Ensure app directory exists inside the app folder
if [ ! -d "$DESTINATION" ]; then
    echo "Creating application directory: $DESTINATION"
    mkdir -p "$DESTINATION" || { echo "Failed to create application directory"; exit 1; }
fi

# Construct the GitHub repository URL dynamically based on the template parameter
GITHUB_REPO_URL="https://github.com/linkingtechnologies/camila-php-framework-app-template-$TEMPLATE"

# Clone the repository into a temporary directory
TEMP_DIR=temp

if [ -d "$TEMP_DIR/camila-php-framework-$TEMPLATE/.git" ]; then
    echo "Repository for template '$TEMPLATE' already exists. Checking for updates..."
    cd "$TEMP_DIR/camila-php-framework-$TEMPLATE" && git pull origin main || { echo "Git pull failed"; exit 1; }
    cd -
else
    echo "Cloning repository for template '$TEMPLATE'..."
    git clone --depth 1 "$GITHUB_REPO_URL" "$TEMP_DIR/camila-php-framework-$TEMPLATE" || { echo "Git clone failed. Check if the template exists."; exit 1; }
    echo "Repository cloned successfully."
fi


case "$TRANSFER_MODE" in
    local)
        echo "Deploying files locally to $DESTINATION..."
        cp -r "$TEMP_DIR/camila-php-framework-$TEMPLATE/"* "$DESTINATION" || { echo "Copy failed"; exit 1; }
        echo "All files copied to $DESTINATION successfully."
		# Setting CAMILA_LANG
		echo "Setting locale $LOCALE in $DESTINATION/var/config.php..."
		sed -i "s/define('CAMILA_LANG', '[^']*');/define('CAMILA_LANG', '${LOCALE}');/" "$DESTINATION/var/config.php"

        ;;
    *)
        echo "Invalid transfer mode."
        usage
        ;;
esac

echo "Deployment completed successfully."
