#!/bin/bash

# Script to manage media streams from various sites using yt-dlp

# Default color definitions for better output readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Set default values
OUTPUT_DIR="$(pwd)"
INTERACTIVE_MODE=true
DOWNLOAD_TYPE=""
MEDIA_URL=""
QUIET_MODE=false
SILENT_MODE=false
VERBOSE_MODE=false
DOWNLOAD_SUBTITLES=false
DOWNLOAD_AUTO_SUBTITLES=false
SUBTITLE_LANGUAGES="all"
INPUT_FILE=""
LOG_FILE=""
LOG_ENABLED=false
DOWNLOAD_VIDEOS=true
DOWNLOAD_SHORTS=true
DOWNLOAD_LIVE=true

# Function to display log messages with color and timestamp
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local log_entry="[$timestamp] [$level] $message"
    
    # Write to log file if enabled
    if $LOG_ENABLED && [ -n "$LOG_FILE" ]; then
        echo "$log_entry" >> "$LOG_FILE"
    fi
    
    # Handle different verbosity levels
    # When in silent mode, only ERROR messages are shown
    if $SILENT_MODE && [ "$level" != "ERROR" ]; then
        return
    fi
    
    # When in quiet mode, INFO and SUCCESS messages are suppressed
    if $QUIET_MODE && ( [ "$level" == "INFO" ] || [ "$level" == "SUCCESS" ] ) && ! $VERBOSE_MODE; then
        return
    fi
    
    # Display message with appropriate color
    case $level in
        "INFO")
            echo -e "${BLUE}[INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
        "DEBUG")
            # Only show debug messages in verbose mode
            if $VERBOSE_MODE; then
                echo -e "${PURPLE}[DEBUG]${NC} $message"
            fi
            ;;
        *)
            echo -e "${PURPLE}[$level]${NC} $message"
            ;;
    esac
}

# Function to display help information
show_help() {
    # Show banner unless in silent mode
    if ! $SILENT_MODE; then
        show_banner
    fi
    
    echo "Another yt-dlp wrapper Script"
    echo ""
    echo "Usage: ./another_yt-dlp_wrapper.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help                Show this help message and exit"
    echo "  -o, --output-dir DIR      Set output directory (default: current directory)"
    echo "  -u, --url URL             Media URL (video, channel, or playlist)"
    echo "  -f, --file FILE           Input file with URLs (one per line)"
    echo "  -q, --quiet               Show less output"
    echo "  -s, --silent              Show no output except errors"
    echo "  -v, --verbose             Show more detailed output"
    echo "  -n, --non-interactive     Run in non-interactive mode (requires --url or --file)"
    echo "  --subs                    Download manually created subtitles"
    echo "  --auto-subs               Download auto-generated subtitles"
    echo "  --sub-langs LANGS         Subtitle languages to download (comma-separated, e.g., 'en,it')"
    echo "                            Use 'all' for all available languages (default)"
    echo "  --log FILE                Save all output to a log file"
    echo "  --no-videos               Skip regular videos"
    echo "  --no-shorts               Skip shorts"
    echo "  --no-live                 Skip live streams/recordings"
    echo "  --only-videos             Download only regular videos"
    echo "  --only-shorts             Download only shorts"
    echo "  --only-live               Download only live streams/recordings"
    echo ""
    echo "Examples:"
    echo "  ./another_yt-dlp_wrapper.sh                                  # Run in interactive mode"
    echo "  ./another_yt-dlp_wrapper.sh -o ~/Downloads -u https://youtube.com/watch?v=XXXX  # Download a specific video"
    echo "  ./another_yt-dlp_wrapper.sh -n -u https://youtube.com/c/ChannelName             # Download a channel non-interactively"
    echo "  ./another_yt-dlp_wrapper.sh -n -f channels.txt --subs        # Download all channels with manual subtitles"
    echo "  ./another_yt-dlp_wrapper.sh -n -u URL --subs --auto-subs     # Download with both manual and auto subtitles"
    echo "  ./another_yt-dlp_wrapper.sh -n -u URL --subs --sub-langs en,it  # Download only English and Italian subtitles"
    echo ""
}

# Function to check required software dependencies
check_dependencies() {
    local missing_deps=()
    local optional_deps=()
    local required_deps=("curl" "grep" "sed" "mkdir" "yt-dlp")
    
    log_message "INFO" "Checking required dependencies..."
    
    # Check required dependencies
    for cmd in "${required_deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_message "ERROR" "The following required dependencies are missing:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo ""
        log_message "INFO" "Please install these dependencies and try again."
        log_message "INFO" "For yt-dlp installation, visit: https://github.com/yt-dlp/yt-dlp#installation"
        exit 1
    fi
    
    log_message "SUCCESS" "All dependencies are met."
}

# Function to normalize media URL and determine type (video, channel, playlist)
process_url() {
    local url="$1"
    
    # Detect URL type
    if [[ $url == *"youtube.com/watch"* ]] || [[ $url == *"youtu.be/"* ]]; then
        DOWNLOAD_TYPE="video"
    elif [[ $url == *"youtube.com/playlist"* ]]; then
        DOWNLOAD_TYPE="playlist"
    elif [[ $url == *"youtube.com/c/"* ]] || [[ $url == *"youtube.com/channel/"* ]] || [[ $url == *"youtube.com/user/"* ]] || [[ $url == *"youtube.com/@"* ]]; then
        DOWNLOAD_TYPE="channel"
    else
        log_message "ERROR" "Couldn't determine URL type. Please provide a valid media URL supported by yt-dlp."
        return 1
    fi
    
    log_message "INFO" "URL type detected: $DOWNLOAD_TYPE"
    
    return 0
}

# Function to get channel name from URL
get_channel_name() {
    local url="$1"
    local channel_name=""
    
    # Try to extract from the URL first (most reliable and avoids infinite loops)
    if [[ $url == *"youtube.com/c/"* ]]; then
        channel_name=$(echo "$url" | sed -n 's|.*youtube\.com/c/\([^/?]*\).*|\1|p')
    elif [[ $url == *"youtube.com/channel/"* ]]; then
        channel_name="channel_$(echo "$url" | sed -n 's|.*channel/\([^/?]*\).*|\1|p')"
    elif [[ $url == *"youtube.com/user/"* ]]; then
        channel_name=$(echo "$url" | sed -n 's|.*youtube\.com/user/\([^/?]*\).*|\1|p')
    elif [[ $url == *"youtube.com/@"* ]]; then
        channel_name=$(echo "$url" | sed -n 's|.*youtube\.com/@\([^/?]*\).*|\1|p')
    else
        # Only if we can't extract from URL, try yt-dlp (once)
        channel_name=$(yt-dlp --quiet --print channel_id "$url" 2>/dev/null)
    fi
    
    # If we still don't have a channel name, use a timestamp
    if [ -z "$channel_name" ]; then
        channel_name="media_download_$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Sanitize the channel name to avoid problematic characters
    channel_name=$(echo "$channel_name" | tr -d '\n\r' | tr -c '[:alnum:]_-' '_' | cut -c 1-50)
    
    echo "$channel_name"
}

# Function to download videos
download_videos() {
    local url="$1"
    local output_dir="$2"
    local channel_dir
    local yt_dlp_args=()
    
    # Common arguments for yt-dlp
    yt_dlp_args+=(--format "bestvideo+bestaudio/best")
    yt_dlp_args+=(--merge-output-format "mp4")
    yt_dlp_args+=(--continue)
    yt_dlp_args+=(--no-overwrites)
    
    # Set up for different content types (videos, shorts, live)
    local content_types=()
    
    # Add content types based on settings
    if $DOWNLOAD_VIDEOS; then
        content_types+=("videos")
    fi
    if $DOWNLOAD_SHORTS; then
        content_types+=("shorts")
    fi
    if $DOWNLOAD_LIVE; then
        content_types+=("lives")
    fi
    
    # Check if we have any content types to download
    if [ ${#content_types[@]} -eq 0 ]; then
        log_message "ERROR" "No content types selected to download. Enable at least one type."
        return 1
    fi
    
    # Add subtitles if requested
    if $DOWNLOAD_SUBTITLES || $DOWNLOAD_AUTO_SUBTITLES; then
        # Settings for subtitle format
        yt_dlp_args+=(--sub-format "srt")
        yt_dlp_args+=(--convert-subs "srt")
        
        # Determine which types of subtitles to download
        if $DOWNLOAD_SUBTITLES; then
            yt_dlp_args+=(--write-sub)      # Download manually created subtitles
            log_message "INFO" "Downloading manually created subtitles"
        fi
        
        if $DOWNLOAD_AUTO_SUBTITLES; then
            yt_dlp_args+=(--write-auto-sub) # Download auto-generated subtitles
            log_message "INFO" "Downloading auto-generated subtitles"
        fi
        
        # Set subtitle languages
        yt_dlp_args+=(--sub-langs "$SUBTITLE_LANGUAGES")
        log_message "INFO" "Subtitle languages: $SUBTITLE_LANGUAGES"
    fi
    
    # Add verbosity settings
    if $QUIET_MODE; then
        yt_dlp_args+=(--quiet)
    elif $VERBOSE_MODE; then
        yt_dlp_args+=(--verbose)
    fi
    
    # Handle different download types
    case "$DOWNLOAD_TYPE" in
        "video")
            # Get channel name for the directory (even for single videos)
            channel_name=$(get_channel_name "$url")
            channel_dir="$output_dir/$channel_name"
            
            log_message "INFO" "Downloading single video from channel: $channel_name"
            log_message "INFO" "Base output directory: $channel_dir"
            
            # Create channel directory if it doesn't exist
            mkdir -p "$channel_dir"
            
            # Download each content type in separate directories
            for content_type in "${content_types[@]}"; do
                # Create subdirectory for content type
                local type_dir="$channel_dir/$content_type"
                mkdir -p "$type_dir"
                
                log_message "INFO" "Downloading $content_type to: $type_dir"
                
                # Set up specific yt-dlp args for this content type
                local type_args=("${yt_dlp_args[@]}")
                type_args+=(--output "$type_dir/%(title)s.%(ext)s")
                
                # Content-type specific settings
                case "$content_type" in
                    "videos")
                        type_args+=(--extractor-args "youtube:tab=videos")
                        type_args+=(--match-filter "!is_live & !live & !is_shorts")
                        ;;
                    "shorts")
                        type_args+=(--extractor-args "youtube:tab=shorts")
                        type_args+=(--match-filter "is_shorts")
                        ;;
                    "lives")
                        type_args+=(--extractor-args "youtube:tab=videos")
                        type_args+=(--match-filter "is_live | live")
                        ;;
                esac
                
                # Execute yt-dlp and capture output for logging
                if $LOG_ENABLED && [ -n "$LOG_FILE" ]; then
                    log_message "INFO" "Starting $content_type download with yt-dlp, check log file for details"
                    {
                        echo -e "\n---------- YT-DLP OUTPUT (SINGLE $content_type) ----------" 
                        yt-dlp "${type_args[@]}" "$url" 2>&1
                        echo -e "---------- END YT-DLP OUTPUT ----------\n"
                    } >> "$LOG_FILE" 2>&1
                    
                    # Still show something to the user even when logging
                    yt-dlp "${type_args[@]}" "$url"
                else
                    # Normal execution without special logging
                    yt-dlp "${type_args[@]}" "$url"
                fi
            done
            ;;
            
        "playlist"|"channel")
            # Get channel name for the directory
            channel_name=$(get_channel_name "$url")
            channel_dir="$output_dir/$channel_name"
            
            log_message "INFO" "Downloading $DOWNLOAD_TYPE: $channel_name"
            log_message "INFO" "Base output directory: $channel_dir"
            
            # Create channel directory if it doesn't exist
            mkdir -p "$channel_dir"
            
            # Download each content type in separate directories
            for content_type in "${content_types[@]}"; do
                # Create subdirectory for content type
                local type_dir="$channel_dir/$content_type"
                mkdir -p "$type_dir"
                
                log_message "INFO" "Downloading $content_type to: $type_dir"
                
                # Set up specific yt-dlp args for this content type
                local type_args=("${yt_dlp_args[@]}")
                type_args+=(--output "$type_dir/%(title)s.%(ext)s")
                
                # Content-type specific settings
                case "$content_type" in
                    "videos")
                        type_args+=(--extractor-args "youtube:tab=videos")
                        type_args+=(--match-filter "!is_live & !live & !is_shorts")
                        ;;
                    "shorts")
                        type_args+=(--extractor-args "youtube:tab=shorts")
                        type_args+=(--match-filter "is_shorts")
                        ;;
                    "lives")
                        type_args+=(--extractor-args "youtube:tab=videos")
                        type_args+=(--match-filter "is_live | live")
                        ;;
                esac
                
                # Execute yt-dlp and capture output for logging
                if $LOG_ENABLED && [ -n "$LOG_FILE" ]; then
                    log_message "INFO" "Starting $DOWNLOAD_TYPE/$content_type download with yt-dlp, check log file for details"
                    {
                        echo -e "\n---------- YT-DLP OUTPUT ($DOWNLOAD_TYPE $content_type) ----------" 
                        yt-dlp "${type_args[@]}" "$url" 2>&1
                        echo -e "---------- END YT-DLP OUTPUT ----------\n"
                    } >> "$LOG_FILE" 2>&1
                    
                    # Still show something to the user even when logging
                    yt-dlp "${type_args[@]}" "$url"
                else
                    # Normal execution without special logging
                    yt-dlp "${type_args[@]}" "$url"
                fi
            done
            ;;
            
        *)
            log_message "ERROR" "Unknown download type: $DOWNLOAD_TYPE"
            return 1
            ;;
    esac
    
    log_message "SUCCESS" "Download completed successfully!"
    
    return 0
}

# Function to process URLs from input file
process_input_file() {
    local input_file="$1"
    local success_count=0
    local failed_count=0
    
    # Check if file exists
    if [ ! -f "$input_file" ]; then
        log_message "ERROR" "Input file not found: $input_file"
        return 1
    fi
    
    log_message "INFO" "Processing URLs from file: $input_file"
    
    # Log information about the batch process
    if $LOG_ENABLED && [ -n "$LOG_FILE" ]; then
        {
            echo -e "\n========== BATCH PROCESSING START ===========" 
            echo "Input file: $input_file"
            echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "Output directory: $OUTPUT_DIR"
            echo "================================================="
        } >> "$LOG_FILE" 2>&1
    fi
    
    # Read file line by line
    while IFS= read -r url || [ -n "$url" ]; do
        # Skip empty lines and comments
        if [ -z "$url" ] || [[ "$url" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Trim whitespace
        url=$(echo "$url" | xargs)
        
        # Skip if still empty after trimming
        if [ -z "$url" ]; then
            continue
        fi
        
        log_message "INFO" "Processing URL: $url"
        
        # Reset download type for each URL
        DOWNLOAD_TYPE=""
        
        # Process URL to determine type
        if ! process_url "$url"; then
            log_message "WARN" "Failed to process URL: $url"
            failed_count=$((failed_count + 1))
            continue
        fi
        
        # Download videos
        if download_videos "$url" "$OUTPUT_DIR"; then
            success_count=$((success_count + 1))
        else
            failed_count=$((failed_count + 1))
        fi
    done < "$input_file"
    
    log_message "INFO" "File processing complete. Successfully processed $success_count URLs, failed $failed_count."
    
    # Log summary of the batch process
    if $LOG_ENABLED && [ -n "$LOG_FILE" ]; then
        {
            echo -e "\n========== BATCH PROCESSING SUMMARY =========="
            echo "Input file: $input_file"
            echo "End timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "URLs processed successfully: $success_count"
            echo "URLs failed: $failed_count"
            echo "=================================================="
        } >> "$LOG_FILE" 2>&1
    fi
    
    return 0
}

# Function to display banner
show_banner() {
    # Banner colors
    local ACCENT_COLOR='\033[1;31m'
    local MAIN_COLOR='\033[1;37m'
    
    echo -e "${ACCENT_COLOR}【 ${MAIN_COLOR}Another yt-dlp wrapper${ACCENT_COLOR} 】${NC} v1.0.0 - A simple media downloader utility"
}

# Function to handle interactive mode
run_interactive_mode() {
    # Display banner
    show_banner
    
    # Ask for media URL
    read -p "Enter media URL (video, channel, or playlist): " MEDIA_URL
    if [ -z "$MEDIA_URL" ]; then
        log_message "ERROR" "No URL provided."
        exit 1
    fi
    
    # Process URL to determine type
    if ! process_url "$MEDIA_URL"; then
        exit 1
    fi
    
    # Ask for output directory
    read -p "Enter output directory (or press Enter for current directory): " user_output_dir
    if [ -n "$user_output_dir" ]; then
        # Expand tilde to home directory if used
        OUTPUT_DIR="${user_output_dir/#\~/$HOME}"
    fi
    
    # Create output directory if it doesn't exist
    if [ ! -d "$OUTPUT_DIR" ]; then
        log_message "INFO" "Creating output directory: $OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
    fi
    
    # Ask about subtitles
    echo ""
    echo "Subtitle options:"
    read -p "Download manually created subtitles? (y/N): " get_subs
    if [[ "$get_subs" =~ ^[Yy] ]]; then
        DOWNLOAD_SUBTITLES=true
        echo "Manual subtitles will be downloaded when available."
    fi
    
    read -p "Download auto-generated subtitles? (y/N): " get_auto_subs
    if [[ "$get_auto_subs" =~ ^[Yy] ]]; then
        DOWNLOAD_AUTO_SUBTITLES=true
        echo "Auto-generated subtitles will be downloaded when available."
    fi
    
    if $DOWNLOAD_SUBTITLES || $DOWNLOAD_AUTO_SUBTITLES; then
        read -p "Subtitle languages (comma-separated, e.g., 'en,it' or 'all' for all languages): " sub_langs
        if [ -n "$sub_langs" ]; then
            SUBTITLE_LANGUAGES="$sub_langs"
        fi
        echo "Will download subtitles in languages: $SUBTITLE_LANGUAGES"
    fi
    
    # Ask about content types
    echo ""
    echo "Content type options:"
    read -p "Download regular videos? (Y/n): " get_videos
    if [[ "$get_videos" =~ ^[Nn] ]]; then
        DOWNLOAD_VIDEOS=false
        echo "Regular videos will be skipped."
    else
        echo "Regular videos will be downloaded."
    fi
    
    read -p "Download shorts? (Y/n): " get_shorts
    if [[ "$get_shorts" =~ ^[Nn] ]]; then
        DOWNLOAD_SHORTS=false
        echo "Shorts will be skipped."
    else
        echo "Shorts will be downloaded."
    fi
    
    read -p "Download live streams/recordings? (Y/n): " get_live
    if [[ "$get_live" =~ ^[Nn] ]]; then
        DOWNLOAD_LIVE=false
        echo "Live streams/recordings will be skipped."
    else
        echo "Live streams/recordings will be downloaded."
    fi
    
    # Confirm with user
    echo ""
    log_message "INFO" "Ready to download:"
    echo "  Type: $DOWNLOAD_TYPE"
    echo "  URL: $MEDIA_URL"
    echo "  Output Directory: $OUTPUT_DIR"
    if $DOWNLOAD_SUBTITLES; then
        echo "  Manual Subtitles: Yes (languages: $SUBTITLE_LANGUAGES)"
    fi
    if $DOWNLOAD_AUTO_SUBTITLES; then
        echo "  Auto-generated Subtitles: Yes (languages: $SUBTITLE_LANGUAGES)"
    fi
    echo "  Content types:"
    if $DOWNLOAD_VIDEOS; then
        echo "    - Regular videos: Yes"
    else
        echo "    - Regular videos: No"
    fi
    if $DOWNLOAD_SHORTS; then
        echo "    - Shorts: Yes"
    else
        echo "    - Shorts: No"
    fi
    if $DOWNLOAD_LIVE; then
        echo "    - Live streams/recordings: Yes"
    else
        echo "    - Live streams/recordings: No"
    fi
    echo ""
    read -p "Continue? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn] ]]; then
        log_message "INFO" "Download cancelled."
        exit 0
    fi
    
    # Start download
    download_videos "$MEDIA_URL" "$OUTPUT_DIR"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output-dir)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                # Expand tilde to home directory if used
                OUTPUT_DIR="${2/#\~/$HOME}"
                shift 2
            else
                log_message "ERROR" "Argument for $1 is missing."
                exit 1
            fi
            ;;
        -u|--url)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                MEDIA_URL="$2"
                shift 2
            else
                log_message "ERROR" "Argument for $1 is missing."
                exit 1
            fi
            ;;
        -q|--quiet)
            QUIET_MODE=true
            shift
            ;;
        -s|--silent)
            SILENT_MODE=true
            QUIET_MODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE_MODE=true
            QUIET_MODE=false
            SILENT_MODE=false
            shift
            ;;
        -n|--non-interactive)
            INTERACTIVE_MODE=false
            shift
            ;;
        --subs)
            DOWNLOAD_SUBTITLES=true
            shift
            ;;
        --auto-subs)
            DOWNLOAD_AUTO_SUBTITLES=true
            shift
            ;;
        --sub-langs)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                SUBTITLE_LANGUAGES="$2"
                shift 2
            else
                log_message "ERROR" "Argument for $1 is missing."
                exit 1
            fi
            ;;
        -f|--file)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                INPUT_FILE="$2"
                shift 2
            else
                log_message "ERROR" "Argument for $1 is missing."
                exit 1
            fi
            ;;
        --log)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                LOG_FILE="$2"
                LOG_ENABLED=true
                # Create log file dir if it doesn't exist
                log_dir=$(dirname "$LOG_FILE")
                mkdir -p "$log_dir"
                # Initialize log file with header
                echo "# yt-dlp wrapper Log - $(date)" > "$LOG_FILE"
                echo "# Command: $0 $@" >> "$LOG_FILE"
                echo "----------------------------------------" >> "$LOG_FILE"
                log_message "INFO" "Logging to file: $LOG_FILE"
                shift 2
            else
                log_message "ERROR" "Argument for $1 is missing."
                exit 1
            fi
            ;;
        --no-videos)
            DOWNLOAD_VIDEOS=false
            shift
            ;;
        --no-shorts)
            DOWNLOAD_SHORTS=false
            shift
            ;;
        --no-live)
            DOWNLOAD_LIVE=false
            shift
            ;;
        --only-videos)
            DOWNLOAD_VIDEOS=true
            DOWNLOAD_SHORTS=false
            DOWNLOAD_LIVE=false
            shift
            ;;
        --only-shorts)
            DOWNLOAD_VIDEOS=false
            DOWNLOAD_SHORTS=true
            DOWNLOAD_LIVE=false
            shift
            ;;
        --only-live)
            DOWNLOAD_VIDEOS=false
            DOWNLOAD_SHORTS=false
            DOWNLOAD_LIVE=true
            shift
            ;;
        -*)
            log_message "ERROR" "Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            log_message "ERROR" "Unknown argument $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
check_dependencies

# Create output directory if it doesn't exist
if [ ! -d "$OUTPUT_DIR" ]; then
    log_message "INFO" "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
fi

if $INTERACTIVE_MODE; then
    run_interactive_mode
else
    # Non-interactive mode requires URL or input file
    if [ -z "$MEDIA_URL" ] && [ -z "$INPUT_FILE" ]; then
        log_message "ERROR" "In non-interactive mode, you must provide a URL with --url option or an input file with --file option."
        show_help
        exit 1
    fi
    
    # Display banner unless in silent mode
    if ! $SILENT_MODE; then
        show_banner
    fi
    
    if [ -n "$INPUT_FILE" ]; then
        # Process input file
        process_input_file "$INPUT_FILE"
    else
        # Process URL to determine type
        if ! process_url "$MEDIA_URL"; then
            exit 1
        fi
        
        # Start download
        download_videos "$MEDIA_URL" "$OUTPUT_DIR"
    fi
fi

exit 0
