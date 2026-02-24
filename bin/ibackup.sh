#!/bin/bash

# ==========================================
# iToolkit: ibackup
# A simple wrapper for idevicebackup2
# ==========================================

# 1. Help Function
function show_help() {
    echo "Usage: ibackup [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Description:"
    echo "  Performs a full interactive backup of the connected iPhone using idevicebackup2."
    echo "  Requires configuration in a .env file."
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# 2. Load Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Look for .env in current dir or parent dir
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
elif [ -f "$PARENT_DIR/.env" ]; then
    source "$PARENT_DIR/.env"
else
    echo "Error: .env configuration file not found."
    echo "Please create a .env file based on .env.example"
    exit 1
fi

# 3. Validation Checks & OS Detection
OS_TYPE=$(uname -s)

if [ -z "$IPHONE_BACKUP_PATH" ]; then
    echo "Error: IPHONE_BACKUP_PATH is not set in your .env file."
    exit 1
fi

# Define dependencies based on OS
if [[ "$OS_TYPE" == "Darwin" ]]; then
    DEPS="idevicebackup2 idevice_id"
    INSTALL_CMD="brew install libimobiledevice"
else
    DEPS="idevicebackup2 idevice_id"
    INSTALL_CMD="sudo dnf install libimobiledevice"
fi

for cmd in $DEPS; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: '$cmd' is not installed."
        echo "To install: $INSTALL_CMD"
        exit 1
    fi
done

# Ensure directory exists
if [ ! -d "$IPHONE_BACKUP_PATH" ]; then
    echo "Directory not found. Creating $IPHONE_BACKUP_PATH..."
    mkdir -p "$IPHONE_BACKUP_PATH"
fi

# 4. Device Detection
if [ -z "$IPHONE_UDID" ]; then
    echo "Detecting connected devices..."
    IPHONE_UDID=$(idevice_id -l | head -n1)
fi

if [ -z "$IPHONE_UDID" ]; then
    echo "Error: No iPhone found. Please connect your device via USB."
    exit 1
fi

# 5. Execution
echo "---------------------------------------------------"
echo "Starting backup for device: $IPHONE_UDID"
echo "Destination: $IPHONE_BACKUP_PATH"
echo "---------------------------------------------------"

# Execute backup
idevicebackup2 -u "$IPHONE_UDID" backup --full --interactive "$IPHONE_BACKUP_PATH"

# Check success
if [ $? -eq 0 ]; then
    echo "---------------------------------------------------"
    echo "✅ Backup completed successfully!"
else
    echo "---------------------------------------------------"
    echo "❌ Backup failed. Check connection or trust settings."
    exit 1
fi