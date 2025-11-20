#!/usr/bin/env bash

# Script to download Bing Image of the Day

# Function to check required software dependencies
check_dependencies() {
    local missing_deps=()
    local optional_deps=()
    local required_deps=("curl" "grep" "sed" "basename" "mkdir" "cp")
    local recommended_deps=("jq")
    
    if ! $SILENT_MODE; then
        echo "Checking required dependencies..."
    fi
    
    # Check required dependencies
    for cmd in "${required_deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # Check for optional dependencies
    for cmd in "${recommended_deps[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            optional_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo "ERROR: The following required dependencies are missing:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        echo "Please install these dependencies and try again."
        exit 1
    fi
    
    if [ ${#optional_deps[@]} -ne 0 ] && ! $QUIET_MODE && ! $SILENT_MODE; then
        echo "NOTE: The following recommended dependencies are missing:"
        for dep in "${optional_deps[@]}"; do
            echo "  - $dep"
        done
        echo "Installing these will improve script functionality."
        # Give time for user to read the message
        if [ -t 0 ]; then  # Only if it's an interactive terminal
            sleep 2
        fi
    fi
    
    if ! $QUIET_MODE && ! $SILENT_MODE; then
        echo "All required dependencies are installed."
    fi
    
    # Set flag to indicate if we have jq available
    if command -v "jq" &> /dev/null; then
        HAS_JQ=true
    else
        HAS_JQ=false
    fi
}

# Function to display help information
show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -o, --output PATH       Specify the output directory for images and info files"
    echo "  -w, --wallpaper PATH    Specify a second directory to save image as wallpaper"
    echo "  -l, --locale LOCALE     Specify the locale to use (e.g., en-US, it-IT, etc.)"
    echo "  -q, --quiet             Quiet mode, minimal output"
    echo "  -s, --silent            Silent mode, no output at all (implies --quiet)"
    echo "  -h, --help              Display this help message and exit"
    echo
    echo "Examples:"
    echo "  $0 --output ~/Pictures/BingImages"
    echo "  $0 --wallpaper ~/Pictures/Wallpapers"
    echo "  $0 --locale it-IT"
    echo "  $0 --silent"
    echo "  $0 -o ~/Pictures/BingImages -w ~/Pictures/Wallpapers -l en-GB"
    echo
    echo "Note: Settings can also be defined in env.conf file, but command-line options take precedence."
}

# Default values
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/env.conf"
WALLPAPERS_DIR="$SCRIPT_DIR/wallpapers"
SECOND_PATH=""
QUIET_MODE=false
SILENT_MODE=false
CLI_LOCALE=""
HAS_JQ=false

# Parse command line options
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -o|--output)
            WALLPAPERS_DIR="$2"
            shift
            shift
            ;;
        -w|--wallpaper)
            SECOND_PATH="$2"
            shift
            shift
            ;;
        -l|--locale)
            CLI_LOCALE="$2"
            shift
            shift
            ;;
        -q|--quiet)
            QUIET_MODE=true
            shift
            ;;
        -s|--silent)
            SILENT_MODE=true
            QUIET_MODE=true  # Silent mode implies quiet mode
            shift
            ;;
        -h|--help)
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

# Check required dependencies before proceeding
check_dependencies

# Check if config file exists, otherwise create it with default values
if [ ! -f "$CONFIG_FILE" ]; then
    {
        echo "LOCALE=en-US"
        echo "# OUTPUT_DIR="
        echo "# WALLPAPER_DIR="
    } > "$CONFIG_FILE"
    
    if ! $QUIET_MODE; then
        echo "Configuration file created with default values"
    fi
fi

# Read configuration from env.conf
source "$CONFIG_FILE"

# Command-line options take precedence over config file settings
# If not specified on command line, use values from env.conf
if [ -z "$CLI_LOCALE" ]; then
    # LOCALE already set from env.conf
    :
else
    LOCALE="$CLI_LOCALE"
fi

# Check if OUTPUT_DIR is defined in env.conf and not overridden by command line
if [ -z "$WALLPAPERS_DIR" ] || [ "$WALLPAPERS_DIR" = "$SCRIPT_DIR/wallpapers" ]; then
    if [ -n "$OUTPUT_DIR" ]; then
        WALLPAPERS_DIR="$OUTPUT_DIR"
    else
        WALLPAPERS_DIR="$SCRIPT_DIR/wallpapers"
    fi
fi

# Check if WALLPAPER_DIR is defined in env.conf and not overridden by command line
if [ -z "$SECOND_PATH" ]; then
    if [ -n "$WALLPAPER_DIR" ]; then
        SECOND_PATH="$WALLPAPER_DIR"
    fi
fi

# Create wallpapers directory if it doesn't exist
mkdir -p "$WALLPAPERS_DIR"

# Create second path directory if specified and it doesn't exist
if [ -n "$SECOND_PATH" ]; then
    mkdir -p "$SECOND_PATH"
fi

if ! $QUIET_MODE && ! $SILENT_MODE; then
    echo "Currently selected locale: $LOCALE"
    echo "Output directory: $WALLPAPERS_DIR"
    if [ -n "$SECOND_PATH" ]; then
        echo "Wallpaper directory: $SECOND_PATH"
    fi
fi

# Function to detect locale based on IP address
detect_locale_from_ip() {
    if ! $QUIET_MODE && ! $SILENT_MODE; then
        echo "Detecting locale from IP address..."
    fi
    
    # Get public IP address using multiple services for redundancy
    # Try ifconfig.co first (direct country code, more reliable)
    COUNTRY_CODE=$(curl -s https://ifconfig.co/country-iso)
    
    # If ifconfig.co fails, try ipinfo.io
    if [ -z "$COUNTRY_CODE" ]; then
        if ! $QUIET_MODE && ! $SILENT_MODE; then
            echo "First service failed, trying alternative service..."
        fi
        IP_INFO=$(curl -s https://ipinfo.io)
        COUNTRY_CODE=$(echo "$IP_INFO" | grep -o '"country":"[^"]*"' | sed 's/"country":"\(.*\)"/\1/')
    fi
    
    # If both fail, try ip-api.com
    if [ -z "$COUNTRY_CODE" ]; then
        if ! $QUIET_MODE && ! $SILENT_MODE; then
            echo "Second service failed, trying another alternative..."
        fi
        IP_INFO=$(curl -s http://ip-api.com/json)
        COUNTRY_CODE=$(echo "$IP_INFO" | grep -o '"countryCode":"[^"]*"' | sed 's/"countryCode":"\(.*\)"/\1/')
    fi
    
    if [ -z "$COUNTRY_CODE" ]; then
        if ! $QUIET_MODE && ! $SILENT_MODE; then
            echo "Could not detect country from IP. Defaulting to en-US."
        fi
        echo "en-US"
        return
    fi
    
    if ! $QUIET_MODE && ! $SILENT_MODE; then
        echo "Detected country code: $COUNTRY_CODE"
    fi
    
    # Map country code to locale
    case "$COUNTRY_CODE" in
        "US") echo "en-US" ;;
        "GB") echo "en-GB" ;;
        "AU") echo "en-AU" ;;
        "CA") echo "en-CA" ;;
        "IN") echo "en-IN" ;;
        "DE") echo "de-DE" ;;
        "AT") echo "de-AT" ;;
        "CH") echo "de-CH" ;;
        "FR") echo "fr-FR" ;;
        "IT") echo "it-IT" ;;
        "ES") echo "es-ES" ;;
        "MX") echo "es-MX" ;;
        "JP") echo "ja-JP" ;;
        "CN") echo "zh-CN" ;;
        "TW") echo "zh-TW" ;;
        "HK") echo "zh-HK" ;;
        "BR") echo "pt-BR" ;;
        "PT") echo "pt-PT" ;;
        "RU") echo "ru-RU" ;;
        "UA") echo "uk-UA" ;;
        "NL") echo "nl-NL" ;;
        "BE") echo "nl-BE" ;;  # Note: Belgium could be fr-BE too, but we default to nl-BE
        "NO") echo "nb-NO" ;;
        "SE") echo "sv-SE" ;;
        "DK") echo "da-DK" ;;
        "FI") echo "fi-FI" ;;
        "PL") echo "pl-PL" ;;
        "CZ") echo "cs-CZ" ;;
        "SK") echo "sk-SK" ;;
        "HU") echo "hu-HU" ;;
        "RO") echo "ro-RO" ;;
        "GR") echo "el-GR" ;;
        "TR") echo "tr-TR" ;;
        "IL") echo "he-IL" ;;
        "TH") echo "th-TH" ;;
        *) 
            if ! $QUIET_MODE && ! $SILENT_MODE; then
                echo "Country $COUNTRY_CODE not mapped to a specific locale. Defaulting to en-US."
            fi
            echo "en-US" 
            ;;
    esac
}

# Function to change locale
change_locale() {
    echo "Select a locale:"
    echo "1) Auto (detect from IP) (auto)"
    echo "2) Arabic (ar-XA)"
    echo "3) Bulgarian (bg-BG)"
    echo "4) Czech (cs-CZ)"
    echo "5) Danish (da-DK)"
    echo "6) German - Austria (de-AT)"
    echo "7) German - Switzerland (de-CH)"
    echo "8) German - Germany (de-DE)"
    echo "9) Greek (el-GR)"
    echo "10) English - Australia (en-AU)"
    echo "11) English - Canada (en-CA)"
    echo "12) English - United Kingdom (en-GB)"
    echo "13) English - Indonesia (en-ID)"
    echo "14) English - Ireland (en-IE)"
    echo "15) English - India (en-IN)"
    echo "16) English - Malaysia (en-MY)"
    echo "17) English - New Zealand (en-NZ)"
    echo "18) English - Philippines (en-PH)"
    echo "19) English - Singapore (en-SG)"
    echo "20) English - United States (en-US)"
    echo "21) English - South Africa (en-ZA)"
    echo "22) Spanish - Argentina (es-AR)"
    echo "23) Spanish - Chile (es-CL)"
    echo "24) Spanish - Spain (es-ES)"
    echo "25) Spanish - Mexico (es-MX)"
    echo "26) Spanish - United States (es-US)"
    echo "27) Estonian (et-EE)"
    echo "28) Finnish (fi-FI)"
    echo "29) French - Belgium (fr-BE)"
    echo "30) French - Canada (fr-CA)"
    echo "31) French - Switzerland (fr-CH)"
    echo "32) French - France (fr-FR)"
    echo "33) Hebrew (he-IL)"
    echo "34) Croatian (hr-HR)"
    echo "35) Hungarian (hu-HU)"
    echo "36) Italian (it-IT)"
    echo "37) Japanese (ja-JP)"
    echo "38) Korean (ko-KR)"
    echo "39) Lithuanian (lt-LT)"
    echo "40) Latvian (lv-LV)"
    echo "41) Norwegian (nb-NO)"
    echo "42) Dutch - Belgium (nl-BE)"
    echo "43) Dutch - Netherlands (nl-NL)"
    echo "44) Polish (pl-PL)"
    echo "45) Portuguese - Brazil (pt-BR)"
    echo "46) Portuguese - Portugal (pt-PT)"
    echo "47) Romanian (ro-RO)"
    echo "48) Russian (ru-RU)"
    echo "49) Slovak (sk-SK)"
    echo "50) Slovenian (sl-SL)"
    echo "51) Swedish (sv-SE)"
    echo "52) Thai (th-TH)"
    echo "53) Turkish (tr-TR)"
    echo "54) Ukrainian (uk-UA)"
    echo "55) Chinese - China (zh-CN)"
    echo "56) Chinese - Hong Kong (zh-HK)"
    echo "57) Chinese - Taiwan (zh-TW)"
    echo "0) Cancel"
    
    read -p "Enter the corresponding number: " selection
    
    case $selection in
        1) 
            echo "Detecting locale from IP address..."
            # Capture only the locale result, not the debug messages
            new_locale=$(detect_locale_from_ip)
            # Store the fact that we're using auto detection
            is_auto_detected=true
            echo "Detected locale: $new_locale (auto)"
            ;;
        2) new_locale="ar-XA" ;;
        3) new_locale="bg-BG" ;;
        4) new_locale="cs-CZ" ;;
        5) new_locale="da-DK" ;;
        6) new_locale="de-AT" ;;
        7) new_locale="de-CH" ;;
        8) new_locale="de-DE" ;;
        9) new_locale="el-GR" ;;
        10) new_locale="en-AU" ;;
        11) new_locale="en-CA" ;;
        12) new_locale="en-GB" ;;
        13) new_locale="en-ID" ;;
        14) new_locale="en-IE" ;;
        15) new_locale="en-IN" ;;
        16) new_locale="en-MY" ;;
        17) new_locale="en-NZ" ;;
        18) new_locale="en-PH" ;;
        19) new_locale="en-SG" ;;
        20) new_locale="en-US" ;;
        21) new_locale="en-ZA" ;;
        22) new_locale="es-AR" ;;
        23) new_locale="es-CL" ;;
        24) new_locale="es-ES" ;;
        25) new_locale="es-MX" ;;
        26) new_locale="es-US" ;;
        27) new_locale="et-EE" ;;
        28) new_locale="fi-FI" ;;
        29) new_locale="fr-BE" ;;
        30) new_locale="fr-CA" ;;
        31) new_locale="fr-CH" ;;
        32) new_locale="fr-FR" ;;
        33) new_locale="he-IL" ;;
        34) new_locale="hr-HR" ;;
        35) new_locale="hu-HU" ;;
        36) new_locale="it-IT" ;;
        37) new_locale="ja-JP" ;;
        38) new_locale="ko-KR" ;;
        39) new_locale="lt-LT" ;;
        40) new_locale="lv-LV" ;;
        41) new_locale="nb-NO" ;;
        42) new_locale="nl-BE" ;;
        43) new_locale="nl-NL" ;;
        44) new_locale="pl-PL" ;;
        45) new_locale="pt-BR" ;;
        46) new_locale="pt-PT" ;;
        47) new_locale="ro-RO" ;;
        48) new_locale="ru-RU" ;;
        49) new_locale="sk-SK" ;;
        50) new_locale="sl-SL" ;;
        51) new_locale="sv-SE" ;;
        52) new_locale="th-TH" ;;
        53) new_locale="tr-TR" ;;
        54) new_locale="uk-UA" ;;
        55) new_locale="zh-CN" ;;
        56) new_locale="zh-HK" ;;
        57) new_locale="zh-TW" ;;
        0) return ;;
        *) 
            if ! $SILENT_MODE; then
                echo "Invalid selection"
            fi
            return ;;
    esac
    
    # Keep other settings when changing locale
    if [ -n "$OUTPUT_DIR" ]; then
        if [ "$is_auto_detected" = true ]; then
            echo "LOCALE=$new_locale
LOCALE_AUTO=true
OUTPUT_DIR=$OUTPUT_DIR
WALLPAPER_DIR=$WALLPAPER_DIR" > "$CONFIG_FILE"
        else
            echo "LOCALE=$new_locale
LOCALE_AUTO=false
OUTPUT_DIR=$OUTPUT_DIR
WALLPAPER_DIR=$WALLPAPER_DIR" > "$CONFIG_FILE"
        fi
    else
        if [ "$is_auto_detected" = true ]; then
            echo "LOCALE=$new_locale
LOCALE_AUTO=true" > "$CONFIG_FILE"
        else
            echo "LOCALE=$new_locale
LOCALE_AUTO=false" > "$CONFIG_FILE"
        fi
        
        # Add commented examples if they don't exist yet
        echo "# OUTPUT_DIR=/path/to/your/images" >> "$CONFIG_FILE"
        echo "# WALLPAPER_DIR=/path/to/your/wallpaper" >> "$CONFIG_FILE"
    fi
    
    if [ "$is_auto_detected" = true ]; then
        echo "Locale auto-detected and changed successfully to: $new_locale"
    else
        echo "Locale changed successfully to: $new_locale"
    fi
    
    # Re-source the config file properly
    LOCALE=$(grep "^LOCALE=" "$CONFIG_FILE" | cut -d'=' -f2)
    LOCALE_AUTO=$(grep "^LOCALE_AUTO=" "$CONFIG_FILE" | cut -d'=' -f2)
    OUTPUT_DIR=$(grep "^OUTPUT_DIR=" "$CONFIG_FILE" | cut -d'=' -f2)
    WALLPAPER_DIR=$(grep "^WALLPAPER_DIR=" "$CONFIG_FILE" | cut -d'=' -f2)
}

# Function to download image of the day
download_image() {
    # Use the already detected locale from config
    local actual_locale="$LOCALE"
    
    if ! $QUIET_MODE && ! $SILENT_MODE; then
        if [ "$LOCALE_AUTO" = "true" ]; then
            echo "Using auto-detected locale: $actual_locale"
        else
            echo "Using selected locale: $actual_locale"
        fi
        
        echo "Downloading Bing Image of the Day for locale: $actual_locale"
    fi
    
    # Base URL for Bing
    BING_URL="https://www.bing.com"
    
    # Get image metadata from Bing API
    API_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=$actual_locale"
    
    if ! $QUIET_MODE && ! $SILENT_MODE; then
        echo "Requesting metadata from: $API_URL"
    fi
    
    JSON_DATA=$(curl -s "$API_URL")
    
    # Check if the API call was successful
    if [ -z "$JSON_DATA" ]; then
        if ! $SILENT_MODE; then
            echo "Error: Failed to get data from Bing API."
        fi
        return 1
    fi
    
    # Extract needed fields for the image
    if $HAS_JQ; then
        # Use jq for more reliable JSON parsing
        IMAGE_RELATIVE_URL=$(echo "$JSON_DATA" | jq -r '.images[0].url')
        IMAGE_TITLE=$(echo "$JSON_DATA" | jq -r '.images[0].title')
        IMAGE_COPYRIGHT=$(echo "$JSON_DATA" | jq -r '.images[0].copyright')
        IMAGE_COPYRIGHT_LINK=$(echo "$JSON_DATA" | jq -r '.images[0].copyrightlink')
        IMAGE_START_DATE=$(echo "$JSON_DATA" | jq -r '.images[0].startdate')
        IMAGE_FULLSTART_DATE=$(echo "$JSON_DATA" | jq -r '.images[0].fullstartdate')
        IMAGE_ENDDATE=$(echo "$JSON_DATA" | jq -r '.images[0].enddate')
        IMAGE_HEADLINE=$(echo "$JSON_DATA" | jq -r '.images[0].headline // "None"')
        IMAGE_WP=$(echo "$JSON_DATA" | jq -r '.images[0].wp // "None"')
        IMAGE_QUIZ=$(echo "$JSON_DATA" | jq -r '.images[0].quiz // "None"')
    else
        # Fallback to grep and sed if jq is not available
        IMAGE_RELATIVE_URL=$(echo "$JSON_DATA" | grep -o '"url":"[^"]*"' | head -1 | sed 's/"url":"\(.*\)"/\1/')
        IMAGE_TITLE=$(echo "$JSON_DATA" | grep -o '"title":"[^"]*"' | head -1 | sed 's/"title":"\(.*\)"/\1/')
        IMAGE_COPYRIGHT=$(echo "$JSON_DATA" | grep -o '"copyright":"[^"]*"' | head -1 | sed 's/"copyright":"\(.*\)"/\1/')
        IMAGE_COPYRIGHT_LINK=$(echo "$JSON_DATA" | grep -o '"copyrightlink":"[^"]*"' | head -1 | sed 's/"copyrightlink":"\(.*\)"/\1/')
        IMAGE_START_DATE=$(echo "$JSON_DATA" | grep -o '"startdate":"[^"]*"' | head -1 | sed 's/"startdate":"\(.*\)"/\1/')
        IMAGE_FULLSTART_DATE=$(echo "$JSON_DATA" | grep -o '"fullstartdate":"[^"]*"' | head -1 | sed 's/"fullstartdate":"\(.*\)"/\1/')
        IMAGE_ENDDATE=$(echo "$JSON_DATA" | grep -o '"enddate":"[^"]*"' | head -1 | sed 's/"enddate":"\(.*\)"/\1/')
        IMAGE_HEADLINE=$(echo "$JSON_DATA" | grep -o '"headline":"[^"]*"' | head -1 | sed 's/"headline":"\(.*\)"/\1/' || echo "None")
        IMAGE_WP=$(echo "$JSON_DATA" | grep -o '"wp":[^,]*' | head -1 | sed 's/"wp":\(.*\)/\1/' || echo "None")
        IMAGE_QUIZ=$(echo "$JSON_DATA" | grep -o '"quiz":"[^"]*"' | head -1 | sed 's/"quiz":"\(.*\)"/\1/' || echo "None")
    fi
    
    # Check if we got a valid URL
    if [ -z "$IMAGE_RELATIVE_URL" ]; then
        if ! $SILENT_MODE; then
            echo "Unable to find image URL in API response."
        fi
        return 1
    fi
    
    # Construct the full image URL
    IMAGE_URL="${BING_URL}${IMAGE_RELATIVE_URL}"
    
    if ! $QUIET_MODE && ! $SILENT_MODE; then
        echo "Downloading image: $IMAGE_URL"
    fi
    
    # Extract original filename from URL
    ORIGINAL_FILENAME=$(basename "$IMAGE_RELATIVE_URL" | cut -d '?' -f 1)
    
    # Extract file extension (look for common image extensions)
    # Default to jpg if no valid extension is found
    FILE_EXTENSION="jpg"
    if [[ "$ORIGINAL_FILENAME" =~ \.(jpg|jpeg|png|webp|gif|bmp)$ ]]; then
        FILE_EXTENSION="${BASH_REMATCH[1]}"
    fi
    
    # Current date for info filename prefix
    DATE=$(date +"%Y%m%d")
    
    # Use the image start date to create a more meaningful filename
    IMAGE_PATH="$WALLPAPERS_DIR/${DATE}_${ORIGINAL_FILENAME}"
    INFO_FILENAME="${DATE}_${ORIGINAL_FILENAME%.*}.txt"
    INFO_PATH="$WALLPAPERS_DIR/$INFO_FILENAME"
    
    # Download the image
    curl -s "$IMAGE_URL" -o "$IMAGE_PATH"
    
    if [ $? -eq 0 ]; then
        if ! $QUIET_MODE && ! $SILENT_MODE; then
            echo "Image successfully downloaded: $IMAGE_PATH"
        fi
        
        # Save information to text file
        {
            echo "Title: $IMAGE_TITLE"
            echo "Copyright: $IMAGE_COPYRIGHT"
            echo "Copyright Link: $IMAGE_COPYRIGHT_LINK"
            echo "URL: $IMAGE_URL"
            echo "Original Filename: $ORIGINAL_FILENAME"
            echo "Start Date: $IMAGE_START_DATE"
            echo "Full Start Date: $IMAGE_FULLSTART_DATE"
            echo "End Date: $IMAGE_ENDDATE"
            echo "Headline: $IMAGE_HEADLINE"
            echo "WP: $IMAGE_WP"
            echo "Quiz: $IMAGE_QUIZ"
            echo "Download Date: $(date +"%d-%m-%Y")"
            if [ "$LOCALE_AUTO" = "true" ]; then
                echo "Locale: $actual_locale (auto-detected)"
            else
                echo "Locale: $actual_locale"
            fi
        } > "$INFO_PATH"
        
        if ! $QUIET_MODE && ! $SILENT_MODE; then
            echo "Information saved to: $INFO_PATH"
        fi
        
        # If second path is specified, copy the image and create a simple info file there
        if [ -n "$SECOND_PATH" ]; then
            # Use the file extension already extracted earlier
            # Define the second path filenames with correct extension
            WALL_IMAGE_PATH="$SECOND_PATH/bing_wallpaper.${FILE_EXTENSION}"
            WALL_TITLE_PATH="$SECOND_PATH/bing_title.txt"
            WALL_COPYRIGHT_PATH="$SECOND_PATH/bing_copyright.txt"
            
            # Copy the image to the second path
            cp "$IMAGE_PATH" "$WALL_IMAGE_PATH"
            
            # Clean the title for Italian locale (remove ? character issues)
            CLEAN_TITLE="$IMAGE_TITLE"
            if [[ "$actual_locale" == it-* ]]; then
                # Remove single ? or replace double ?? with single ?
                CLEAN_TITLE=$(echo "$IMAGE_TITLE" | sed 's/??/?/g; s/?//g')
            fi
            
            # Clean the copyright (remove text in parentheses at the end)
            CLEAN_COPYRIGHT="$IMAGE_COPYRIGHT"
            # Remove everything from the last opening parenthesis to the end, including the space before it
            CLEAN_COPYRIGHT=$(echo "$IMAGE_COPYRIGHT" | sed 's/ (.*$//')
            
            # Save title to separate file
            echo "$CLEAN_TITLE" > "$WALL_TITLE_PATH"
            
            # Save copyright to separate file
            echo "$CLEAN_COPYRIGHT" > "$WALL_COPYRIGHT_PATH"
            
            if ! $QUIET_MODE && ! $SILENT_MODE; then
                echo "Wallpaper copied to: $WALL_IMAGE_PATH"
                echo "Wallpaper title saved to: $WALL_TITLE_PATH"
                echo "Wallpaper copyright saved to: $WALL_COPYRIGHT_PATH"
            fi
        fi
        
        return 0
    else
        if ! $SILENT_MODE; then
            echo "Error downloading image."
        fi
        return 1
    fi
}

# Main function to handle script execution
main() {
    # If command-line options were provided or in silent mode, just download the image and exit
    if [ "$#" -gt 0 ] || ! [ -t 0 ] || $SILENT_MODE; then
        download_image
        exit 0
    fi
    
    # Otherwise show interactive menu
    while true; do
        echo
        echo "===== Another Bing Image Of The Day ====="
        echo "1. Download today's image"
        echo "2. Change locale"
        echo "3. Configuration"
        echo "4. Exit"
        read -p "Select an option: " option
        
        case $option in
            1) 
                download_image 
                ;;
            2) 
                change_locale 
                ;;
            3)
                echo "Configuration options:"
                echo "1) Set output directory"
                echo "2) Set wallpaper directory"
                echo "3) Back to main menu"
                read -p "Enter option: " config_option
                
                case $config_option in
                    1)
                        read -p "Enter output directory path: " new_output_dir
                        if [ -d "$new_output_dir" ] || mkdir -p "$new_output_dir" 2>/dev/null; then
                            WALLPAPERS_DIR="$new_output_dir"
                            OUTPUT_DIR="$new_output_dir"
                            # Update config file
                            sed -i "s|^OUTPUT_DIR=.*|OUTPUT_DIR=$new_output_dir|" "$CONFIG_FILE"
                            if ! grep -q "^OUTPUT_DIR=" "$CONFIG_FILE"; then
                                echo "OUTPUT_DIR=$new_output_dir" >> "$CONFIG_FILE"
                            fi
                            echo "Output directory updated."
                        else
                            echo "Could not create or access directory. Using default."
                        fi
                        ;;
                    2)
                        read -p "Enter wallpaper directory path: " new_wall_dir
                        if [ -d "$new_wall_dir" ] || mkdir -p "$new_wall_dir" 2>/dev/null; then
                            SECOND_PATH="$new_wall_dir"
                            WALLPAPER_DIR="$new_wall_dir"
                            # Update config file
                            sed -i "s|^WALLPAPER_DIR=.*|WALLPAPER_DIR=$new_wall_dir|" "$CONFIG_FILE"
                            if ! grep -q "^WALLPAPER_DIR=" "$CONFIG_FILE"; then
                                echo "WALLPAPER_DIR=$new_wall_dir" >> "$CONFIG_FILE"
                            fi
                            echo "Wallpaper directory updated."
                        else
                            echo "Could not create or access directory. Using default."
                        fi
                        ;;
                    3) ;;
                    *) echo "Invalid option." ;;
                esac
                ;;
            4) echo "Exiting program."; exit 0 ;;
            *) echo "Invalid option. Try again." ;;
        esac
    done
}

# Run the main function with command line arguments
main "$@"
