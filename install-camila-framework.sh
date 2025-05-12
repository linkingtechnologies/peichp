#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <destination_directory> [transfer_mode]"
    echo "Example for local: $0 /var/www/html local"
    exit 1
}

# Verify required parameters
if [ "$#" -lt 1 ]; then
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

GITHUB_REPO_URL="https://github.com/linkingtechnologies/camila-php-framework"
DESTINATION=$1
TRANSFER_MODE=${2:-local}  # Default to 'local' if not specified

# Clone the repository into a temporary directory
TEMP_DIR=/tmp

if [ -d "$TEMP_DIR/camila-php-framework/.git" ]; then
    echo "Repository already exists. Checking for updates..."
    cd "$TEMP_DIR/camila-php-framework" && git pull origin master || { echo "Git pull failed"; exit 1; }
    cd -
else
    echo "Cloning repository..."
    git clone --depth 1 "$GITHUB_REPO_URL" "$TEMP_DIR/camila-php-framework" || { echo "Git clone failed"; exit 1; }
    echo "Repository cloned successfully."
fi

# Ensure required directories exist in the destination
mkdir -p "$DESTINATION/vendor" "$DESTINATION/camila" "$DESTINATION/lib"

case "$TRANSFER_MODE" in
    local)
        echo "Deploying files locally..."
        cp -r "$TEMP_DIR/camila-php-framework/vendor" "$DESTINATION" || { echo "Copy failed"; exit 1; }
        cp -r "$TEMP_DIR/camila-php-framework/camila" "$DESTINATION" || { echo "Copy failed"; exit 1; }
        cp -r "$TEMP_DIR/camila-php-framework/lib" "$DESTINATION" || { echo "Copy failed"; exit 1; }
        cp "$TEMP_DIR/camila-php-framework/index.php" "$DESTINATION" || { echo "Copy failed"; exit 1; }
        cp "$TEMP_DIR/camila-php-framework/cli.php" "$DESTINATION" || { echo "Copy failed"; exit 1; }
        echo "Files copied to $DESTINATION successfully."
        ;;
    *)
        echo "Invalid transfer mode."
        usage
        ;;
esac

# Clean up the temporary directory
# rm -rf "$TEMP_DIR"
echo "Temporary files cleaned up."

echo "Deployment completed successfully."