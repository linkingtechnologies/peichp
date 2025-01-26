#!/bin/bash

# Function to display the correct usage of the script
usage() {
    echo "Usage: $0 <camila_base_dir> <appdir> <template> <transfer_mode> [ftp_user] [ftp_password] [ftp_host]"
    echo "Example for local: $0 /var/www camila_app default local"
    echo "Example for FTP: $0 /remote/path camila_app default ftp user pass ftp.example.com"
    echo "Example for SFTP: $0 /remote/path camila_app custom sftp user pass sftp.example.com"
    exit 1
}

# Verify required parameters
if [ "$#" -lt 4 ]; then
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

CAMILA_BASE_DIR=$1
APPDIR=$2
TEMPLATE=$3
TRANSFER_MODE=$4
FTP_USER=$5
FTP_PASS=$6
FTP_HOST=$7

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
        ;;
    ftp)
        if [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ] || [ -z "$FTP_HOST" ]; then
            echo "Missing FTP credentials."
            usage
        fi
        echo "Uploading files via FTP..."
        lftp -u "$FTP_USER","$FTP_PASS" "$FTP_HOST" <<EOF
        mirror -R "$TEMP_DIR/camila-php-framework-$TEMPLATE" "$DESTINATION"
        bye
EOF
        echo "All files uploaded to FTP server successfully."
        ;;
    sftp)
        if [ -z "$FTP_USER" ] || [ -z "$FTP_PASS" ] || [ -z "$FTP_HOST" ]; then
            echo "Missing SFTP credentials."
            usage
        fi
        echo "Uploading files via SFTP..."
        sshpass -p "$FTP_PASS" sftp -oBatchMode=no "$FTP_USER@$FTP_HOST" <<EOF
        put -r "$TEMP_DIR/camila-php-framework-$TEMPLATE/"* "$DESTINATION"
        bye
EOF
        echo "All files uploaded to SFTP server successfully."
        ;;
    *)
        echo "Invalid transfer mode. Choose from local, ftp, or sftp."
        usage
        ;;
esac

echo "Deployment completed successfully."
