#!/bin/bash

# Function to check if required commands are installed
check_commands() {
    local missing=0
    for cmd in du rm find awk numfmt; do
        if ! command -v $cmd &> /dev/null; then
            echo "Error: Required command '$cmd' is not installed."
            missing=1
        fi
    done
    if [ $missing -eq 1 ]; then
        echo "Please install the missing commands and try again."
        exit 1
    fi
}

# Run command check
check_commands

# Get PHP directory input
if [ $# -eq 0 ]; then
    read -p "Enter the PHP directory path: " PHP_DIR
else
    PHP_DIR="$1"
fi

# Check if the PHP directory exists
if [ ! -d "$PHP_DIR" ]; then
    echo "Error: The directory '$PHP_DIR' does not exist!"
    exit 1
fi

# Function to get the directory size in bytes
get_dir_size() {
    du -sb "$1" | awk '{print $1}'
}

# Get initial size
initial_size=$(get_dir_size "$PHP_DIR")
echo "Initial PHP distribution size: $(du -sh "$PHP_DIR" | awk '{print $1}')"

echo "Cleaning up PHP distribution in '$PHP_DIR'..."

# 1. Remove unnecessary files
echo "Removing unnecessary files..."

# Remove documentation and duplicate configuration files
rm -fv "$PHP_DIR"/{README.md,CHANGELOG,LICENSE,NEWS,UPGRADING*}
rm -fv "$PHP_DIR"/php.ini-development "$PHP_DIR"/php.ini-production

# Remove debug and unnecessary executables
rm -fv "$PHP_DIR"/*.pdb
rm -fv "$PHP_DIR"/phpdbg.exe "$PHP_DIR"/php.exe.manifest

# Remove unnecessary extensions (add/remove based on your requirements)
rm -fv "$PHP_DIR"/ext/{php_ldap.dll,php_pgsql.dll,php_xdebug.dll,php_snmp.dll}

# Remove unnecessary libraries
rm -fv "$PHP_DIR"/{icu*.dll,libpq.dll,ssleay32.dll}

# Remove tests and examples if they exist
rm -rf "$PHP_DIR"/tests "$PHP_DIR"/examples "$PHP_DIR"/docs

# 2. Cleaning logs and temporary files
echo "Cleaning temporary files..."
find "$PHP_DIR" -type f \( -name "*.log" -o -name "*.tmp" -o -name "*.bak" \) -delete

# Get final size after cleanup
final_size=$(get_dir_size "$PHP_DIR")
echo "Final PHP distribution size: $(du -sh "$PHP_DIR" | awk '{print $1}')"

# Calculate reduction
size_reduction=$((initial_size - final_size))
reduction_percentage=$(awk "BEGIN {print ($size_reduction / $initial_size) * 100}")

echo "Size reduced by: $(numfmt --to=iec $size_reduction) ($reduction_percentage%)"

echo "Cleanup completed successfully!"
