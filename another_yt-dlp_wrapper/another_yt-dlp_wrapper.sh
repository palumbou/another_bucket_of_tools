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

# Authentication configuration
USE_COOKIES=false
COOKIES_FROM_BROWSER=""
COOKIES_FILE=""

# Rate limiting configuration
RATE_LIMIT_MODE="normal"  # normal, slow, fast
SLOW_MIN_DELAY=5
SLOW_MAX_DELAY=10
NORMAL_MIN_DELAY=1
NORMAL_MAX_DELAY=3

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
    echo "  --cookie-guide            Show detailed guide for cookie authentication"
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
    echo "  --slow                    Enable slower download mode (5-10 sec delay) to avoid rate limits"
    echo "  --fast                    Disable rate limiting delays (may trigger YouTube limits)"
    echo ""
    echo "Authentication options:"
    echo "  --cookies-from-browser BROWSER"
    echo "                            Extract cookies from browser (chrome, firefox, edge, safari, etc.)"
    echo "  --cookies-file FILE       Use cookies from a Netscape format cookie file"
    echo ""
    echo "Note: Thumbnails and descriptions (with URLs) are automatically downloaded for all videos."
    echo ""
    echo "Examples:"
    echo "  ./another_yt-dlp_wrapper.sh                                  # Run in interactive mode"
    echo "  ./another_yt-dlp_wrapper.sh -o ~/Downloads -u https://youtube.com/watch?v=XXXX  # Download a specific video"
    echo "  ./another_yt-dlp_wrapper.sh -n -u https://youtube.com/c/ChannelName             # Download a channel non-interactively"
    echo "  ./another_yt-dlp_wrapper.sh -n -f channels.txt --subs        # Download all channels with manual subtitles"
    echo "  ./another_yt-dlp_wrapper.sh -n -u URL --subs --auto-subs     # Download with both manual and auto subtitles"
    echo "  ./another_yt-dlp_wrapper.sh -n -u URL --subs --sub-langs en,it  # Download only English and Italian subtitles"
    echo "  ./another_yt-dlp_wrapper.sh -n -u URL --cookies-from-browser chrome  # Use cookies from Chrome browser"
    echo "  ./another_yt-dlp_wrapper.sh -n -u URL --cookies-file ~/cookies.txt   # Use cookies from file"
    echo ""
}

# Function to display cookie setup guide
show_cookie_guide() {
    echo ""
    echo "=========================================="
    echo "   COOKIE AUTHENTICATION GUIDE"
    echo "=========================================="
    echo ""
    echo "Cookies allow you to download private/members-only videos and bypass age restrictions."
    echo ""
    echo "METHOD 1: Extract cookies from your browser (recommended)"
    echo "-----------------------------------------------------------"
    echo "Use the --cookies-from-browser option to automatically extract cookies."
    echo ""
    echo "Supported browsers:"
    echo "  - chrome, chromium"
    echo "  - firefox"
    echo "  - edge"
    echo "  - safari"
    echo "  - opera"
    echo "  - brave"
    echo "  - vivaldi"
    echo ""
    echo "Example:"
    echo "  ./another_yt-dlp_wrapper.sh -n -u URL --cookies-from-browser chrome"
    echo ""
    echo "Note: You must be logged into YouTube in the specified browser."
    echo ""
    echo "METHOD 2: Use a cookies file"
    echo "-----------------------------------------------------------"
    echo "1. Install a browser extension to export cookies:"
    echo "   - Chrome/Edge: 'Get cookies.txt LOCALLY' or 'cookies.txt'"
    echo "   - Firefox: 'cookies.txt'"
    echo ""
    echo "2. Log into YouTube in your browser"
    echo ""
    echo "3. Navigate to youtube.com"
    echo ""
    echo "4. Click the extension icon and export cookies"
    echo "   - Save the file as 'youtube_cookies.txt' (or any name you prefer)"
    echo "   - The file must be in Netscape cookie format"
    echo ""
    echo "5. Use the cookies file with this script:"
    echo "   ./another_yt-dlp_wrapper.sh -n -u URL --cookies-file ~/youtube_cookies.txt"
    echo ""
    echo "BROWSER EXTENSION LINKS:"
    echo "-----------------------------------------------------------"
    echo "Chrome/Edge: https://chrome.google.com/webstore (search 'cookies.txt')"
    echo "Firefox: https://addons.mozilla.org (search 'cookies.txt')"
    echo ""
    echo "Note: Keep your cookies file secure as it contains authentication data!"
    echo "=========================================="
    echo ""
}

# Function to check required software dependencies
check_dependencies() {
    local missing_deps=()
    local required_deps=("yt-dlp" "date" "echo" "head" "sed" "tr" "cut" "mkdir" "grep" "tail" "xargs" "dirname" "find")
    
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
    
    # Check optional dependencies
    if ! command -v jq &> /dev/null; then
        log_message "WARN" "Optional dependency 'jq' is not installed. Description extraction will use basic parsing."
        log_message "INFO" "For better JSON parsing, consider installing jq: https://jqlang.github.io/jq/"
    fi
    
    log_message "SUCCESS" "All required dependencies are met."
}

# Function to validate input file content
validate_input_file() {
    local input_file="$1"
    local total_lines=0
    local empty_lines=0
    local comment_lines=0
    local youtube_urls=0
    local non_youtube_urls=0
    local invalid_lines=0
    local non_youtube_examples=()
    
    log_message "INFO" "Validating file content: $input_file"
    
    # Read file line by line and analyze content
    while IFS= read -r line || [ -n "$line" ]; do
        total_lines=$((total_lines + 1))
        
        # Skip empty lines
        if [ -z "$line" ]; then
            empty_lines=$((empty_lines + 1))
            continue
        fi
        
        # Skip comment lines (starting with #)
        if [[ "$line" =~ ^[[:space:]]*# ]]; then
            comment_lines=$((comment_lines + 1))
            continue
        fi
        
        # Trim whitespace
        line=$(echo "$line" | xargs)
        
        # Skip if empty after trimming
        if [ -z "$line" ]; then
            empty_lines=$((empty_lines + 1))
            continue
        fi
        
        # Check if line looks like a URL
        if [[ "$line" =~ ^https?:// ]]; then
            # Check if it's a YouTube URL
            if [[ "$line" == *"youtube.com"* ]] || [[ "$line" == *"youtu.be"* ]]; then
                youtube_urls=$((youtube_urls + 1))
            else
                non_youtube_urls=$((non_youtube_urls + 1))
                # Store first few examples of non-YouTube URLs
                if [ ${#non_youtube_examples[@]} -lt 3 ]; then
                    non_youtube_examples+=("$line")
                fi
            fi
        else
            # Line doesn't look like a URL
            invalid_lines=$((invalid_lines + 1))
            # Store first few examples of invalid lines
            if [ ${#non_youtube_examples[@]} -lt 3 ]; then
                non_youtube_examples+=("$line")
            fi
        fi
    done < "$input_file"
    
    # Calculate meaningful content lines
    local content_lines=$((youtube_urls + non_youtube_urls + invalid_lines))
    
    # Display validation results
    log_message "INFO" "File content analysis:"
    echo "  - Total lines: $total_lines"
    echo "  - Empty lines: $empty_lines"
    echo "  - Comment lines: $comment_lines"
    echo "  - YouTube URLs: $youtube_urls"
    
    if [ $non_youtube_urls -gt 0 ]; then
        echo "  - Non-YouTube URLs: $non_youtube_urls"
    fi
    
    if [ $invalid_lines -gt 0 ]; then
        echo "  - Invalid/non-URL lines: $invalid_lines"
    fi
    
    # Show warnings for non-YouTube content
    if [ $non_youtube_urls -gt 0 ] || [ $invalid_lines -gt 0 ]; then
        echo ""
        log_message "WARN" "File contains non-YouTube content:"
        
        if [ $non_youtube_urls -gt 0 ]; then
            log_message "WARN" "Found $non_youtube_urls non-YouTube URLs. This script is optimized for YouTube content."
        fi
        
        if [ $invalid_lines -gt 0 ]; then
            log_message "WARN" "Found $invalid_lines lines that don't appear to be valid URLs."
        fi
        
        # Show examples of problematic content
        if [ ${#non_youtube_examples[@]} -gt 0 ]; then
            echo "  Examples of non-YouTube content:"
            for example in "${non_youtube_examples[@]}"; do
                echo "    - $example"
            done
        fi
        
        echo ""
        log_message "INFO" "Note: Non-YouTube URLs may not work with this tool."
        echo ""
        read -p "Continue anyway? (y/N): " continue_choice
        if [[ ! "$continue_choice" =~ ^[Yy] ]]; then
            log_message "INFO" "File processing cancelled."
            exit 0
        fi
    fi
    
    # Check if file has any processable content
    if [ $youtube_urls -eq 0 ] && [ $non_youtube_urls -eq 0 ]; then
        log_message "ERROR" "No valid URLs found in the file."
        log_message "INFO" "The file should contain URLs (one per line). Comments starting with # are allowed."
        exit 1
    fi
    
    if [ $youtube_urls -gt 0 ]; then
        log_message "SUCCESS" "File validation completed. Found $youtube_urls YouTube URLs to process."
    else
        log_message "WARN" "No YouTube URLs found. Proceeding with $non_youtube_urls non-YouTube URLs."
    fi
    
    return 0
}

# Function to normalize media URL and determine type (video, channel, playlist)
process_url() {
    local url="$1"
    
    # Detect URL type
    if [[ $url == *"youtube.com/watch"* ]] || [[ $url == *"youtu.be/"* ]]; then
        DOWNLOAD_TYPE="video"
    elif [[ $url == *"youtube.com/shorts/"* ]]; then
        DOWNLOAD_TYPE="video"  # Treat shorts as videos for download logic
        log_message "INFO" "Shorts URL detected"
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

# Function to get rate limiting arguments based on current mode
get_rate_limit_args() {
    local rate_args=()
    
    case "$RATE_LIMIT_MODE" in
        "fast")
            # Fast mode: minimal rate limiting (may trigger YouTube limits)
            rate_args+=(--sleep-interval 0)
            ;;
        "slow")
            # Slow mode: aggressive rate limiting to avoid limits
            rate_args+=(--sleep-interval "$SLOW_MIN_DELAY")
            rate_args+=(--max-sleep-interval "$SLOW_MAX_DELAY")
            rate_args+=(--retries 5)
            rate_args+=(--fragment-retries 5)
            rate_args+=(--retry-sleep 10)
            ;;
        "normal"|*)
            # Normal mode: balanced rate limiting
            rate_args+=(--sleep-interval "$NORMAL_MIN_DELAY")
            rate_args+=(--max-sleep-interval "$NORMAL_MAX_DELAY")
            rate_args+=(--retries 3)
            rate_args+=(--fragment-retries 3)
            rate_args+=(--retry-sleep 5)
            ;;
    esac
    
    echo "${rate_args[@]}"
}

# Function to generate equivalent command line
generate_command_line() {
    local cmd="./another_yt-dlp_wrapper.sh"
    
    # Add non-interactive flag
    cmd="$cmd --non-interactive"
    
    # Add URL or file
    if [ -n "$MEDIA_URL" ]; then
        cmd="$cmd --url \"$MEDIA_URL\""
    elif [ -n "$INPUT_FILE" ]; then
        cmd="$cmd --file \"$INPUT_FILE\""
    fi
    
    # Add output directory if different from current
    if [ "$OUTPUT_DIR" != "$(pwd)" ]; then
        cmd="$cmd --output-dir \"$OUTPUT_DIR\""
    fi
    
    # Add subtitle options
    if $DOWNLOAD_SUBTITLES; then
        cmd="$cmd --subs"
    fi
    if $DOWNLOAD_AUTO_SUBTITLES; then
        cmd="$cmd --auto-subs"
    fi
    if [ "$SUBTITLE_LANGUAGES" != "all" ] && ($DOWNLOAD_SUBTITLES || $DOWNLOAD_AUTO_SUBTITLES); then
        cmd="$cmd --sub-langs \"$SUBTITLE_LANGUAGES\""
    fi
    
    # Add authentication options
    if [ -n "$COOKIES_FROM_BROWSER" ]; then
        cmd="$cmd --cookies-from-browser \"$COOKIES_FROM_BROWSER\""
    elif [ -n "$COOKIES_FILE" ]; then
        cmd="$cmd --cookies-file \"$COOKIES_FILE\""
    fi
    
    # Add content type filters
    if ! $DOWNLOAD_VIDEOS; then
        cmd="$cmd --no-videos"
    fi
    if ! $DOWNLOAD_SHORTS; then
        cmd="$cmd --no-shorts"
    fi
    if ! $DOWNLOAD_LIVE; then
        cmd="$cmd --no-live"
    fi
    
    # Add rate limiting mode
    case "$RATE_LIMIT_MODE" in
        "slow")
            cmd="$cmd --slow"
            ;;
        "fast")
            cmd="$cmd --fast"
            ;;
        # "normal" is default, no flag needed
    esac
    
    echo "$cmd"
}

# Function to create channel information file
create_channel_info_file() {
    local url="$1"
    local channel_dir="$2"
    local info_file="$channel_dir/channel_info.txt"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    log_message "INFO" "Creating channel information file: $info_file"
    
    # Create the channel info file with basic information
    {
        echo "=== CHANNEL INFORMATION ==="
        echo "Download Date: $timestamp"
        echo "Original URL: $url"
        echo ""
        
        # Try to extract detailed channel information using yt-dlp
        log_message "DEBUG" "Extracting channel metadata..."
        
        # Get channel information in a single call to avoid multiple requests
        local channel_info
        channel_info=$(yt-dlp --quiet --print "%(channel)s|%(channel_id)s|%(channel_url)s|%(uploader)s|%(uploader_id)s|%(uploader_url)s|%(channel_follower_count)s|%(description)s" "$url" 2>/dev/null | head -1)
        
        if [ -n "$channel_info" ]; then
            # Split the pipe-separated values
            IFS='|' read -r channel_name channel_id channel_url uploader uploader_id uploader_url follower_count description <<< "$channel_info"
            
            # Display channel information
            if [ -n "$channel_name" ] && [ "$channel_name" != "NA" ]; then
                echo "Channel Name: $channel_name"
            fi
            
            if [ -n "$channel_id" ] && [ "$channel_id" != "NA" ]; then
                echo "Channel ID: $channel_id"
            fi
            
            if [ -n "$channel_url" ] && [ "$channel_url" != "NA" ]; then
                echo "Channel URL: $channel_url"
            fi
            
            if [ -n "$uploader" ] && [ "$uploader" != "NA" ] && [ "$uploader" != "$channel_name" ]; then
                echo "Uploader: $uploader"
            fi
            
            if [ -n "$uploader_id" ] && [ "$uploader_id" != "NA" ] && [ "$uploader_id" != "$channel_id" ]; then
                echo "Uploader ID: $uploader_id"
            fi
            
            if [ -n "$uploader_url" ] && [ "$uploader_url" != "NA" ] && [ "$uploader_url" != "$channel_url" ]; then
                echo "Uploader URL: $uploader_url"
            fi
            
            if [ -n "$follower_count" ] && [ "$follower_count" != "NA" ] && [ "$follower_count" != "0" ]; then
                echo "Followers: $follower_count"
            fi
            
            echo ""
            if [ -n "$description" ] && [ "$description" != "NA" ]; then
                echo "Description:"
                echo "$description" | head -10  # Limit description to first 10 lines
                echo ""
            fi
        else
            # Fallback: extract basic info from URL
            echo "Channel URL: $url"
            
            # Try to extract channel name from URL patterns
            if [[ $url == *"youtube.com/@"* ]]; then
                local extracted_name=$(echo "$url" | sed -n 's|.*youtube\.com/@\([^/?]*\).*|\1|p')
                if [ -n "$extracted_name" ]; then
                    echo "Channel Handle: @$extracted_name"
                fi
            elif [[ $url == *"youtube.com/c/"* ]]; then
                local extracted_name=$(echo "$url" | sed -n 's|.*youtube\.com/c/\([^/?]*\).*|\1|p')
                if [ -n "$extracted_name" ]; then
                    echo "Channel Name: $extracted_name"
                fi
            elif [[ $url == *"youtube.com/user/"* ]]; then
                local extracted_name=$(echo "$url" | sed -n 's|.*youtube\.com/user/\([^/?]*\).*|\1|p')
                if [ -n "$extracted_name" ]; then
                    echo "Username: $extracted_name"
                fi
            fi
            
            echo ""
            echo "Note: Detailed channel information could not be retrieved."
        fi
        
        echo "=== DOWNLOAD CONFIGURATION ==="
        echo "Output Directory: $channel_dir"
        echo "Download Videos: $DOWNLOAD_VIDEOS"
        echo "Download Shorts: $DOWNLOAD_SHORTS"
        echo "Download Live: $DOWNLOAD_LIVE"
        if $DOWNLOAD_SUBTITLES || $DOWNLOAD_AUTO_SUBTITLES; then
            echo "Download Subtitles: Yes"
            echo "Subtitle Languages: $SUBTITLE_LANGUAGES"
            if $DOWNLOAD_SUBTITLES; then
                echo "Manual Subtitles: Yes"
            fi
            if $DOWNLOAD_AUTO_SUBTITLES; then
                echo "Auto-generated Subtitles: Yes"
            fi
        else
            echo "Download Subtitles: No"
        fi
        echo "Rate Limiting Mode: $RATE_LIMIT_MODE"
        echo "Command Used: $(generate_command_line)"
        echo ""
        
        echo "=== DOWNLOAD HISTORY ==="
        if [ -f "$info_file" ] && grep -q "Last Download:" "$info_file" 2>/dev/null; then
            echo "Previous Downloads:"
            grep "Last Download:" "$info_file" 2>/dev/null | tail -5
        fi
        echo "Last Download: $timestamp"
        
    } > "$info_file"
    
    log_message "SUCCESS" "Channel information file created successfully"
}

# Function to update channel info file with download timestamp
update_channel_info_timestamp() {
    local channel_dir="$1"
    local info_file="$channel_dir/channel_info.txt"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    if [ -f "$info_file" ]; then
        # Add new timestamp to the file
        echo "Last Download: $timestamp" >> "$info_file"
        log_message "DEBUG" "Updated channel info file with new timestamp"
    fi
}

# Function to create description files from info.json files
create_description_files() {
    local content_dir="$1"
    
    log_message "DEBUG" "Creating description files with URLs in: $content_dir"
    
    # Find all info.json files in the directory
    find "$content_dir" -name "*.info.json" -type f 2>/dev/null | while read -r info_file; do
        # Get the base filename without extension
        local base_name="${info_file%.info.json}"
        local desc_file="${base_name}.description.txt"
        
        # Check if jq is available for better JSON parsing
        if command -v jq &> /dev/null; then
            # Extract URL and description using jq
            local video_url=$(jq -r '.webpage_url // .url // "URL not available"' "$info_file" 2>/dev/null)
            local description=$(jq -r '.description // "No description available"' "$info_file" 2>/dev/null)
            
            # Create description file with URL
            {
                echo "Video URL: $video_url"
                echo ""
                echo "Description:"
                echo "----------------------------------------"
                echo "$description"
            } > "$desc_file"
        else
            # Fallback: use grep and sed for basic extraction (less reliable)
            local video_url=$(grep -o '"webpage_url"[[:space:]]*:[[:space:]]*"[^"]*"' "$info_file" 2>/dev/null | sed 's/.*"webpage_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1)
            local description=$(grep -o '"description"[[:space:]]*:[[:space:]]*"[^"]*"' "$info_file" 2>/dev/null | sed 's/.*"description"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' | head -1)
            
            # If extraction failed, provide defaults
            if [ -z "$video_url" ]; then
                video_url="URL not available"
            fi
            if [ -z "$description" ]; then
                description="No description available"
            fi
            
            # Create description file with URL
            {
                echo "Video URL: $video_url"
                echo ""
                echo "Description:"
                echo "----------------------------------------"
                echo "$description"
            } > "$desc_file"
        fi
        
        log_message "DEBUG" "Created description file: $desc_file"
    done
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
    
    # Download thumbnail for all content types
    yt_dlp_args+=(--write-thumbnail)
    
    # Write info.json to extract URL and description later
    yt_dlp_args+=(--write-info-json)
    
    # Add authentication options if configured
    if [ -n "$COOKIES_FROM_BROWSER" ]; then
        yt_dlp_args+=(--cookies-from-browser "$COOKIES_FROM_BROWSER")
        log_message "INFO" "Using cookies from browser: $COOKIES_FROM_BROWSER"
    elif [ -n "$COOKIES_FILE" ]; then
        if [ -f "$COOKIES_FILE" ]; then
            yt_dlp_args+=(--cookies "$COOKIES_FILE")
            log_message "INFO" "Using cookies from file: $COOKIES_FILE"
        else
            log_message "ERROR" "Cookies file not found: $COOKIES_FILE"
            return 1
        fi
    fi
    
    # Rate limiting protection to avoid YouTube blocks
    yt_dlp_args+=($(get_rate_limit_args))
    
    log_message "INFO" "Rate limiting protection enabled (${RATE_LIMIT_MODE} mode)"
    
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
            
            # Create channel information file
            create_channel_info_file "$url" "$channel_dir"
            
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
                        # Filter for regular videos: not live and not shorts (URL-based)
                        type_args+=(--match-filter "!is_live & original_url!~='/shorts/'")
                        ;;
                    "shorts")
                        type_args+=(--extractor-args "youtube:tab=shorts")
                        # Filter for shorts: URL contains /shorts/ and not live
                        type_args+=(--match-filter "!is_live & original_url~='/shorts/'")
                        ;;
                    "lives")
                        type_args+=(--extractor-args "youtube:tab=videos")
                        # Filter for live streams/recordings (both current and past)
                        type_args+=(--match-filter "is_live")
                        type_args+=(--match-filter "was_live")
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
                else
                    # Normal execution without special logging
                    yt-dlp "${type_args[@]}" "$url"
                fi
                
                # Create description files with URLs from info.json
                create_description_files "$type_dir"
            done
            
            # Update channel info file with download timestamp
            update_channel_info_timestamp "$channel_dir"
            ;;
            
        "playlist"|"channel")
            # Get channel name for the directory
            channel_name=$(get_channel_name "$url")
            channel_dir="$output_dir/$channel_name"
            
            log_message "INFO" "Downloading $DOWNLOAD_TYPE: $channel_name"
            log_message "INFO" "Base output directory: $channel_dir"
            
            # Create channel directory if it doesn't exist
            mkdir -p "$channel_dir"
            
            # Create channel information file
            create_channel_info_file "$url" "$channel_dir"
            
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
                        # Filter for regular videos: not live and not shorts (URL-based)
                        type_args+=(--match-filter "!is_live & original_url!~='/shorts/'")
                        ;;
                    "shorts")
                        type_args+=(--extractor-args "youtube:tab=shorts")
                        # Filter for shorts: URL contains /shorts/ and not live
                        type_args+=(--match-filter "!is_live & original_url~='/shorts/'")
                        ;;
                    "lives")
                        type_args+=(--extractor-args "youtube:tab=videos")
                        # Filter for live streams/recordings (both current and past)
                        type_args+=(--match-filter "is_live")
                        type_args+=(--match-filter "was_live")
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
                else
                    # Normal execution without special logging
                    yt-dlp "${type_args[@]}" "$url"
                fi
                
                # Create description files with URLs from info.json
                create_description_files "$type_dir"
            done
            
            # Update channel info file with download timestamp
            update_channel_info_timestamp "$channel_dir"
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
    
    # Validate file content
    validate_input_file "$input_file"
    
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
    
    # Ask for input type (single URL or file with URLs)
    echo ""
    echo "Input options:"
    echo "  1) Single URL (video, channel, or playlist) [default]"
    echo "  2) Text file with list of URLs (one per line)"
    
    # Loop until valid input is provided
    while true; do
        read -p "Choose input type (1/2): " input_choice
        
        # Default to URL (option 1) if no input provided
        if [ -z "$input_choice" ]; then
            input_choice="1"
            break
        fi
        
        # Validate input
        case "$input_choice" in
            "1"|"2")
                break
                ;;
            *)
                log_message "ERROR" "Invalid input '$input_choice'. Please enter 1 or 2, or press Enter for default."
                ;;
        esac
    done
    
    case "$input_choice" in
        "2"|"file"|"f")
            # Ask for input file
            read -p "Enter path to text file with URLs: " INPUT_FILE
            if [ -z "$INPUT_FILE" ]; then
                log_message "ERROR" "No file path provided."
                exit 1
            fi
            
            # Expand tilde to home directory if used
            INPUT_FILE="${INPUT_FILE/#\~/$HOME}"
            
            # Check if file exists
            if [ ! -f "$INPUT_FILE" ]; then
                log_message "ERROR" "Input file not found: $INPUT_FILE"
                exit 1
            fi
            
            # Validate file content
            validate_input_file "$INPUT_FILE"
            
            log_message "INFO" "Will process URLs from file: $INPUT_FILE"
            ;;
        *|"1"|"url"|"u")
            # Ask for single media URL
            read -p "Enter media URL (video, channel, or playlist): " MEDIA_URL
            if [ -z "$MEDIA_URL" ]; then
                log_message "ERROR" "No URL provided."
                exit 1
            fi
            
            # Process URL to determine type
            if ! process_url "$MEDIA_URL"; then
                exit 1
            fi
            ;;
    esac
    
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
    
    # Ask about authentication
    echo ""
    echo "Authentication options:"
    echo "  (Use cookies to access private videos, members-only content, or bypass age restrictions)"
    read -p "Use authentication? (y/N): " use_auth
    if [[ "$use_auth" =~ ^[Yy] ]]; then
        echo ""
        echo "Authentication methods:"
        echo "  1) Extract cookies from browser (recommended)"
        echo "  2) Use cookies from file"
        echo "  3) Show cookie setup guide"
        
        while true; do
            read -p "Choose method (1/2/3): " auth_method
            
            case "$auth_method" in
                "1")
                    echo ""
                    echo "Available browsers: chrome, firefox, edge, safari, opera, brave, vivaldi"
                    read -p "Enter browser name: " browser_name
                    if [ -n "$browser_name" ]; then
                        COOKIES_FROM_BROWSER="$browser_name"
                        echo "Will use cookies from $browser_name browser."
                    fi
                    break
                    ;;
                "2")
                    read -p "Enter path to cookies file: " cookies_path
                    if [ -n "$cookies_path" ]; then
                        # Expand tilde to home directory if used
                        COOKIES_FILE="${cookies_path/#\~/$HOME}"
                        if [ -f "$COOKIES_FILE" ]; then
                            echo "Will use cookies from file: $COOKIES_FILE"
                        else
                            log_message "WARN" "Cookies file not found: $COOKIES_FILE"
                            read -p "Continue anyway? (y/N): " continue_cookies
                            if [[ ! "$continue_cookies" =~ ^[Yy] ]]; then
                                COOKIES_FILE=""
                            fi
                        fi
                    fi
                    break
                    ;;
                "3")
                    show_cookie_guide
                    read -p "Press Enter to continue..."
                    ;;
                *)
                    echo "Invalid choice. Please enter 1, 2, or 3."
                    ;;
            esac
        done
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
    
    # Ask about download speed/rate limiting
    echo ""
    echo "Download speed options:"
    echo "  1) Normal mode (default) - Balanced speed with 1-3 sec delays"
    echo "  2) Slow mode - Slower with 5-10 sec delays to avoid rate limits"
    echo "  3) Fast mode - No delays (may trigger YouTube rate limits)"
    
    # Loop until valid input is provided
    while true; do
        read -p "Choose download mode (1/2/3): " speed_choice
        
        # Default to normal mode (option 1) if no input provided
        if [ -z "$speed_choice" ]; then
            speed_choice="1"
            break
        fi
        
        # Validate input
        case "$speed_choice" in
            "1"|"2"|"3")
                break
                ;;
            *)
                log_message "ERROR" "Invalid input '$speed_choice'. Please enter 1, 2, or 3, or press Enter for default."
                ;;
        esac
    done
    
    case "$speed_choice" in
        "2"|"slow"|"s")
            RATE_LIMIT_MODE="slow"
            echo "Slow mode selected (5-10 sec delays)."
            ;;
        "3"|"fast"|"f")
            RATE_LIMIT_MODE="fast"
            echo "Fast mode selected (no delays - may trigger limits)."
            ;;
        *|"1"|"normal"|"n")
            RATE_LIMIT_MODE="normal"
            echo "Normal mode selected (1-3 sec delays)."
            ;;
    esac
    
    # Confirm with user
    echo ""
    log_message "INFO" "Ready to download:"
    if [ -n "$INPUT_FILE" ]; then
        echo "  Type: Multiple URLs from file"
        echo "  Input File: $INPUT_FILE"
    else
        echo "  Type: $DOWNLOAD_TYPE"
        echo "  URL: $MEDIA_URL"
    fi
    echo "  Output Directory: $OUTPUT_DIR"
    if $DOWNLOAD_SUBTITLES; then
        echo "  Manual Subtitles: Yes (languages: $SUBTITLE_LANGUAGES)"
    fi
    if $DOWNLOAD_AUTO_SUBTITLES; then
        echo "  Auto-generated Subtitles: Yes (languages: $SUBTITLE_LANGUAGES)"
    fi
    if [ -n "$COOKIES_FROM_BROWSER" ]; then
        echo "  Authentication: Cookies from $COOKIES_FROM_BROWSER browser"
    elif [ -n "$COOKIES_FILE" ]; then
        echo "  Authentication: Cookies from file ($COOKIES_FILE)"
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
    echo "  Download mode: $RATE_LIMIT_MODE"
    echo ""
    if [ -n "$INPUT_FILE" ]; then
        echo "Equivalent command line:"
        echo "./another_yt-dlp_wrapper.sh --non-interactive --file \"$INPUT_FILE\" --output-dir \"$OUTPUT_DIR\"$(
            if $DOWNLOAD_SUBTITLES; then echo -n " --subs"; fi
            if $DOWNLOAD_AUTO_SUBTITLES; then echo -n " --auto-subs"; fi
            if [ "$SUBTITLE_LANGUAGES" != "all" ] && ($DOWNLOAD_SUBTITLES || $DOWNLOAD_AUTO_SUBTITLES); then echo -n " --sub-langs \"$SUBTITLE_LANGUAGES\""; fi
            if ! $DOWNLOAD_VIDEOS; then echo -n " --no-videos"; fi
            if ! $DOWNLOAD_SHORTS; then echo -n " --no-shorts"; fi
            if ! $DOWNLOAD_LIVE; then echo -n " --no-live"; fi
            case "$RATE_LIMIT_MODE" in
                "slow") echo -n " --slow" ;;
                "fast") echo -n " --fast" ;;
            esac
        )"
    else
        echo "Equivalent command line:"
        echo "$(generate_command_line)"
    fi
    echo ""
    read -p "Continue? (Y/n): " confirm
    if [[ "$confirm" =~ ^[Nn] ]]; then
        log_message "INFO" "Download cancelled."
        exit 0
    fi
    
    # Start download
    if [ -n "$INPUT_FILE" ]; then
        process_input_file "$INPUT_FILE"
    else
        download_videos "$MEDIA_URL" "$OUTPUT_DIR"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --cookie-guide)
            show_cookie_guide
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
        --slow)
            RATE_LIMIT_MODE="slow"
            log_message "INFO" "Rate limiting set to slow mode (${SLOW_MIN_DELAY}-${SLOW_MAX_DELAY}s delays)"
            shift
            ;;
        --fast)
            RATE_LIMIT_MODE="fast"
            log_message "INFO" "Rate limiting disabled (fast mode - may trigger YouTube limits)"
            shift
            ;;
        --cookies-from-browser)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                COOKIES_FROM_BROWSER="$2"
                log_message "INFO" "Will extract cookies from browser: $COOKIES_FROM_BROWSER"
                shift 2
            else
                log_message "ERROR" "Argument for $1 is missing."
                exit 1
            fi
            ;;
        --cookies-file)
            if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                # Expand tilde to home directory if used
                COOKIES_FILE="${2/#\~/$HOME}"
                if [ -f "$COOKIES_FILE" ]; then
                    log_message "INFO" "Will use cookies from file: $COOKIES_FILE"
                else
                    log_message "WARN" "Cookies file not found: $COOKIES_FILE"
                fi
                shift 2
            else
                log_message "ERROR" "Argument for $1 is missing."
                exit 1
            fi
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
        # Expand tilde to home directory if used
        INPUT_FILE="${INPUT_FILE/#\~/$HOME}"
        
        # Check if file exists
        if [ ! -f "$INPUT_FILE" ]; then
            log_message "ERROR" "Input file not found: $INPUT_FILE"
            exit 1
        fi
        
        # Validate file content
        validate_input_file "$INPUT_FILE"
        
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
