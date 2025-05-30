#!/bin/bash

# another_home_backup_tool.sh
# A script to backup essential files from a user's home directory
# Creates a tar.gz archive with format: home_username_date.tar.gz

# Show usage information
show_usage() {
  echo "Usage: $0 [destination_path]"
  echo ""
  echo "This script creates a backup of essential files from your home directory."
  echo "If destination_path is provided, the backup will be saved there."
  echo "Otherwise, it will be saved to a 'backup' folder in your home directory."
  echo ""
  echo "Examples:"
  echo "  $0                      # Save to ~/backup/"
  echo "  $0 /path/to/backups/    # Save to specified directory"
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_usage
  exit 0
fi

# Get username and date for the filename
USERNAME=$(whoami)
CURRENT_DATE=$(date +"%Y%m%d")
BACKUP_FILENAME="home_${USERNAME}_${CURRENT_DATE}.tar.gz"

# Determine backup destination
if [ -n "$1" ]; then
  # Use user-provided destination
  DESTINATION="$1"
  # Make sure destination ends with a slash
  [[ "${DESTINATION}" != */ ]] && DESTINATION="${DESTINATION}/"
  
  # Check if destination directory exists, if not create it
  if [ ! -d "$DESTINATION" ]; then
    echo "Creating destination directory $DESTINATION"
    mkdir -p "$DESTINATION" || { echo "Error: Cannot create destination directory"; exit 1; }
  fi
else
  # Use default destination: ~/backup/
  DESTINATION="${HOME}/backup/"
  
  # Create backup directory if it doesn't exist
  if [ ! -d "$DESTINATION" ]; then
    echo "Creating backup directory $DESTINATION"
    mkdir -p "$DESTINATION" || { echo "Error: Cannot create backup directory"; exit 1; }
  fi
fi

BACKUP_PATH="${DESTINATION}${BACKUP_FILENAME}"

echo "Starting backup of essential files from $HOME to $BACKUP_PATH"

# Define essential directories and files to backup
# Add or remove entries as needed
ESSENTIAL_DIRS=(
  # Configuration directories
  ".config"
  ".local/share"
  ".ssh"
  
  # Common document directories
  "Documents"
  "Pictures"
  
  # Shell configurations
  ".bashrc"
  ".bash_profile"
  ".profile"
  ".zshrc"
)

# Use temporary file for exclusion patterns
EXCLUDE_FILE=$(mktemp)

# Define patterns to exclude
cat > "$EXCLUDE_FILE" << EOF
# Exclude cache and temporary files
*.cache
*cache*
*.tmp
*.temp
*tmp*
*temp*

# Exclude package manager caches
*node_modules*
*.npm*
*.pip*
*.yarn*

# Exclude version control directories
*.git*
*.svn*

# Exclude large media files
*.mp4
*.mov
*.avi
*.mkv
*.iso
*.dmg

# Exclude log files
*.log
*logs*

# Exclude browser data
*/Google/Chrome/*
*/BraveSoftware/*
*/Mozilla/Firefox/*
*/chromium/*

# Application caches
*/.config/*/Cache*
*/.var/app/*/cache*
EOF

# Create the backup using tar
# -c: create archive
# -z: compress with gzip
# -f: specify filename
# -C: change to directory
# --exclude-from: use exclude patterns from file
# -v: verbose output

echo "Creating backup archive..."
tar -czf "$BACKUP_PATH" \
    -C "$HOME" \
    --exclude-from="$EXCLUDE_FILE" \
    "${ESSENTIAL_DIRS[@]}" \
    2> >(grep -v "Removing leading" >&2)

# Check if backup was successful
if [ $? -eq 0 ]; then
  echo "Backup completed successfully!"
  echo "Backup saved to: $BACKUP_PATH"
  echo "Backup size: $(du -h "$BACKUP_PATH" | cut -f1)"
else
  echo "Error: Backup failed!"
fi

# Clean up temporary file
rm "$EXCLUDE_FILE"

exit 0
# End of script