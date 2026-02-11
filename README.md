# iToolkit 📱🚀

**iToolkit** is a set of open-source shell utilities designed for macOS to help you easily backup your iPhone and import/organize your photos without relying on proprietary software like iTunes or Photos.app.

## Features

- **ibackup**: A clean wrapper for `idevicebackup2` to perform full, interactive backups of your iPhone.
- **iphoto-import**: Syncs photos from your iPhone and organizes them into a `Year/Month` folder structure using **hardlinks** (to save disk space while keeping your backup mirror intact).
- **HEIC to JPG Conversion**: Optional auto-conversion of HEIC images to JPG during import.

## Prerequisites

You need the following tools installed on your Mac:

```bash
brew install libimobiledevice ifuse rsync
```

- `libimobiledevice`: For communication with iOS devices.
- `ifuse`: For mounting the iPhone filesystem.
- `rsync`: For efficient file syncing.
- `sips`: (Pre-installed on macOS) For image conversion.

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/iToolkit.git
   cd iToolkit
   ```

2. Create your configuration file:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and set your desired paths.

## Usage

### 1. Full iPhone Backup
To perform a full backup of your device:
```bash
./bin/ibackup.sh
```

### 2. Photo Import & Organization
To sync photos and organize them by date:
```bash
./bin/iphoto-import.sh
```

## How It Works (Photo Organization)
The `iphoto-import` tool performs a two-phase process:
1. **Mirror**: It creates an exact copy of your iPhone's `DCIM` folder on your local drive.
2. **Organize**: It scans the mirror and creates a separate folder structure (`YYYY/MM`). Instead of copying files again, it uses **Hardlinks**. This means you can see your photos in two different ways (the original mirror and the organized view) without using double the disk space.

## Contributing
Feel free to open issues or submit pull requests to improve these tools!

## License
MIT
