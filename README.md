# iToolkit 📱🚀

**iToolkit** is a set of open-source shell utilities designed for macOS to help you easily backup your iPhone and import/organize your photos without relying on proprietary software like iTunes or Photos.app.

## Features

- **ibackup**: A clean wrapper for `idevicebackup2` to perform full, interactive backups of your iPhone.
- **iphoto-import**: Syncs photos from your iPhone and organizes them into a `Year/Month` folder structure using **hardlinks** (to save disk space while keeping your backup mirror intact).
- **HEIC to JPG Conversion**: Optional auto-conversion of HEIC images to JPG during import.

---

## 🛠 macOS Setup Guide

Setting up `ifuse` on modern macOS can be tricky. Follow these steps for a smooth installation:

### 1. Install macFUSE
`ifuse` requires a FUSE kernel extension. Download and install the latest version of **macFUSE** from [osxfuse.github.io](https://osxfuse.github.io/).

> [!IMPORTANT]
> Since macOS High Sierra, you must manually allow the kernel extension in **System Settings > Privacy & Security**. You may need to restart your Mac.

### 2. Install Dependencies
Install the required command-line tools via Homebrew:

```bash
brew install libimobiledevice rsync
```

### 3. Install ifuse using the included Tap
Since `ifuse` was removed from the Homebrew core tap, this repository includes a local copy of the `homebrew-fuse` tap to simplify installation.

From the project root, run:
```bash
# Register the local tap
brew tap gromgit/fuse ./homebrew-fuse

# Install ifuse-mac
brew install ifuse-mac
```

---

## 🚀 Installation & Configuration

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/iToolkit.git
   cd iToolkit
   ```

2. **Setup your environment**:
   ```bash
   cp .env.example .env
   ```

3. **Edit `.env`**:
   Set your desired paths for backups and photo organization.
   - `IPHONE_BACKUP_PATH`: Where full backups will sit.
   - `PHOTO_DESTINATION`: Where your photos will be imported and organized.
   - `IPHONE_MOUNT_POINT`: A folder where the iPhone's filesystem will be mounted (e.g., `~/mnt/iphone`).

---

## 📖 Usage

Before running any script, connect your iPhone via USB and **"Trust This Computer"** when prompted on the device.

### 1. Full iPhone Backup
To perform a full device backup:
```bash
./bin/ibackup.sh
```

### 2. Photo Import & Organization
This tool automates mounting, syncing, and organizing your photos. 
```bash
./bin/iphoto-import.sh
```

**How it works:**
1. **Mounts**: Automatically mounts your iPhone to the path specified in `.env`.
2. **Mirror Phase**: Creates an exact copy of the `DCIM` folder on your local drive.
3. **Organize Phase**: Scans the mirror and creates a `YYYY/MM` structure using **Hardlinks**. This keeps your photos organized without using double the disk space!
4. **Cleanup**: Gracefully unmounts the device when finished.

---

## 📂 Project Structure

- `bin/`: The executable shell scripts.
- `homebrew-fuse/`: Local Homebrew tap for FUSE formulae.
- `.env`: Your local configuration (ignored by git).

## 💡 Troubleshooting

- **"Mount failed"**: Ensure your iPhone is unlocked and you have tapped "Trust" on the screen.
- **"Permission denied" (FUSE)**: Ensure macFUSE is properly allowed in System Settings.
- **Script permissions**: If the scripts won't run, try `chmod +x bin/*.sh`.

---

## Contributing
Feel free to open issues or submit pull requests to improve these tools!

## License
MIT

