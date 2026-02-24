#!/bin/bash

# ==========================================
# iToolkit: iphoto-import
# iPhone Photo Import & Organize Tool
# ==========================================

# 1. Help Function
function show_help() {
    echo "Usage: iphoto-import [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Description:"
    echo "  Syncs photos from a connected iPhone and organizes them into folders"
    echo "  by Year/Month using hardlinks (saves space)."
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

# 3. Dependency Check & OS Detection
OS_TYPE=$(uname -s)

# Define dependencies based on OS
if [[ "$OS_TYPE" == "Darwin" ]]; then
    DEPS="ifuse rsync sips"
    INSTALL_CMD="brew install rsync ifuse"
else
    DEPS="ifuse rsync mogrify"
    INSTALL_CMD="sudo dnf install rsync ifuse ImageMagick"
fi

for cmd in $DEPS; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: '$cmd' is not installed."
        echo "To install: $INSTALL_CMD"
        exit 1
    fi
done

# 4. Directories
BACKUP_MIRROR="$PHOTO_DESTINATION/Backup_Mirror"
ORGANIZED_VIEW="$PHOTO_DESTINATION/Organized_Photos"

# Ensure directories exist
if [ ! -d "$IPHONE_MOUNT_POINT" ]; then mkdir -p "$IPHONE_MOUNT_POINT"; fi
if [ ! -d "$BACKUP_MIRROR" ]; then mkdir -p "$BACKUP_MIRROR"; fi
if [ ! -d "$ORGANIZED_VIEW" ]; then mkdir -p "$ORGANIZED_VIEW"; fi

# 5. Smart Mount Function
function mount_iphone() {
    if mount | grep -q "$IPHONE_MOUNT_POINT"; then
        echo "✅ iPhone is already mounted."
        return 0
    fi
    
    echo "Attempting to mount iPhone..."
    mkdir -p "$IPHONE_MOUNT_POINT"
    ifuse "$IPHONE_MOUNT_POINT"
    
    # Wait up to 5 seconds for mount to appear
    for i in {1..5}; do
        if mount | grep -q "$IPHONE_MOUNT_POINT"; then
            echo "✅ Mount successful."
            return 0
        fi
        sleep 1
    done
    
    echo "❌ Mount failed. Please unlock your iPhone and try again."
    return 1
}

# 6. Core Logic
if ! mount_iphone; then
    echo "Could not mount iPhone at $IPHONE_MOUNT_POINT"
    exit 1
fi

echo "---------------------------------------------------"
echo "Phase 1: Syncing to Backup Mirror..."
echo "---------------------------------------------------"
echo "Syncing from $IPHONE_MOUNT_POINT/DCIM/ to $BACKUP_MIRROR/"
rsync -av --progress --ignore-existing --exclude=".DS_Store" \
    "$IPHONE_MOUNT_POINT/DCIM/" "$BACKUP_MIRROR/"

if [ $? -ne 0 ]; then
    echo "❌ Rsync failed. Check connection."
    exit 1
fi

echo "---------------------------------------------------"
echo "Phase 2: Organizing Photos (Hardlinks)..."
echo "---------------------------------------------------"

echo "Scanning $BACKUP_MIRROR for photos..."
find "$BACKUP_MIRROR" -type f -not -name ".*" | while read -r file; do
    FILENAME=$(basename "$file")
    
    # Get modification year and month (YYYY/MM)
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        DATE_PATH=$(stat -f "%Sm" -t "%Y/%m" "$file")
    else
        # GNU stat on Linux
        DATE_PATH=$(stat -c "%y" "$file" | cut -d'-' -f1,2 | tr '-' '/')
    fi
    
    TARGET_DIR="$ORGANIZED_VIEW/$DATE_PATH"
    TARGET_FILE="$TARGET_DIR/$FILENAME"
    
    mkdir -p "$TARGET_DIR"
    
    # Create Hardlink if it doesn't exist
    if [ ! -f "$TARGET_FILE" ]; then
        ln "$file" "$TARGET_FILE"
    fi
done
echo "✅ Organization complete."

echo "---------------------------------------------------"
echo "Phase 3: Optional HEIC Conversion"
echo "---------------------------------------------------"
read -p "Do you want to convert HEIC photos to JPG in the Organized folder? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Converting HEIC images..."
    find "$ORGANIZED_VIEW" \( -name "*.HEIC" -o -name "*.heic" \) | while read -r file; do
        jpg_file="${file%.*}.JPG"
        if [ ! -f "$jpg_file" ]; then
            echo "Converting $(basename "$file")..."
            if [[ "$OS_TYPE" == "Darwin" ]]; then
                sips -s format jpeg -s formatOptions 80 "$file" --out "$jpg_file" &>/dev/null
            else
                # Using ImageMagick on Linux
                convert "$file" -quality 80 "$jpg_file" &>/dev/null
            fi
        fi
    done
    echo "✅ Conversion complete."
fi

# 7. Cleanup
echo "---------------------------------------------------"
echo "Unmounting iPhone..."
if [[ "$OS_TYPE" == "Darwin" ]]; then
    umount "$IPHONE_MOUNT_POINT"
else
    # fusermount is safer for FUSE mounts on Linux
    fusermount -u "$IPHONE_MOUNT_POINT" || umount "$IPHONE_MOUNT_POINT"
fi
echo "✨ All operations complete. Check $ORGANIZED_VIEW"