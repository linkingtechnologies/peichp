#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <destination_directory> <transfer_mode> [ftp_user] [ftp_password] [ftp_host]"
    echo "Example for local: $0 /var/www/html local"
    echo "Example for FTP: $0 /remote/path ftp user pass ftp.example.com"
    echo "Example for SFTP: $0 /remote/path sftp user pass sftp.example.com"
    exit 1
}

# Verify required parameters
if [ "$#" -lt 2 ]; then
    usage
fi

# Check if required commands are installed
REQUIRED_COMMANDS=("wget" "unzip" "sed" "jq" "git" "lftp" "sshpass" "sftp")
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
TRANSFER_MODE=$2
FTP_USER=$3
FTP_PASS=$4
FTP_HOST=$5

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
    ftp)
        if [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ] || [ -z "$FTP_HOST" ]; then
            echo "Missing FTP credentials."
            usage
        fi
        echo "Uploading files via FTP..."
        lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" <<EOF
        mirror -R "$TEMP_DIR/camila-php-framework/vendor" "$DESTINATION/vendor"
        mirror -R "$TEMP_DIR/camila-php-framework/camila" "$DESTINATION/camila"
        mirror -R "$TEMP_DIR/camila-php-framework/lib" "$DESTINATION/lib"
        put "$TEMP_DIR/camila-php-framework/index.php" -o "$DESTINATION/index.php"
        put "$TEMP_DIR/camila-php-framework/cli.php" -o "$DESTINATION/cli.php"
        bye
EOF
        echo "Files uploaded to FTP server successfully."
        ;;
    sftp)
        if [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ] || [ -z "$FTP_HOST" ]; then
            echo "Missing SFTP credentials."
            usage
        fi
        echo "Uploading files via SFTP..."
        sshpass -p "$FTP_PASS" sftp -oBatchMode=no "$FTP_USER@$FTP_HOST" <<EOF
        put -r "$TEMP_DIR/camila-php-framework/vendor" "$DESTINATION/vendor"
        put -r "$TEMP_DIR/camila-php-framework/camila" "$DESTINATION/camila"
        put -r "$TEMP_DIR/camila-php-framework/lib" "$DESTINATION/lib"
        put "$TEMP_DIR/camila-php-framework/index.php" "$DESTINATION/index.php"
        put "$TEMP_DIR/camila-php-framework/cli.php" "$DESTINATION/cli.php"
        bye
EOF
        echo "Files uploaded to SFTP server successfully."
        ;;
    *)
        echo "Invalid transfer mode. Choose from local, ftp, or sftp."
        usage
        ;;
esac

# Clean up the temporary directory
# rm -rf "$TEMP_DIR"
echo "Temporary files cleaned up."

echo "Deployment completed successfully."
