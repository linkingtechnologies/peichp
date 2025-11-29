# README.md

# PHP Environment Setup Scripts

This repository contains multiple Bash scripts that automate the creation, configuration, and packaging of **local environments for running PHP applications**, as well as building applications based on the **Camila PHP Framework**:

**https://github.com/linkingtechnologies/camila-php-framework**

Some scripts target Windows (using downloadable PHP builds and optional Nginx), others build self-contained environments on Linux by compiling components from source, and one orchestrates the full build of the WorkTable application.

While examples often reference WSL (Windows Subsystem for Linux), any modern Linux environment can run these scripts.

---

## Table of Contents

1. [Scripts Index](#scripts-index)  
2. [Script: build-win-local-php-server.sh](#script-build-win-local-php-serversh)  
3. [Script: build-linux-local-php-server.sh](#script-build-linux-local-php-serversh)  
4. [Script: build-worktable-app.sh](#script-build-worktable-appsh)  
5. [Example: Downloading and Running a Local PHP Server](#example-downloading-and-running-a-local-php-server)  
6. [Notes](#notes)  
7. [Troubleshooting](#troubleshooting)

---

## Scripts Index

- **build-win-local-php-server.sh**  
  Creates a portable PHP environment for Windows, with optional Nginx.

- **build-linux-local-php-server.sh**  
  Builds a portable PHP environment for Linux by compiling PHP and optionally Nginx from source.

- **build-worktable-app.sh**  
  Builds the WorkTable application, orchestrating the complete Camila-based build pipeline.

---

## Script: build-win-local-php-server.sh

### Purpose  
Builds a self-contained PHP server environment for Windows, using either the PHP built-in server or an Nginx + PHP setup.  
The script downloads PHP (Windows binaries), optionally downloads Nginx (Windows binaries), applies templates, and configures `php.ini` and helper scripts.

### Usage
```bash
./build-win-local-php-server.sh <php_version> [lang] [nginx_version]
```

### Arguments
- **php_version** (required)  
  PHP version to download, e.g. `8.3.28`.

- **lang** (optional, default: `en`)  
  Supported: `en`, `it`.

- **nginx_version** (optional)  
  If omitted: PHP-only mode.  
  If provided: downloads and configures an Nginx + PHP environment.

---

## Script: build-linux-local-php-server.sh

### Purpose  
Builds a self-contained PHP server environment for Linux, using either the PHP built-in server or an Nginx + PHP-FPM setup.  
Unlike the Windows version, Linux builds compile PHP and optionally Nginx from source.

### Usage
```bash
./build-linux-local-php-server.sh <php_version> [lang] [nginx_version]
```

### Arguments
- **php_version** (required)  
  PHP version to compile, e.g. `8.3.28`.

- **lang** (optional, default: `en`)  
  Supported: `en`, `it`.

- **nginx_version** (optional)  
  If omitted: PHP-only mode.  
  If provided: compile and configure Nginx + PHP-FPM.

---

## Script: build-worktable-app.sh

### Purpose  
Builds the WorkTable application based on the **Camila PHP Framework**.  
The script performs the entire build workflow: validates commands, prepares server, installs framework, installs template, installs/init plugins, sets config vars, packages output.

### Usage
```bash
./build-worktable-app.sh [BUILD_TYPE] [APP_ID] [LOCALE] [APP_NAME] [APP_TITLE] [APP_GROUP] [PLUGIN_NAMES] [DB_DSN]
```

### Arguments (summary)

- **BUILD_TYPE**: `win-local-php`, `win-local-nginx`, `linux-local-php`, `linux-local-nginx`, `remote`
- **APP_ID**: default `worktable`
- **LOCALE**: `en`, `it`
- **APP_NAME**
- **APP_TITLE**
- **APP_GROUP**
- **PLUGIN_NAMES**: comma-separated plugin names  
  Example:  
  For repo `camila-php-framework-app-plugin-example`, plugin name is:  
  `example`
- **DB_DSN**

---

# Example: Downloading and Running a Local PHP Server

## 1. Download ZIP
```bash
wget https://github.com/linkingtechnologies/peichp/archive/refs/heads/main.zip -O peichp.zip
```

## 2. Unzip
```bash
unzip peichp.zip
cd peichp-main
```

## 3. Make scripts executable
```bash
chmod +x *.sh
```

## 4. Build server (Linux recommended)
```bash
./build-linux-local-php-server.sh 8.3.28 en
```

## 5. Run server
```bash
cd build
./start_server_8080.sh
```

Visit:
```
http://localhost:8080
```

## 6. Stop server
```bash
./stop_server.sh
```

---

# Notes

### Common to Windows & Linux build scripts

- PHP extensions required by the Camila Framework are auto-enabled, detected from:  
  https://github.com/linkingtechnologies/camila-php-framework/blob/master/composer.json

- Both scripts override `php.ini` with fixed values:
  - `error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE & ~E_WARNING`
  - `display_errors = On`
  - `max_execution_time = 900`
  - `max_input_vars = 100000`
  - `extension_dir = "ext"`
  - `upload_max_filesize = 10M`
  - `date.timezone = "Europe/London"`
  - `memory_limit = 256M`

### Windows-specific
- Uses `RunHiddenConsole.exe`  
- PHP and Nginx downloaded as **binaries**

### Linux-specific
- PHP and Nginx **compiled from source**

---

# Troubleshooting

Permissions:
```bash
chmod +x build-win-local-php-server.sh
```

Convert Windows line endings:
```bash
dos2unix build-win-local-php-server.sh
```
