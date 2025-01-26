# PHP Environment Setup Scripts

This repository contains multiple Bash scripts that automate the creation and configuration of environments for running PHP scripts.

While the examples provided use WSL (Windows Subsystem for Linux), any Linux environment can be used to run scripts.

## Table of Contents

1. [Scripts Index](#scripts-index)
2. [Script: build-win-local-php-server.sh](#script-build-win-local-php-server.sh)
   - [Prerequisites](#prerequisites)
   - [Usage](#usage)
     - [Example Usage](#example-usage)
     - [Parameters](#parameters)
   - [Output Structure](#output-structure)
   - [Notes](#notes)
   - [Troubleshooting](#troubleshooting)

## Scripts Index

- `build-win-local-php-server.sh` - Automates the installation of a standalone Windows PHP environment with or without Nginx.

## Script: build-win-local-php-server.sh

### Prerequisites

Ensure that the following dependencies are installed on your Linux environment:

- `wget`
- `unzip`
- `sed`
- `jq`

If any of the above tools are missing, you can install them using the following command:

```bash
sudo apt update && sudo apt install -y wget unzip sed jq
```

### Usage

To run the script, open a terminal and execute the following command:

```bash
./build-win-local-php-server.sh <php_version> [nginx_version]
```

#### Example Usage

1. Running PHP without Nginx:

   ```bash
   ./build-win-local-php-server.sh 8.3.16
   ```

2. Running PHP with Nginx:

   ```bash
   ./build-win-local-php-server.sh 8.3.16 1.27.3
   ```

#### Parameters

- `<php_version>` (required): Specify the desired PHP version (e.g., 8.3.16).
- `[nginx_version]` (optional): Specify the Nginx version (e.g., `1.27.3`). If omitted, the script will use PHP's built-in server.

### Output Structure

After running the script, the `build` folder will also contain scripts to start and stop the service:

- `start_server.bat` - A script to start the PHP server.
- `stop_server.bat` - A script to stop the PHP server.

These scripts simplify the process of managing the PHP environment on a Windows system.

### Notes

- The script uses `RunHiddenConsole.exe` to hide the Windows console when starting services.

- The script downloads PHP and Nginx from their official sources.

- PHP extensions required by the project (from `composer.json`) will be automatically enabled.

- Various PHP settings, such as `display_errors`, `max_execution_time`, and `memory_limit`, will be adjusted for development purposes.

### Troubleshooting

If the script does not execute, ensure it has the appropriate permissions:

```bash
chmod +x build-win-local-php-server.sh
```

If you encounter issues related to file format, especially after downloading from Windows, convert the script using:

```bash
dos2unix build-win-local-php-server.sh
```

If you encounter any issues, check the log output for error messages and verify dependencies are installed correctly.

---

**Enjoy coding with your PHP environment!**
