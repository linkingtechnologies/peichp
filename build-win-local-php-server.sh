#!/bin/bash

# Check if required commands are installed
REQUIRED_COMMANDS=("wget" "unzip" "sed" "jq")

for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed."
    echo "If you are using WSL (Ubuntu/Debian), install it by running:"
    echo "  sudo apt update && sudo apt install -y $cmd"
    exit 1
  fi
done

# Check if PHP version is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <php_version> [nginx_version]"
  exit 1
fi

PHP_VERSION=$1
NGINX_VERSION=$2

# Path to the composer.json file
COMPOSER_JSON="composer.json"

# URL of the composer.json file
COMPOSER_URL="https://raw.githubusercontent.com/linkingtechnologies/camila-php-framework/master/composer.json"

# Remove the build directory if it exists
rm -rf build
mkdir -p temp

# Download the composer.json file using wget
wget -q -O ${COMPOSER_JSON} "$COMPOSER_URL"

if [ -z "$NGINX_VERSION" ]; then
  echo "Using PHP built-in server. Skipping Nginx download."
  mkdir -p build/php
else
  echo "Checking Nginx version $NGINX_VERSION"
  if [ ! -f "temp/nginx-${NGINX_VERSION}.zip" ]; then
    wget -O temp/nginx-${NGINX_VERSION}.zip "https://nginx.org/download/nginx-${NGINX_VERSION}.zip" || { echo "Error downloading Nginx"; exit 1; }
  else
    echo "Nginx archive already exists, skipping download."
  fi

  unzip temp/nginx-${NGINX_VERSION}.zip -d build
  mv build/nginx-${NGINX_VERSION} build/nginx
  mkdir -p build/nginx/php
  touch build/nginx/temp/.gitkeep
fi

# Download PHP using wget if not already downloaded
echo "Checking PHP version $PHP_VERSION"

if [ ! -f "temp/php-${PHP_VERSION}.zip" ]; then
  wget -O temp/php-${PHP_VERSION}.zip "https://windows.php.net/downloads/releases/php-${PHP_VERSION}-Win32-vs16-x64.zip" || { echo "Error downloading PHP"; exit 1; }
else
  echo "PHP archive already exists, skipping download."
fi

PHP_INI='build/nginx/php/php.ini'
if [ -z "$NGINX_VERSION" ]; then
  unzip temp/php-${PHP_VERSION}.zip -d build/php
  cp build/php/php.ini-production build/php/php.ini
  PHP_INI='build/php/php.ini'
else
  unzip temp/php-${PHP_VERSION}.zip -d build/nginx/php
  cp build/nginx/php/php.ini-production build/nginx/php/php.ini
fi

# Download source files from GitHub using wget
wget -O temp/src.zip "https://github.com/linkingtechnologies/peichp/archive/refs/heads/main.zip" || { echo "Error downloading source files"; exit 1; }


# Extract the downloaded source files
if [ -z "$NGINX_VERSION" ]; then
  echo "[Embedded PHP]"
  unzip -o temp/src.zip 'peichp-main/templates/win/embedded/*' -d temp
  cp -rf temp/peichp-main/templates/win/embedded/* build/
else
  echo "[Nginx+PHP]"
  unzip -o temp/src.zip 'peichp-main/templates/win/nginx/*' -d temp
  cp -rf temp/peichp-main/templates/win/nginx/* build/
fi

rm -f build/nginx/html/index.html

# Extract required PHP extensions from composer.json
EXTENSIONS=$(jq -r '.require | keys[]' "$COMPOSER_JSON" | grep '^ext-' | sed 's/^ext-//')

# Check if any PHP extensions were found
if [ -z "$EXTENSIONS" ]; then
    echo "No PHP extensions found in composer.json."
    exit 0
fi

# Generate and execute sed commands to enable the extensions
for ext in $EXTENSIONS; do
    sed -i "s/;extension=$ext/extension=$ext/g" "$PHP_INI"
    echo "Enabled PHP extension: $ext"
done

echo "All required extensions have been enabled."

sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT \& ~E_NOTICE \& ~E_WARNING/g' ${PHP_INI}
sed -i 's/display_errors = Off/display_errors = On/g' ${PHP_INI}
sed -i 's/max_execution_time = 30/max_execution_time = 900/g' ${PHP_INI}
sed -i 's/max_input_vars = 1000/max_input_vars = 100000/g' ${PHP_INI}
sed -i 's@;extension_dir = "ext"@extension_dir = "ext"@g' ${PHP_INI}
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' ${PHP_INI}
sed -i 's/;date.timezone =/date.timezone = "Europe\/London"/g' ${PHP_INI}
sed -i 's/memory_limit = 128M/memory_limit = 256M/g' ${PHP_INI}

echo "Script completed successfully."