# Another One Bites the Dust

> **Available languages**: [English (current)](README.md) | [Italiano](README.it.md)

A comprehensive system cleaning utility that automatically identifies and removes old, unnecessary files to free up disk space.

> **⚠️ WARNING**: This script permanently deletes files from your system. Always run in dry-run mode first to review what will be deleted. The authors are not responsible for any data loss that may occur from using this tool. Use at your own risk.

> **⚠️ NOTE**: Administrator privileges (sudo) are required to clean package manager caches. When cleaning system directories like /var/cache or package manager caches, run the script with sudo.

## Features

- **Multi-target cleaning**: scans and cleans various system directories including cache, logs, temporary files, trash, and package manager caches
- **Smart backup removal**: identifies and removes old backup files based on configurable age thresholds
- **Dry-run mode**: preview what would be deleted before making any changes
- **Interactive mode**: confirm each cleaning operation before execution
- **Detailed logging**: all operations are logged for audit and reference
- **Package manager support**: specialized cleaning for APT, DNF, Pacman, and Nix package managers
- **Browser cache cleaning**: support for Firefox and Chrome browser cache cleanup
- **Docker cleanup**: removes unused Docker containers, images, networks, and volumes to reclaim disk space
- **Configurable age thresholds**: set different age thresholds for each type of file
- **Hidden surprises**: contains a hidden Easter egg for the curious minds. Can you find it?

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/palumbou/another_bucket_of_tools.git
   ```

2. Make the script executable:
   ```bash
   chmod u+x another_bucket_of_tools/another_one_bites_the_dust/another_one_bites_the_dust.sh
   ```

3. Run the script:
   ```bash
   cd another_bucket_of_tools/another_one_bites_the_dust
   ./another_one_bites_the_dust.sh
   ```

## Usage

```bash
./another_one_bites_the_dust.sh [options]
```

### Options

- `-d, --dry-run`: show what would be deleted without actually deleting
- `-v, --verbose`: show detailed information during execution
- `-n, --non-interactive`: run without asking for confirmation (use with caution)
- `-t, --target DIR`: set target directory (default: $HOME)
- `-l, --log FILE`: set log file location
- `-h, --help`: display help message and exit

### Examples

```bash
# Dry run with detailed output
./another_one_bites_the_dust.sh --dry-run --verbose

# Clean a specific directory non-interactively
./another_one_bites_the_dust.sh --target /home/username --non-interactive

# Show help information
./another_one_bites_the_dust.sh --help
```

## Configuration

The script reads configuration from `env.conf` in the same directory. You can modify this file to customize:

- Age thresholds for different types of files
- Additional directories to clean
- File patterns to exclude

Example configuration:

```bash
# Age in days for different types of files
CACHE_AGE=30
LOG_AGE=30
TEMP_AGE=7
TRASH_AGE=30
BACKUP_AGE=90

# Additional directories to clean (space-separated)
# Format: path:age_in_days
ADDITIONAL_DIRS="/home/user/projects/temp:14 /var/tmp/builds:7"

# File patterns to exclude (space-separated)
EXCLUDE_PATTERNS=".mozilla .config/google-chrome"
```

## License

This project is licensed under Creative Commons Attribution-NonCommercial 4.0 International License - see the [LICENSE](../LICENSE) file in the parent directory for details.

---

This script is part of the [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools) collection.