#!/bin/bash

set -euo pipefail

# Check if an existing compiled binary matches the expected version.
# Arguments:
#   $1: full path to the binary (e.g. /path/to/bin/php)
#   $2: expected version string (e.g. 8.3.3 or 1.27.0)
check_existing_build() {
  local CMD="$1"
  local EXPECTED_VERSION="$2"

  echo ">>> [DEBUG] check_existing_build()"
  echo ">>> [DEBUG] Binary path: $CMD"
  echo ">>> [DEBUG] Expected version: $EXPECTED_VERSION"

  # If the binary does not exist or is not executable, treat as no build
  if [ ! -x "$CMD" ]; then
    echo ">>> [DEBUG] Binary does not exist or is not executable."
    return 1
  fi

  echo ">>> [DEBUG] Running: $CMD -v"
  local RAW_OUTPUT
  RAW_OUTPUT="$("$CMD" -v 2>&1)"
  echo ">>> [DEBUG] Raw version output:"
  echo "$RAW_OUTPUT"

  # Extract version number from `<cmd> -v` output
  local INSTALLED_VERSION
  INSTALLED_VERSION="$(echo "$RAW_OUTPUT" | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" || true

  echo ">>> [DEBUG] Extracted INSTALLED_VERSION: '${INSTALLED_VERSION}'"

  if [ -z "$INSTALLED_VERSION" ]; then
    echo ">>> [DEBUG] No version number extracted → build not reusable"
    return 1
  fi

  if [ "$INSTALLED_VERSION" = "$EXPECTED_VERSION" ]; then
    echo ">>> [DEBUG] Version MATCHES. Reusing build."
    return 0
  else
    echo ">>> [DEBUG] Version MISMATCH."
    echo ">>> [DEBUG] Installed: $INSTALLED_VERSION"
    echo ">>> [DEBUG] Expected:   $EXPECTED_VERSION"
    return 1
  fi
}


build_php_from_source() {
  local PHP_VERSION="$1"
  local PREFIX="$2"
  local PHP_BIN="$PREFIX/bin/php"

  # If PHP binary already exists and version matches, reuse it
  if check_existing_build "$PHP_BIN" "$PHP_VERSION"; then
    echo ">>> PHP $PHP_VERSION already built at $PHP_BIN. Reusing existing build."
    return 0
  fi

  echo ">>> Building PHP $PHP_VERSION into: $PREFIX"

  # Ensure prefix exists
  mkdir -p "$PREFIX"

  # Install build dependencies (Ubuntu/Debian)
  if command -v apt-get >/dev/null 2>&1; then
    echo ">>> Installing PHP build dependencies via apt-get..."
    sudo apt-get update
    sudo apt-get install -y \
      build-essential \
      pkg-config \
      autoconf \
      bison \
      re2c \
      libxml2-dev \
      libsqlite3-dev \
      libssl-dev \
      libcurl4-openssl-dev \
      libzip-dev \
      zlib1g-dev \
      libonig-dev \
      libjpeg-dev \
      libpng-dev \
      libfreetype6-dev \
      libxslt-dev
  else
    echo "Warning: apt-get not found. Make sure all build deps are installed manually."
  fi

  # Temporary build directory
  local WORKDIR
  WORKDIR="$(mktemp -d)"
  echo ">>> Using temporary directory: $WORKDIR"

  pushd "$WORKDIR" >/dev/null

  echo ">>> Downloading PHP sources..."
  wget "https://www.php.net/distributions/php-$PHP_VERSION.tar.xz" -O "php-$PHP_VERSION.tar.xz" \
    || { echo "Error downloading PHP sources"; exit 1; }

  echo ">>> Extracting PHP sources..."
  tar xf "php-$PHP_VERSION.tar.xz"
  cd "php-$PHP_VERSION"

  echo ">>> Configuring PHP..."
  ./configure \
    --prefix="$PREFIX" \
    --enable-cli \
    --enable-fpm \
    --disable-cgi \
    --enable-mbstring \
    --enable-exif \
    --enable-gd \
    --with-jpeg \
    --with-freetype \
    --with-xsl \
    --with-zlib \
    --with-curl \
    --with-openssl \
    --with-pdo-mysql \
    --with-mysqli \
    --with-pdo-sqlite \
    --with-sqlite3 \
    --with-zip

  echo ">>> Building PHP..."
  local JOBS=1
  if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)"
  fi
  make -j"$JOBS"

  echo ">>> Installing PHP..."
  make install

  echo ">>> Copying php.ini-production to prefix..."
  cp php.ini-production "$PREFIX/php.ini"

  # Detect and set extension_dir to the compiled extension directory
  if [ -d "$PREFIX/lib/php/extensions" ]; then
    local EXT_DIR
    EXT_DIR="$(find "$PREFIX/lib/php/extensions" -maxdepth 1 -mindepth 1 -type d | head -n1 || true)"
    if [ -n "$EXT_DIR" ]; then
      echo ">>> Setting extension_dir to: $EXT_DIR"
      sed -i "s@;extension_dir = .*@extension_dir = \"$EXT_DIR\"@g" "$PREFIX/php.ini" || true
    fi
  fi

  popd >/dev/null
  rm -rf "$WORKDIR"

  echo ">>> PHP $PHP_VERSION build completed."
}

build_nginx_from_source() {
  local NGINX_VERSION="$1"
  local PREFIX="$2"
  local NGINX_BIN="$PREFIX/sbin/nginx"

  # If Nginx binary already exists and version matches, reuse it
  if check_existing_build "$NGINX_BIN" "$NGINX_VERSION"; then
    echo ">>> Nginx $NGINX_VERSION already built at $NGINX_BIN. Reusing existing build."
    return 0
  fi

  echo ">>> Building Nginx $NGINX_VERSION into: $PREFIX"

  # Ensure prefix exists
  mkdir -p "$PREFIX"

  # Install build dependencies (Ubuntu/Debian)
  if command -v apt-get >/dev/null 2>&1; then
    echo ">>> Installing Nginx build dependencies via apt-get..."
    local SUDO=""
    if command -v sudo >/dev/null 2>&1 && [ "$EUID" -ne 0 ]; then
      SUDO="sudo"
    fi

    $SUDO apt-get update
    $SUDO apt-get install -y \
      build-essential \
      libpcre3-dev \
      zlib1g-dev \
      libssl-dev
  else
    echo "Warning: apt-get not found. Make sure Nginx build deps are installed manually."
  fi

  # Temporary build directory
  local WORKDIR
  WORKDIR="$(mktemp -d)"
  echo ">>> Using temporary directory for Nginx: $WORKDIR"

  pushd "$WORKDIR" >/dev/null

  local TARBALL="nginx-${NGINX_VERSION}.tar.gz"
  local URL="https://nginx.org/download/${TARBALL}"

  echo ">>> Downloading Nginx sources from: $URL"
  wget -O "$TARBALL" "$URL" \
    || { echo "Error downloading Nginx sources"; exit 1; }

  echo ">>> Extracting Nginx sources..."
  tar xzf "$TARBALL"

  cd "nginx-${NGINX_VERSION}"

  echo ">>> Configuring Nginx..."
  ./configure \
    --prefix="$PREFIX" \
    --with-http_ssl_module \
    --with-http_gzip_static_module \
    --with-http_stub_status_module

  echo ">>> Building Nginx..."
  local JOBS=1
  if command -v nproc >/dev/null 2>&1; then
    JOBS="$(nproc)"
  fi
  make -j"$JOBS"

  echo ">>> Installing Nginx..."
  make install

  popd >/dev/null
  rm -rf "$WORKDIR"

  echo ">>> Nginx $NGINX_VERSION build completed."
}



# Check if required commands are installed
REQUIRED_COMMANDS=("wget" "unzip" "sed" "jq")
for cmd in "${REQUIRED_COMMANDS[@]}"; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: Required command '$cmd' is not installed."
    echo "If you are using WSL (Ubuntu/Debian), install it by running:"
    echo "  sudo apt update && sudo apt install -y $cmd"
    exit 1
  fi
done

# Check if PHP version is provided
if [ -z "${1:-}" ]; then
  echo "Usage: $0 <php_version> [lang] [nginx_version]"
  exit 1
fi

PHP_VERSION="$1"
LANGUAGE="${2:-"en"}"
NGINX_VERSION="${3:-}"

# Resolve script directory (so paths are absolute and robust)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Path to the composer.json file
COMPOSER_JSON="$SCRIPT_DIR/temp/composer.json"

# URL of the composer.json file
COMPOSER_URL="https://raw.githubusercontent.com/linkingtechnologies/camila-php-framework/master/composer.json"

# Remove the build directory if it exists (only if KEEP_BUILD_DIR is not set)
# Note: if you want to reuse compiled binaries across runs, set KEEP_BUILD_DIR.
if [ -z "${KEEP_BUILD_DIR:-}" ]; then
    rm -rf "$SCRIPT_DIR/build"
else
    echo "Skipping build directory removal because KEEP_BUILD_DIR is set"
fi

mkdir -p "$SCRIPT_DIR/temp"

# Download the composer.json file using wget
wget -q -O "${COMPOSER_JSON}" "$COMPOSER_URL"

if [ -z "$NGINX_VERSION" ]; then
  echo "Using PHP built-in server. Skipping Nginx build."
  mkdir -p "$SCRIPT_DIR/build/php"
else
  echo "Building Nginx version $NGINX_VERSION from source..."
  NGINX_PREFIX="$SCRIPT_DIR/build/nginx"

  # Build Nginx into build/nginx (with reuse if already built)
  build_nginx_from_source "$NGINX_VERSION" "$NGINX_PREFIX"

  # Create folders used by the templates
  mkdir -p "$NGINX_PREFIX/php"
  mkdir -p "$NGINX_PREFIX/temp"
  touch "$NGINX_PREFIX/temp/.gitkeep"
fi

echo "Checking PHP version $PHP_VERSION"

if [ -z "$NGINX_VERSION" ]; then
  # PHP-only mode: install into build/php
  PHP_PREFIX="$SCRIPT_DIR/build/php"
else
  # Nginx+PHP mode: install PHP into build/nginx/php
  PHP_PREFIX="$SCRIPT_DIR/build/nginx/php"
fi

# Build PHP into the chosen prefix (with reuse if already built)
build_php_from_source "$PHP_VERSION" "$PHP_PREFIX"

# Path to php.ini in our local PHP build
PHP_INI="$PHP_PREFIX/php.ini"

# -----------------------------------------
# Download source files from GitHub using wget
# -----------------------------------------
wget -O "$SCRIPT_DIR/temp/src.zip" "https://github.com/linkingtechnologies/peichp/archive/refs/heads/main.zip" || { echo "Error downloading source files"; exit 1; }

if [ -z "$NGINX_VERSION" ]; then
  echo "[Embedded PHP]"
  unzip -o "$SCRIPT_DIR/temp/src.zip" 'peichp-main/templates/linux/embedded/*' -d "$SCRIPT_DIR/temp"
  cp -rf "$SCRIPT_DIR/temp/peichp-main/templates/linux/embedded/"* "$SCRIPT_DIR/build/"
else
  echo "[Nginx+PHP]"
  unzip -o "$SCRIPT_DIR/temp/src.zip" 'peichp-main/templates/linux/nginx/*' -d "$SCRIPT_DIR/temp"
  cp -rf "$SCRIPT_DIR/temp/peichp-main/templates/linux/nginx/"* "$SCRIPT_DIR/build/"
fi

rm -f "$SCRIPT_DIR/build/nginx/html/index.html" 2>/dev/null || true

# -----------------------------------------
# Extract required PHP extensions from composer.json
# -----------------------------------------
EXTENSIONS=$(jq -r '.require | keys[]' "$COMPOSER_JSON" | grep '^ext-' | sed 's/^ext-//')

# Check if any PHP extensions were found
if [ -z "$EXTENSIONS" ]; then
    echo "No PHP extensions found in composer.json."
else
    echo "Enabling required PHP extensions in php.ini..."
    for ext in $EXTENSIONS; do
        sed -i "s/;extension=$ext/extension=$ext/g" "$PHP_INI" || true
        echo "Enabled PHP extension: $ext (if present in php.ini)"
    done
fi

echo "Applying php.ini tweaks..."

sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT/error_reporting = E_ALL \& ~E_DEPRECATED \& ~E_STRICT \& ~E_NOTICE \& ~E_WARNING/g' "$PHP_INI" || true
sed -i 's/display_errors = Off/display_errors = On/g' "$PHP_INI" || true
sed -i 's/max_execution_time = 30/max_execution_time = 900/g' "$PHP_INI" || true
sed -i 's/max_input_vars = 1000/max_input_vars = 100000/g' "$PHP_INI" || true
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/g' "$PHP_INI" || true
sed -i 's/;date.timezone =/date.timezone = "Europe\/London"/g' "$PHP_INI" || true
sed -i 's/memory_limit = 128M/memory_limit = 256M/g' "$PHP_INI" || true

if [ "$LANGUAGE" == "it" ]; then
  if [ -f "$SCRIPT_DIR/build/view_IP_addresses.sh" ]; then
    mv "$SCRIPT_DIR/build/view_IP_addresses.sh" "$SCRIPT_DIR/build/mostra_indirizzi_IP.sh"
  fi
  if [ -f "$SCRIPT_DIR/build/start_server.sh" ]; then
    mv "$SCRIPT_DIR/build/start_server.sh" "$SCRIPT_DIR/build/avvia_server.sh"
  fi
  if [ -f "$SCRIPT_DIR/build/start_server_8080.sh" ]; then
    mv "$SCRIPT_DIR/build/start_server_8080.sh" "$SCRIPT_DIR/build/avvia_server_8080.sh"
  fi
  if [ -f "$SCRIPT_DIR/build/stop_server.sh" ]; then
    mv "$SCRIPT_DIR/build/stop_server.sh" "$SCRIPT_DIR/build/ferma_server.sh"
  fi
  echo "Batch files have been renamed to Italian (if they exist)."
fi

echo "Script completed successfully."
