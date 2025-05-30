# Another Home Backup Tool

> **Available languages**: [English (current)](README.md) | [Italiano](README.it.md)

A simple bash script to backup essential files from your home directory.

## Features

- Creates a compressed tar archive of your home directory
- Focuses only on essential files and directories
- Excludes caches, logs, and other unnecessary files
- Names backups with your username and current date
- Allows specifying a custom backup destination
- If no destination is provided, saves to ~/backup/

## Usage

```bash
./another_home_backup_tool.sh [destination_path]
```

Examples:
```bash
./another_home_backup_tool.sh                      # Save to ~/backup/
./another_home_backup_tool.sh /path/to/backups/    # Save to specified directory
```

## Customizing the Backup

You can customize which directories and files are included in the backup by modifying the `ESSENTIAL_DIRS` array in the script. Additionally, you can modify the exclusion patterns in the script to suit your needs.

## Requirements

- Bash shell
- tar command (installed by default on most Linux systems)

## License

This project is licensed under Creative Commons Attribution-NonCommercial 4.0 International License - see the [LICENSE](../LICENSE) file in the parent directory for details.

---

This script is part of the [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools) collection.
