#!/bin/bash

# WARNING: This script permanently deletes files from your system. 
# Always run in dry-run mode first to review what will be deleted.
# The authors are not responsible for any data loss that may occur from using this tool.
# Use at your own risk.

# Default color definitions for better output readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Initial variable definitions
BIANCA_EDITION=false

# Easter Egg: Check if "Bianca" is an argument to enable pink theme
# First, save all arguments in an array for processing
args=("$@")
# Create a new array to hold all arguments except "Bianca"
new_args=()
# Flag to track if Bianca argument was found
BIANCA_FOUND=false

for arg in "${args[@]}"; do
    if [[ "$arg" == "Bianca" ]]; then
        # Color definitions for pink theme
        LIGHT_PINK='\033[1;38;5;218m'    # Light pink
        HOT_PINK='\033[1;38;5;198m'      # Hot pink
        PASTEL_PINK='\033[1;38;5;225m'   # Pastel pink
        DEEP_PINK='\033[1;38;5;199m'     # Deep pink
        PINK='\033[1;38;5;213m'          # Regular pink
        MAGENTA='\033[1;35m'             # Magenta
        
        # Override standard colors with pink variants
        RED=$HOT_PINK
        GREEN=$LIGHT_PINK
        YELLOW=$PASTEL_PINK
        BLUE=$PINK
        PURPLE=$MAGENTA
        CYAN=$DEEP_PINK
        
        # Set Bianca Edition flag
        BIANCA_EDITION=true
        BIANCA_FOUND=true
    else
        # Add non-"Bianca" arguments to the new arguments array
        new_args+=("$arg")
    fi
done

# If Bianca was found, replace original arguments with filtered ones
if [ "$BIANCA_FOUND" = true ]; then
    set -- "${new_args[@]}"
fi

# Config file location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/env.conf"

# Default values
DRY_RUN=false
VERBOSE=false
INTERACTIVE=true
LOG_FILE="$SCRIPT_DIR/cleanup_log_$(date +"%Y%m%d_%H%M%S").log"
TARGET_DIR="$HOME"
CACHE_AGE=30
LOG_AGE=30
TEMP_AGE=7
TRASH_AGE=30
BACKUP_AGE=90

# Variables to track space usage
TOTAL_SPACE_RECOVERED=0
INITIAL_DISK_SPACE=""
FINAL_DISK_SPACE=""
SPACE_RECOVERED_BY_OPERATION=()

# Function to display banner
show_banner() {
    echo -e "${YELLOW}"
    echo "  █████╗ ███╗   ██╗ ██████╗ ████████╗██╗  ██╗███████╗██████╗      ██████╗ ███╗   ██╗███████╗"
    echo " ██╔══██╗████╗  ██║██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗    ██╔═══██╗████╗  ██║██╔════╝"
    echo " ███████║██╔██╗ ██║██║   ██║   ██║   ███████║█████╗  ██████╔╝    ██║   ██║██╔██╗ ██║█████╗  "
    echo " ██╔══██║██║╚██╗██║██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗    ██║   ██║██║╚██╗██║██╔══╝  "
    echo " ██║  ██║██║ ╚████║╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║    ╚██████╔╝██║ ╚████║███████╗"
    echo " ╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝"
    echo "                                                                                           "
    echo " ██████╗ ██╗████████╗███████╗███████╗    ████████╗██╗  ██╗███████╗    ██████╗ ██╗   ██╗███████╗████████╗"
    echo " ██╔══██╗██║╚══██╔══╝██╔════╝██╔════╝    ╚══██╔══╝██║  ██║██╔════╝    ██╔══██╗██║   ██║██╔════╝╚══██╔══╝"
    echo " ██████╔╝██║   ██║   █████╗  ███████╗       ██║   ███████║█████╗      ██║  ██║██║   ██║███████╗   ██║   "
    echo " ██╔══██╗██║   ██║   ██╔══╝  ╚════██║       ██║   ██╔══██║██╔══╝      ██║  ██║██║   ██║╚════██║   ██║   "
    echo " ██████╔╝██║   ██║   ███████╗███████║       ██║   ██║  ██║███████╗    ██████╔╝╚██████╔╝███████║   ██║   "
    echo " ╚═════╝ ╚═╝   ╚═╝   ╚══════╝╚══════╝       ╚═╝   ╚═╝  ╚═╝╚══════╝    ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝   "
    echo -e "${NC}"
    echo -e "${CYAN}                       System Cleaning Utility - Version 1.0.0${NC}"
    if [ "$BIANCA_EDITION" = true ]; then
        echo -e "${PINK}                              ✧･ﾟ: *✧･ﾟ:* Bianca Edition *:･ﾟ✧*:･ﾟ✧${NC}"
    fi
    echo
}

# Function to display help
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -d, --dry-run        Show what would be deleted without actually deleting"
    echo "  -v, --verbose        Show detailed information during execution"
    echo "  -n, --non-interactive Run without asking for confirmation (use with caution)"
    echo "  -t, --target DIR     Set target directory (default: $HOME)"
    echo "  -l, --log FILE       Set log file location (default: script_dir/cleanup_log_date.log)"
    echo "  -h, --help           Display this help message and exit"
    echo
    echo "Configuration options (can be set in env.conf):"
    echo "  CACHE_AGE            Age in days for cache files (default: 30)"
    echo "  LOG_AGE              Age in days for log files (default: 30)"
    echo "  TEMP_AGE             Age in days for temporary files (default: 7)"
    echo "  TRASH_AGE            Age in days for trash files (default: 30)"
    echo "  BACKUP_AGE           Age in days for backup files (default: 90)"
    echo
    echo "Examples:"
    echo "  $0 --dry-run --verbose"
    echo "  $0 --target /home/username --non-interactive"
    echo "  $0 -d -v -t /var"
}

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    local color=""
    
    case "$level" in
        "INFO")  color="$BLUE" ;;
        "WARN")  color="$YELLOW" ;;
        "ERROR") color="$RED" ;;
        "SUCCESS") color="$GREEN" ;;
        *) color="$NC" ;;
    esac
    
    if $VERBOSE || [ "$level" == "ERROR" ] || [ "$level" == "WARN" ] || [ "$level" == "SUCCESS" ]; then
        echo -e "${color}[$level] $message${NC}"
    fi
    
    # Always log to file regardless of verbose setting
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] [$level] $message" >> "$LOG_FILE"
}

# Function to check for administrator privileges
check_admin_privileges() {
    if [ "$(id -u)" -ne 0 ]; then
        return 1  # Not running as admin
    else
        return 0  # Running as admin
    fi
}

# Function to display administrator privileges warning
show_admin_warning() {
    local operation="$1"
    echo -e "\n${YELLOW}===== ADMINISTRATOR PRIVILEGES WARNING =====${NC}"
    echo -e "${RED}$operation requires administrator privileges.${NC}"
    echo -e "${RED}You are currently NOT running this script as administrator.${NC}"
    echo -e "${YELLOW}Run the script with sudo to properly perform this operation.${NC}\n"
}

# Load configuration from env.conf if it exists
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log_message "INFO" "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        log_message "WARN" "Configuration file not found, using default values"
        
        # Display the warning from the header when env.conf is not found
        echo -e "\n${RED}!!!!! WARNING !!!!!"
        echo "This script permanently deletes files from your system."
        echo "Always run in dry-run mode first to review what will be deleted."
        echo "The authors are not responsible for any data loss that may occur from using this tool."
        echo -e "Use at your own risk.${NC}\n"
        
        # Ask user to confirm
        if confirm_action "Do you understand the risks and wish to continue?" "n"; then
            # Create a default config file
            cat > "$CONFIG_FILE" << EOL
# Another One Bites the Dust Configuration
# Modify these values to customize the cleanup process

# Age in days for different types of files
CACHE_AGE=30
LOG_AGE=30
TEMP_AGE=7
TRASH_AGE=30
BACKUP_AGE=90

# Additional directories to clean (space-separated)
# Format: path:age_in_days
ADDITIONAL_DIRS=""

# File patterns to exclude (space-separated)
EXCLUDE_PATTERNS=".mozilla .config/google-chrome"
EOL
            log_message "INFO" "Created default configuration file at $CONFIG_FILE"
        else
            log_message "INFO" "User aborted operation"
            exit 0
        fi
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--non-interactive)
                INTERACTIVE=false
                shift
                ;;
            -t|--target)
                TARGET_DIR="$2"
                shift
                shift
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift
                shift
                ;;
            -h|--help)
                show_banner
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Function to ask for confirmation
confirm_action() {
    local message="$1"
    local default="$2"
    
    if ! $INTERACTIVE; then
        return 0
    fi
    
    local prompt
    if [ "$default" = "y" ]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    read -p "$message $prompt " answer
    
    if [ -z "$answer" ]; then
        answer="$default"
    fi
    
    if [[ "$answer" =~ ^[yY]$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to get size of a directory or file
get_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

# Function to get disk space in bytes for a directory
get_disk_usage_bytes() {
    local dir="$1"
    if [ -d "$dir" ] || [ -f "$dir" ]; then
        du -sb "$dir" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

# Function to capture space before operation
measure_space_before_operation() {
    local dir="$1"
    local operation="$2"
    
    if [ -d "$dir" ] || [ -f "$dir" ]; then
        local size_before=$(get_disk_usage_bytes "$dir")
        echo "$size_before"
    else
        echo "0"
    fi
}

# Function to capture space after operation and calculate difference
measure_space_after_operation() {
    local dir="$1"
    local operation="$2"
    local size_before="$3"
    
    if $DRY_RUN; then
        return
    fi
    
    if [ -d "$dir" ] || [ -f "$dir" ]; then
        local size_after=$(get_disk_usage_bytes "$dir")
        local bytes_recovered=$((size_before - size_after))
        
        if [ $bytes_recovered -gt 0 ]; then
            # Convert to human-readable format
            local hr_size=$(numfmt --to=iec-i --suffix=B --format="%.2f" $bytes_recovered)
            log_message "SUCCESS" "$operation: Recovered $hr_size"
            SPACE_RECOVERED_BY_OPERATION+=("$operation: $hr_size")
            TOTAL_SPACE_RECOVERED=$((TOTAL_SPACE_RECOVERED + bytes_recovered))
        fi
    fi
}

# Function to clean cache files
clean_cache() {
    log_message "INFO" "Checking for cache files older than $CACHE_AGE days..."
    
    # Common cache directories
    local cache_dirs=(
        "$HOME/.cache"
        "/var/cache"
        "$HOME/.thumbnails"
    )
    
    for dir in "${cache_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local size=$(get_size "$dir")
            log_message "INFO" "Checking $dir (Size: $size)"
            
            # Measure space before cleanup
            local size_before=$(measure_space_before_operation "$dir" "Cache cleanup")
            
            # Check if admin privileges are needed for this directory
            local needs_admin=false
            if [[ "$dir" == "/var/cache" || "$dir" == "/var/"* ]]; then
                needs_admin=true
            fi
            
            # Find old files
            if $DRY_RUN; then
                local files=$(find "$dir" -type f -mtime +"$CACHE_AGE" -not -path "*/\.*" 2>/dev/null)
                if [ -n "$files" ]; then
                    log_message "INFO" "Would remove old cache files from $dir"
                    if $needs_admin && ! check_admin_privileges; then
                        log_message "WARN" "Would need administrator privileges to clean $dir"
                    fi
                fi
            else
                if confirm_action "Clean old cache files from $dir?" "y"; then
                    log_message "INFO" "Removing old cache files from $dir"
                    
                    # Check if user has admin privileges for system directories
                    if $needs_admin; then
                        if ! check_admin_privileges; then
                            show_admin_warning "Cleaning system cache directories ($dir)"
                            log_message "WARN" "Need administrator privileges to clean $dir. Skipping."
                            continue
                        fi
                    fi
                    
                    find "$dir" -type f -mtime +"$CACHE_AGE" -not -path "*/\.*" -delete 2>/dev/null
                    if [ $? -eq 0 ]; then
                        log_message "SUCCESS" "Cleaned old cache files from $dir"
                        # Measure space after cleanup
                        measure_space_after_operation "$dir" "Cache cleanup ($dir)" "$size_before"
                    else
                        log_message "ERROR" "Failed to clean some cache files from $dir"
                    fi
                else
                    log_message "INFO" "Skipping cache cleanup for $dir"
                fi
            fi
        fi
    done
    
    # Browser-specific cache cleanup
    if [ -d "$HOME/.mozilla" ]; then
        log_message "INFO" "Checking Firefox cache"
        local firefox_cache_dir="$HOME/.mozilla"
        local size_before=$(measure_space_before_operation "$firefox_cache_dir" "Firefox cache")
        
        if $DRY_RUN; then
            log_message "INFO" "Would clean Firefox cache"
        else
            if confirm_action "Clean Firefox cache?" "y"; then
                log_message "INFO" "Cleaning Firefox cache"
                find "$HOME/.mozilla" -name "Cache*" -type d -exec rm -rf {} \; 2>/dev/null
                find "$HOME/.mozilla" -name "OfflineCache" -type d -exec rm -rf {} \; 2>/dev/null
                log_message "SUCCESS" "Firefox cache cleaned"
                measure_space_after_operation "$firefox_cache_dir" "Firefox cache" "$size_before"
            fi
        fi
    fi
    
    if [ -d "$HOME/.config/google-chrome" ]; then
        log_message "INFO" "Checking Chrome cache"
        local chrome_cache_dir="$HOME/.config/google-chrome"
        local size_before=$(measure_space_before_operation "$chrome_cache_dir" "Chrome cache")
        
        if $DRY_RUN; then
            log_message "INFO" "Would clean Chrome cache"
        else
            if confirm_action "Clean Chrome cache?" "y"; then
                log_message "INFO" "Cleaning Chrome cache"
                find "$HOME/.config/google-chrome" -name "Cache" -type d -exec rm -rf {} \; 2>/dev/null
                find "$HOME/.config/google-chrome" -name "Media Cache" -type d -exec rm -rf {} \; 2>/dev/null
                log_message "SUCCESS" "Chrome cache cleaned"
                measure_space_after_operation "$chrome_cache_dir" "Chrome cache" "$size_before"
            fi
        fi
    fi
}

# Function to clean log files
clean_logs() {
    log_message "INFO" "Checking for log files older than $LOG_AGE days..."
    
    # Common log directories
    local log_dirs=(
        "/var/log"
        "$HOME/.local/share/xorg"
        "$HOME/.xsession-errors*"
    )
    
    for dir in "${log_dirs[@]}"; do
        if [ -d "$dir" ] || [ -f "$dir" ]; then
            local size=$(get_size "$dir")
            log_message "INFO" "Checking $dir (Size: $size)"
            
            # Measure space before cleanup
            local size_before=$(measure_space_before_operation "$dir" "Log cleanup")
            
            # Check if admin privileges are needed for this directory
            local needs_admin=false
            if [[ "$dir" == "/var/log" || "$dir" == "/var/"* ]]; then
                needs_admin=true
            fi
            
            if [ -d "$dir" ]; then
                # Find old log files
                if $DRY_RUN; then
                    local files=$(find "$dir" -type f -name "*.log*" -o -name "*.old" -mtime +"$LOG_AGE" 2>/dev/null)
                    if [ -n "$files" ]; then
                        log_message "INFO" "Would remove old log files from $dir"
                        if $needs_admin && ! check_admin_privileges; then
                            log_message "WARN" "Would need administrator privileges to clean $dir"
                        fi
                    fi
                else
                    if confirm_action "Clean old log files from $dir?" "y"; then
                        log_message "INFO" "Removing old log files from $dir"
                        
                        # Check if user has admin privileges for system directories
                        if $needs_admin; then
                            if ! check_admin_privileges; then
                                show_admin_warning "Cleaning system log directories ($dir)"
                                log_message "WARN" "Need administrator privileges to clean $dir. Skipping."
                                continue
                            fi
                        fi
                        
                        find "$dir" -type f \( -name "*.log*" -o -name "*.old" \) -mtime +"$LOG_AGE" -delete 2>/dev/null
                        if [ $? -eq 0 ]; then
                            log_message "SUCCESS" "Cleaned old log files from $dir"
                            # Measure space after cleanup
                            measure_space_after_operation "$dir" "Log cleanup ($dir)" "$size_before"
                        else
                            log_message "ERROR" "Failed to clean some log files from $dir"
                        fi
                    else
                        log_message "INFO" "Skipping log cleanup for $dir"
                    fi
                fi
            fi
        fi
    done
}

# Function to clean temporary files
clean_temp() {
    log_message "INFO" "Checking for temporary files older than $TEMP_AGE days..."
    
    # Common temp directories
    local temp_dirs=(
        "/tmp"
        "$HOME/tmp"
        "$HOME/Downloads"
        "$HOME/Downloads/temp"
    )
    
    for dir in "${temp_dirs[@]}"; do
        if [ -d "$dir" ]; then
            local size=$(get_size "$dir")
            log_message "INFO" "Checking $dir (Size: $size)"
            
            # Measure space before cleanup
            local size_before=$(measure_space_before_operation "$dir" "Temporary files")
            
            # Find old temporary files
            if $DRY_RUN; then
                local files=$(find "$dir" -type f -mtime +"$TEMP_AGE" 2>/dev/null)
                if [ -n "$files" ]; then
                    log_message "INFO" "Would remove old temporary files from $dir"
                fi
            else
                if confirm_action "Clean old temporary files from $dir?" "y"; then
                    log_message "INFO" "Removing old temporary files from $dir"
                    find "$dir" -type f -mtime +"$TEMP_AGE" -delete 2>/dev/null
                    if [ $? -eq 0 ]; then
                        log_message "SUCCESS" "Cleaned old temporary files from $dir"
                        # Measure space after cleanup
                        measure_space_after_operation "$dir" "Temporary files ($dir)" "$size_before"
                    else
                        log_message "ERROR" "Failed to clean some temporary files from $dir"
                    fi
                else
                    log_message "INFO" "Skipping temporary file cleanup for $dir"
                fi
            fi
        fi
    done
}

# Function to clean trash
clean_trash() {
    log_message "INFO" "Checking trash for files older than $TRASH_AGE days..."
    
    local trash_dir="$HOME/.local/share/Trash"
    
    if [ -d "$trash_dir" ]; then
        local size=$(get_size "$trash_dir")
        log_message "INFO" "Checking $trash_dir (Size: $size)"
        
        # Measure space before cleanup
        local size_before=$(measure_space_before_operation "$trash_dir" "Trash")
        
        if $DRY_RUN; then
            log_message "INFO" "Would empty trash"
        else
            if confirm_action "Empty trash?" "y"; then
                log_message "INFO" "Emptying trash"
                rm -rf "$trash_dir/files/"* "$trash_dir/info/"* 2>/dev/null
                if [ $? -eq 0 ]; then
                    log_message "SUCCESS" "Trash emptied"
                    # Measure space after cleanup
                    measure_space_after_operation "$trash_dir" "Trash" "$size_before"
                else
                    log_message "ERROR" "Failed to empty trash"
                fi
            else
                log_message "INFO" "Skipping trash cleanup"
            fi
        fi
    else
        log_message "INFO" "Trash directory not found. Skipping."
    fi
}

# Function to clean package manager caches based on the distribution
clean_package_cache() {
    log_message "INFO" "Checking package manager cache..."
    
    # Check if user has admin privileges before attempting to clean package manager caches
    if ! check_admin_privileges; then
        show_admin_warning "Cleaning package manager caches"
    fi
    
    # Paths to measure for different package managers
    local apt_cache_dir="/var/cache/apt"
    local dnf_cache_dir="/var/cache/dnf"
    local pacman_cache_dir="/var/cache/pacman/pkg"
    local nix_cache_dir="/nix/store"
    
    # Detect the package manager
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        if [ -d "$apt_cache_dir" ]; then
            local size=$(get_size "$apt_cache_dir")
            log_message "INFO" "APT cache size: $size"
            
            # Measure space before cleanup
            local size_before=$(measure_space_before_operation "$apt_cache_dir" "APT cache")
            
            if $DRY_RUN; then
                log_message "INFO" "Would clean apt cache"
                if ! check_admin_privileges; then
                    log_message "WARN" "Would need administrator privileges to clean apt cache"
                fi
            else
                if confirm_action "Clean apt package cache?" "y"; then
                    log_message "INFO" "Cleaning apt cache"
                    if check_admin_privileges; then
                        apt-get clean
                        apt-get autoclean
                        if [ $? -eq 0 ]; then
                            log_message "SUCCESS" "Apt cache cleaned"
                            # Measure space after cleanup
                            measure_space_after_operation "$apt_cache_dir" "APT cache" "$size_before"
                        else
                            log_message "ERROR" "Failed to clean apt cache"
                        fi
                    else
                        log_message "WARN" "Need administrator privileges to clean apt cache. Skipping."
                    fi
                fi
            fi
        fi
    elif command -v dnf &> /dev/null; then
        # Fedora/RHEL/CentOS
        if [ -d "$dnf_cache_dir" ]; then
            local size=$(get_size "$dnf_cache_dir")
            log_message "INFO" "DNF cache size: $size"
            
            # Measure space before cleanup
            local size_before=$(measure_space_before_operation "$dnf_cache_dir" "DNF cache")
            
            if $DRY_RUN; then
                log_message "INFO" "Would clean DNF cache"
                if ! check_admin_privileges; then
                    log_message "WARN" "Would need administrator privileges to clean DNF cache"
                fi
            else
                if confirm_action "Clean DNF package cache?" "y"; then
                    log_message "INFO" "Cleaning DNF cache"
                    if check_admin_privileges; then
                        dnf clean all
                        if [ $? -eq 0 ]; then
                            log_message "SUCCESS" "DNF cache cleaned"
                            # Measure space after cleanup
                            measure_space_after_operation "$dnf_cache_dir" "DNF cache" "$size_before"
                        else
                            log_message "ERROR" "Failed to clean DNF cache"
                        fi
                    else
                        log_message "WARN" "Need administrator privileges to clean DNF cache. Skipping."
                    fi
                fi
            fi
        fi
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        if [ -d "$pacman_cache_dir" ]; then
            local size=$(get_size "$pacman_cache_dir")
            log_message "INFO" "Pacman cache size: $size"
            
            # Measure space before cleanup
            local size_before=$(measure_space_before_operation "$pacman_cache_dir" "Pacman cache")
            
            if $DRY_RUN; then
                log_message "INFO" "Would clean pacman cache"
                if ! check_admin_privileges; then
                    log_message "WARN" "Would need administrator privileges to clean pacman cache"
                fi
            else
                if confirm_action "Clean pacman package cache?" "y"; then
                    log_message "INFO" "Cleaning pacman cache"
                    if check_admin_privileges; then
                        pacman -Sc --noconfirm
                        if [ $? -eq 0 ]; then
                            log_message "SUCCESS" "Pacman cache cleaned"
                            # Measure space after cleanup
                            measure_space_after_operation "$pacman_cache_dir" "Pacman cache" "$size_before"
                        else
                            log_message "ERROR" "Failed to clean pacman cache"
                        fi
                    else
                        log_message "WARN" "Need administrator privileges to clean pacman cache. Skipping."
                    fi
                fi
            fi
        fi
    elif command -v nix-env &> /dev/null; then
        # NixOS
        if [ -d "$nix_cache_dir" ]; then
            local size=$(get_size "$nix_cache_dir")
            log_message "INFO" "Nix store size: $size"
            
            # Measure space before cleanup
            local size_before=$(measure_space_before_operation "$nix_cache_dir" "Nix store")
            
            if $DRY_RUN; then
                log_message "INFO" "Would clean nix store garbage"
                if ! check_admin_privileges; then
                    log_message "WARN" "Would need administrator privileges for full nix garbage collection"
                fi
            else
                if confirm_action "Clean nix store garbage?" "y"; then
                    log_message "INFO" "Cleaning nix store"
                    if check_admin_privileges; then
                        nix-collect-garbage -d
                        if [ $? -eq 0 ]; then
                            log_message "SUCCESS" "Nix store garbage collected"
                            # Measure space after cleanup
                            measure_space_after_operation "$nix_cache_dir" "Nix store" "$size_before"
                        else
                            log_message "ERROR" "Failed to collect nix garbage"
                        fi
                    else
                        log_message "WARN" "Need administrator privileges for full nix garbage collection. Using user-only cleanup."
                        nix-collect-garbage
                        if [ $? -eq 0 ]; then
                            log_message "SUCCESS" "User nix garbage collected"
                            # Measure space after cleanup
                            measure_space_after_operation "$nix_cache_dir" "Nix store (user)" "$size_before"
                        else
                            log_message "ERROR" "Failed to collect user nix garbage"
                        fi
                    fi
                fi
            fi
        fi
    else
        log_message "INFO" "No supported package manager found. Skipping package cache cleanup."
    fi
}

# Function to find and remove backup files
clean_backups() {
    log_message "INFO" "Checking for backup files older than $BACKUP_AGE days..."
    
    local backup_patterns="*.bak *~ *.old *.backup *.swp"
    
    # Measure space before cleanup
    local size_before=$(measure_space_before_operation "$TARGET_DIR" "Backup files")
    
    if $DRY_RUN; then
        log_message "INFO" "Would remove old backup files from $TARGET_DIR"
    else
        if confirm_action "Clean old backup files from $TARGET_DIR?" "y"; then
            log_message "INFO" "Removing old backup files"
            for pattern in $backup_patterns; do
                find "$TARGET_DIR" -type f -name "$pattern" -mtime +"$BACKUP_AGE" -delete 2>/dev/null
            done
            if [ $? -eq 0 ]; then
                log_message "SUCCESS" "Cleaned old backup files"
                # Measure space after cleanup
                measure_space_after_operation "$TARGET_DIR" "Backup files" "$size_before"
            else
                log_message "ERROR" "Failed to clean some backup files"
            fi
        else
            log_message "INFO" "Skipping backup file cleanup"
        fi
    fi
}

# Function to clean additional directories specified in config
clean_additional_dirs() {
    if [ -n "$ADDITIONAL_DIRS" ]; then
        log_message "INFO" "Checking additional directories specified in config..."
        
        IFS=' ' read -ra dirs <<< "$ADDITIONAL_DIRS"
        for dir_entry in "${dirs[@]}"; do
            IFS=':' read -r dir age <<< "$dir_entry"
            
            if [ -d "$dir" ]; then
                local size=$(get_size "$dir")
                log_message "INFO" "Checking $dir (Size: $size, Age: $age days)"
                
                # Measure space before cleanup
                local size_before=$(measure_space_before_operation "$dir" "Additional directory")
                
                if $DRY_RUN; then
                    local files=$(find "$dir" -type f -mtime +"$age" 2>/dev/null)
                    if [ -n "$files" ]; then
                        log_message "INFO" "Would remove old files from $dir"
                    fi
                else
                    if confirm_action "Clean old files from $dir?" "y"; then
                        log_message "INFO" "Removing old files from $dir"
                        find "$dir" -type f -mtime +"$age" -delete 2>/dev/null
                        if [ $? -eq 0 ]; then
                            log_message "SUCCESS" "Cleaned old files from $dir"
                            # Measure space after cleanup
                            measure_space_after_operation "$dir" "Additional directory ($dir)" "$size_before"
                        else
                            log_message "ERROR" "Failed to clean some files from $dir"
                        fi
                    else
                        log_message "INFO" "Skipping cleanup for $dir"
                    fi
                fi
            else
                log_message "WARN" "Directory $dir does not exist. Skipping."
            fi
        done
    fi
}

# Function to clean Docker resources
clean_docker() {
    log_message "INFO" "Checking Docker resources..."
    
    # Check if Docker is installed
    if command -v docker &> /dev/null; then
        # Get Docker disk usage info before cleanup
        local docker_info_before=""
        if ! $DRY_RUN; then
            # Get docker system df info to measure space before cleanup
            docker_info_before=$(docker system df -v 2>/dev/null)
        fi
        
        if $DRY_RUN; then
            log_message "INFO" "Would clean unused Docker resources"
        else
            if confirm_action "Clean unused Docker resources (images, containers, volumes)?" "y"; then
                log_message "INFO" "Cleaning unused Docker resources"
                
                # Prune unused containers
                log_message "INFO" "Pruning unused Docker containers"
                docker container prune -f
                
                # Prune unused images
                log_message "INFO" "Pruning unused Docker images"
                docker image prune -f
                
                # Prune unused volumes
                log_message "INFO" "Pruning unused Docker volumes"
                docker volume prune -f
                
                # Prune entire system (networks and everything else)
                log_message "INFO" "Pruning entire Docker system"
                docker system prune -f
                
                if [ $? -eq 0 ]; then
                    log_message "SUCCESS" "Docker resources cleaned"
                    
                    # Calculate space recovered from Docker cleanup
                    local docker_info_after=$(docker system df -v 2>/dev/null)
                    
                    # Simple estimate based on df output before and after
                    local disk_before=$(df -B1 / | awk 'NR==2 {print $4}')
                    local disk_after=$(df -B1 / | awk 'NR==2 {print $4}')
                    local docker_bytes_recovered=$((disk_after - disk_before))
                    
                    if [ $docker_bytes_recovered -gt 0 ]; then
                        local hr_docker_size=$(numfmt --to=iec-i --suffix=B --format="%.2f" $docker_bytes_recovered)
                        log_message "SUCCESS" "Docker cleanup: Recovered $hr_docker_size"
                        SPACE_RECOVERED_BY_OPERATION+=("Docker cleanup: $hr_docker_size")
                        TOTAL_SPACE_RECOVERED=$((TOTAL_SPACE_RECOVERED + docker_bytes_recovered))
                    fi
                else
                    log_message "ERROR" "Failed to clean some Docker resources"
                fi
            else
                log_message "INFO" "Skipping Docker cleanup"
            fi
        fi
    else
        log_message "INFO" "Docker not found. Skipping Docker cleanup."
    fi
}

# Function to display final summary
show_summary() {
    echo
    echo -e "${GREEN}===== Cleanup Summary =====${NC}"
    echo "Target directory: $TARGET_DIR"
    
    if $DRY_RUN; then
        echo -e "${YELLOW}Dry run completed. No files were actually deleted.${NC}"
    else
        echo -e "${GREEN}Cleanup completed. Check the log file for details.${NC}"
        
        # Display space recovered
        if [ $TOTAL_SPACE_RECOVERED -gt 0 ]; then
            # Convert total bytes to human readable format
            local hr_total=$(numfmt --to=iec-i --suffix=B --format="%.2f" $TOTAL_SPACE_RECOVERED)
            echo -e "\n${GREEN}===== Space Recovered =====${NC}"
            echo -e "${CYAN}Total space recovered: ${GREEN}$hr_total${NC}"
            
            # Display individual operation results
            echo -e "\n${CYAN}Breakdown by operation:${NC}"
            for result in "${SPACE_RECOVERED_BY_OPERATION[@]}"; do
                echo -e "  ${GREEN}$result${NC}"
            done
        fi
    fi
    
    echo -e "\nLog file: $LOG_FILE"
    
    # Display disk space information
    echo
    echo -e "${BLUE}Disk Space Information:${NC}"
    df -h / | grep -v "Filesystem"
    
    # Show before and after comparison if not in dry run mode
    if [ -n "$INITIAL_DISK_SPACE" ] && [ -n "$FINAL_DISK_SPACE" ]; then
        echo -e "\n${CYAN}Disk Space Before:${NC} $INITIAL_DISK_SPACE"
        echo -e "${CYAN}Disk Space After: ${NC} $FINAL_DISK_SPACE"
    fi
}

# Main function
main() {
    # Parse command line arguments
    parse_args "$@"
    
    # Show banner
    show_banner
    
    # Initialize log file
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "=== Another One Bites the Dust - Cleanup Log ($(date)) ===" > "$LOG_FILE"
    
    # Load configuration
    load_config
    
    # Summary of what will be done
    if $DRY_RUN; then
        log_message "INFO" "Running in DRY RUN mode - no files will be deleted"
    else
        log_message "INFO" "Running in NORMAL mode - files will be deleted!"
        
        # Capture initial disk space
        INITIAL_DISK_SPACE=$(df -h / | grep -v "Filesystem" | awk '{print $4 " free out of " $2}')
        log_message "INFO" "Initial disk space: $INITIAL_DISK_SPACE"
    fi
    
    log_message "INFO" "Target directory: $TARGET_DIR"
    log_message "INFO" "Log file: $LOG_FILE"
    
    # Run cleanup functions
    clean_cache
    clean_logs
    clean_temp
    clean_trash
    clean_package_cache
    clean_backups
    clean_additional_dirs
    clean_docker
    
    # Capture final disk space
    if ! $DRY_RUN; then
        FINAL_DISK_SPACE=$(df -h / | grep -v "Filesystem" | awk '{print $4 " free out of " $2}')
        log_message "INFO" "Final disk space: $FINAL_DISK_SPACE"
        
        if [ $TOTAL_SPACE_RECOVERED -gt 0 ]; then
            local hr_total=$(numfmt --to=iec-i --suffix=B --format="%.2f" $TOTAL_SPACE_RECOVERED)
            log_message "SUCCESS" "Total space recovered: $hr_total"
        fi
    fi
    
    # Show summary
    show_summary
}

# Run the main function with command line arguments
main "$@"