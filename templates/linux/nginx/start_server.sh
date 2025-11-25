#!/bin/bash

# Resolve the base directory where this script is located
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Directories
NGINX_DIR="$BASE_DIR/nginx"
PHP_DIR="$NGINX_DIR/php"

# Binaries
PHP_FPM_BIN="$PHP_DIR/sbin/php-fpm"
NGINX_BIN="$NGINX_DIR/sbin/nginx"

# Configuration files
PHP_INI="$PHP_DIR/php.ini"
PHP_FPM_CONF="$PHP_DIR/etc/php-fpm.conf"

# PID file for php-fpm
PHP_FPM_PID="$NGINX_DIR/logs/php-fpm.pid"

echo "Starting PHP-FPM from: $PHP_FPM_BIN"

########################################################################
# Stop previous PHP-FPM instance if PID file exists
########################################################################

if [ -f "$PHP_FPM_PID" ]; then
    echo "PHP-FPM PID file found. Attempting to stop previous instance..."
    kill "$(cat "$PHP_FPM_PID")" 2>/dev/null || true
    rm -f "$PHP_FPM_PID"
fi

"$PHP_FPM_BIN" -y "$PHP_FPM_CONF" -c "$PHP_INI" -g "$PHP_FPM_PID" &

sleep 1
echo "PHP-FPM started."

echo "Starting nginx..."

"$NGINX_BIN" -c conf/nginx.conf

echo "nginx started. Waiting a moment before opening the browser..."
sleep 2

BROWSER_URL="http://localhost"
echo "Opening $BROWSER_URL"
xdg-open "$BROWSER_URL" >/dev/null 2>&1 &

echo "Startup completed."
exit 0
