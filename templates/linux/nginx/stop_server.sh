#!/bin/bash

########################################################################
# Stop script for standalone nginx + php-fpm bundle
# Kills php-fpm and nginx processes started from this project directory
# WITHOUT needing to know their PIDs.
########################################################################

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Full paths to match in process command lines
PHP_FPM_PATTERN="$BASE_DIR/nginx/php/sbin/php-fpm"
NGINX_PATTERN="$BASE_DIR/nginx/sbin/nginx"

echo "Base dir:        $BASE_DIR"
echo "PHP-FPM pattern: $PHP_FPM_PATTERN"
echo "nginx pattern:   $NGINX_PATTERN"
echo

########################################################################
# Stop PHP-FPM
########################################################################
echo "Searching for PHP-FPM processes..."

PHP_PIDS=$(pgrep -f "$PHP_FPM_PATTERN" || true)

if [ -n "$PHP_PIDS" ]; then
    echo "Found PHP-FPM PIDs: $PHP_PIDS"
    kill $PHP_PIDS 2>/dev/null || true
    sleep 1
    # Force kill if still alive
    PHP_PIDS_STILL=$(pgrep -f "$PHP_FPM_PATTERN" || true)
    if [ -n "$PHP_PIDS_STILL" ]; then
        echo "Some PHP-FPM processes are still running, forcing kill: $PHP_PIDS_STILL"
        kill -9 $PHP_PIDS_STILL 2>/dev/null || true
    fi
else
    echo "No PHP-FPM processes found for this project."
fi

echo

########################################################################
# Stop nginx
########################################################################
echo "Searching for nginx processes..."

NGINX_PIDS=$(pgrep -f "$NGINX_PATTERN" || true)

if [ -n "$NGINX_PIDS" ]; then
    echo "Found nginx PIDs: $NGINX_PIDS"
    kill $NGINX_PIDS 2>/dev/null || true
    sleep 1
    # Force kill if still alive
    NGINX_PIDS_STILL=$(pgrep -f "$NGINX_PATTERN" || true)
    if [ -n "$NGINX_PIDS_STILL" ]; then
        echo "Some nginx processes are still running, forcing kill: $NGINX_PIDS_STILL"
        kill -9 $NGINX_PIDS_STILL 2>/dev/null || true
    fi
else
    echo "No nginx processes found for this project."
fi

echo
echo "Done."
exit 0
