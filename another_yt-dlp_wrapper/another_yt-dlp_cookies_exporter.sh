#!/usr/bin/env bash
set -euo pipefail

# Another yt-dlp Cookies Exporter
# Exports cookies from Chrome/Chromium or Firefox to Netscape format for use with yt-dlp
# Supports: NixOS, Debian-based, Fedora-based, and Arch Linux

# Usage:
#   ./another_yt-dlp_cookies_exporter.sh [output_file]
#   CHROME_PROFILE="Profile 1" ./another_yt-dlp_cookies_exporter.sh cookies.txt
#   BROWSER="firefox" ./another_yt-dlp_cookies_exporter.sh cookies.txt
#
# Environment variables:
#   BROWSER         - Browser to export from: chrome, chromium, firefox (default: chrome)
#   CHROME_PROFILE  - Chrome profile name (default: Default)
#   FIREFOX_PROFILE - Firefox profile name or pattern (default: auto-detect)

# OUT can be passed as environment variable or first argument
# Priority: environment variable > argument > default
if [ -z "${OUT:-}" ]; then
    OUT="${1:-cookies.txt}"
fi

BROWSER="${BROWSER:-chrome}"
CHROME_PROFILE="${CHROME_PROFILE:-Default}"
FIREFOX_PROFILE="${FIREFOX_PROFILE:-}"

# Normalize browser name (handle variants like google-chrome-stable, google-chrome, chrome)
case "${BROWSER,,}" in
    google-chrome*|chrome)
        BROWSER="chrome"
        ;;
    chromium)
        BROWSER="chromium"
        ;;
    firefox*)
        BROWSER="firefox"
        ;;
esac

echo "==============================================="
echo "  Another yt-dlp Cookies Exporter"
echo "==============================================="
echo ""
echo "Browser: ${BROWSER}"
echo "Output file: ${OUT}"
echo ""
echo "IMPORTANT: Close your browser before running!"
echo ""

# Determine if we're on NixOS
if [ -f /etc/NIXOS ]; then
    IS_NIXOS=true
else
    IS_NIXOS=false
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to find Chrome/Chromium cookie database
find_chrome_cookies() {
    local profile="$1"
    local candidates=(
        "$HOME/.config/google-chrome/$profile/Cookies"
        "$HOME/.config/chromium/$profile/Cookies"
        "$HOME/.var/app/com.google.Chrome/config/google-chrome/$profile/Cookies"
        "$HOME/.var/app/org.chromium.Chromium/config/chromium/$profile/Cookies"
    )
    
    for path in "${candidates[@]}"; do
        if [ -f "$path" ]; then
            echo "$path"
            return 0
        fi
    done
    
    return 1
}

# Function to find Firefox cookie database
find_firefox_cookies() {
    local pattern="${1:-default}"
    local firefox_dir="$HOME/.mozilla/firefox"
    local flatpak_dir="$HOME/.var/app/org.mozilla.firefox/.mozilla/firefox"
    
    # Try standard location first
    if [ -d "$firefox_dir" ]; then
        local profile_dir=$(ls -1 "$firefox_dir" | grep "$pattern" | head -n1)
        if [ -n "$profile_dir" ] && [ -f "$firefox_dir/$profile_dir/cookies.sqlite" ]; then
            echo "$firefox_dir/$profile_dir/cookies.sqlite"
            return 0
        fi
    fi
    
    # Try flatpak location
    if [ -d "$flatpak_dir" ]; then
        local profile_dir=$(ls -1 "$flatpak_dir" | grep "$pattern" | head -n1)
        if [ -n "$profile_dir" ] && [ -f "$flatpak_dir/$profile_dir/cookies.sqlite" ]; then
            echo "$flatpak_dir/$profile_dir/cookies.sqlite"
            return 0
        fi
    fi
    
    return 1
}

# Detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    else
        echo "unknown"
    fi
}

# Check for Python and sqlite3
check_dependencies() {
    local missing=()
    
    if ! command_exists python3 && ! command_exists python; then
        missing+=("python3")
    fi
    
    if ! command_exists sqlite3; then
        missing+=("sqlite3")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        local distro=$(detect_distro)
        
        # On NixOS, automatically use nix-shell with required dependencies
        if [ "$distro" = "nixos" ] && command_exists nix-shell; then
            echo "INFO: Missing dependencies on NixOS: ${missing[*]}"
            echo "INFO: Starting temporary shell with required packages..."
            echo ""
            
            # Preserve environment variables and re-execute this script in a nix-shell
            # with the required dependencies
            export OUT BROWSER CHROME_PROFILE FIREFOX_PROFILE
            exec nix-shell -p python3 sqlite --run "$0"
        fi
        
        # On other distributions, show installation instructions
        echo "ERROR: Missing required dependencies: ${missing[*]}"
        echo ""
        echo "Please install them first:"
        
        case "$distro" in
            debian|ubuntu|linuxmint)
                echo "  sudo apt install python3 sqlite3"
                ;;
            fedora|rhel|centos)
                echo "  sudo dnf install python3 sqlite"
                ;;
            arch|manjaro)
                echo "  sudo pacman -S python sqlite"
                ;;
            nixos)
                echo "  # Automatic nix-shell failed. You can:"
                echo "  # 1) Run: nix-shell -p python3 sqlite --run './another_yt-dlp_cookies_exporter.sh $OUT'"
                echo "  # 2) Or add to configuration.nix:"
                echo "  environment.systemPackages = [ pkgs.python3 pkgs.sqlite ];"
                ;;
            *)
                echo "  Install python3 and sqlite3 using your distribution's package manager"
                ;;
        esac
        exit 1
    fi
}

# Find the cookie database based on browser
find_cookie_db() {
    local cookie_db=""
    
    case "$BROWSER" in
        chrome|chromium)
            echo "Looking for Chrome/Chromium cookies (profile: $CHROME_PROFILE)..." >&2
            cookie_db=$(find_chrome_cookies "$CHROME_PROFILE")
            if [ -z "$cookie_db" ]; then
                echo "ERROR: Could not find Chrome/Chromium cookie database for profile '$CHROME_PROFILE'" >&2
                echo "" >&2
                echo "Searched in:" >&2
                echo "  - $HOME/.config/google-chrome/$CHROME_PROFILE/Cookies" >&2
                echo "  - $HOME/.config/chromium/$CHROME_PROFILE/Cookies" >&2
                echo "  - $HOME/.var/app/com.google.Chrome/config/google-chrome/$CHROME_PROFILE/Cookies" >&2
                echo "  - $HOME/.var/app/org.chromium.Chromium/config/chromium/$CHROME_PROFILE/Cookies" >&2
                echo "" >&2
                echo "Available Chrome profiles:" >&2
                ls -1 "$HOME/.config/google-chrome" 2>/dev/null >&2 || echo "  (google-chrome not found)" >&2
                ls -1 "$HOME/.config/chromium" 2>/dev/null >&2 || echo "  (chromium not found)" >&2
                exit 1
            fi
            ;;
        firefox)
            local pattern="${FIREFOX_PROFILE:-default}"
            echo "Looking for Firefox cookies (profile pattern: $pattern)..." >&2
            cookie_db=$(find_firefox_cookies "$pattern")
            if [ -z "$cookie_db" ]; then
                echo "ERROR: Could not find Firefox cookie database matching '$pattern'" >&2
                echo "" >&2
                echo "Available profiles:" >&2
                ls -1 "$HOME/.mozilla/firefox" 2>/dev/null >&2 || echo "  (firefox not found)" >&2
                exit 1
            fi
            ;;
        *)
            echo "ERROR: Unknown browser '$BROWSER'. Supported browsers: chrome, chromium, firefox" >&2
            echo "Note: google-chrome-stable is automatically normalized to chrome" >&2
            exit 1
            ;;
    esac
    
    echo "Found cookie database: $cookie_db" >&2
    echo "$cookie_db"
}

# Export cookies using Python and sqlite3
export_cookies() {
    local cookie_db="$1"
    local output="$2"
    
    # Create a temporary copy of the database to avoid locking issues
    local temp_db=$(mktemp)
    cp "$cookie_db" "$temp_db"
    
    # Use Python to read and export cookies
    if $IS_NIXOS; then
        # On NixOS, use nix-shell to ensure Python is available
        nix-shell -p python3 --run "python3 - '$temp_db' '$output'" <<'PYTHON'
import sys
import sqlite3
import time

cookie_db = sys.argv[1]
output_file = sys.argv[2]

# Domains to export (only YouTube/Google)
allowed_domains = ('youtube.com', 'google.com', 'accounts.google.com')

def is_allowed_domain(domain):
    domain = (domain or '').lstrip('.').lower()
    return any(domain == d or domain.endswith('.' + d) for d in allowed_domains)

# Connect to cookie database
conn = sqlite3.connect(cookie_db)
cursor = conn.cursor()

# Determine table structure (Chrome vs Firefox)
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = [row[0] for row in cursor.fetchall()]

count = 0
with open(output_file, 'w', encoding='utf-8') as f:
    f.write('# Netscape HTTP Cookie File\n')
    f.write('# Exported via another_yt-dlp_cookies_exporter\n')
    f.write(f'# Export time: {int(time.time())}\n')
    
    if 'moz_cookies' in tables:
        # Firefox format
        cursor.execute('''
            SELECT host, name, value, path, expiry, isSecure
            FROM moz_cookies
        ''')
        
        for row in cursor.fetchall():
            host, name, value, path, expiry, is_secure = row
            
            if not is_allowed_domain(host):
                continue
            
            include_subdomains = 'TRUE' if host.startswith('.') else 'FALSE'
            path = path or '/'
            secure = 'TRUE' if is_secure else 'FALSE'
            expiry = int(expiry) if expiry else 0
            
            f.write(f'{host}\t{include_subdomains}\t{path}\t{secure}\t{expiry}\t{name}\t{value}\n')
            count += 1
    
    else:
        # Chrome format
        cursor.execute('''
            SELECT host_key, name, value, path, expires_utc, is_secure
            FROM cookies
        ''')
        
        for row in cursor.fetchall():
            host, name, value, path, expires_utc, is_secure = row
            
            if not is_allowed_domain(host):
                continue
            
            include_subdomains = 'TRUE' if host.startswith('.') else 'FALSE'
            path = path or '/'
            secure = 'TRUE' if is_secure else 'FALSE'
            # Chrome stores expiry in microseconds since 1601-01-01, convert to Unix timestamp
            expiry = int(expires_utc / 1000000 - 11644473600) if expires_utc else 0
            
            f.write(f'{host}\t{include_subdomains}\t{path}\t{secure}\t{expiry}\t{name}\t{value}\n')
            count += 1

conn.close()
print(f'Exported {count} cookies to {output_file}')
PYTHON
    else
        # On other systems, use system Python
        python3 - "$temp_db" "$output" <<'PYTHON'
import sys
import sqlite3
import time

cookie_db = sys.argv[1]
output_file = sys.argv[2]

# Domains to export (only YouTube/Google)
allowed_domains = ('youtube.com', 'google.com', 'accounts.google.com')

def is_allowed_domain(domain):
    domain = (domain or '').lstrip('.').lower()
    return any(domain == d or domain.endswith('.' + d) for d in allowed_domains)

# Connect to cookie database
conn = sqlite3.connect(cookie_db)
cursor = conn.cursor()

# Determine table structure (Chrome vs Firefox)
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = [row[0] for row in cursor.fetchall()]

count = 0
with open(output_file, 'w', encoding='utf-8') as f:
    f.write('# Netscape HTTP Cookie File\n')
    f.write('# Exported via another_yt-dlp_cookies_exporter\n')
    f.write(f'# Export time: {int(time.time())}\n')
    
    if 'moz_cookies' in tables:
        # Firefox format
        cursor.execute('''
            SELECT host, name, value, path, expiry, isSecure
            FROM moz_cookies
        ''')
        
        for row in cursor.fetchall():
            host, name, value, path, expiry, is_secure = row
            
            if not is_allowed_domain(host):
                continue
            
            include_subdomains = 'TRUE' if host.startswith('.') else 'FALSE'
            path = path or '/'
            secure = 'TRUE' if is_secure else 'FALSE'
            expiry = int(expiry) if expiry else 0
            
            f.write(f'{host}\t{include_subdomains}\t{path}\t{secure}\t{expiry}\t{name}\t{value}\n')
            count += 1
    
    else:
        # Chrome format
        cursor.execute('''
            SELECT host_key, name, value, path, expires_utc, is_secure
            FROM cookies
        ''')
        
        for row in cursor.fetchall():
            host, name, value, path, expires_utc, is_secure = row
            
            if not is_allowed_domain(host):
                continue
            
            include_subdomains = 'TRUE' if host.startswith('.') else 'FALSE'
            path = path or '/'
            secure = 'TRUE' if is_secure else 'FALSE'
            # Chrome stores expiry in microseconds since 1601-01-01, convert to Unix timestamp
            expiry = int(expires_utc / 1000000 - 11644473600) if expires_utc else 0
            
            f.write(f'{host}\t{include_subdomains}\t{path}\t{secure}\t{expiry}\t{name}\t{value}\n')
            count += 1

conn.close()
print(f'Exported {count} cookies to {output_file}')
PYTHON
    fi
    
    # Clean up temporary database
    rm -f "$temp_db"
    
    # Set restrictive permissions on output file
    chmod 600 "$output"
}

# Main execution
check_dependencies
cookie_db=$(find_cookie_db)
export_cookies "$cookie_db" "$OUT"

echo ""
echo "Done! Use it with:"
echo "  yt-dlp --cookies \"$OUT\" <URL>"
echo "  ./another_yt-dlp_wrapper.sh -n -u <URL> --cookies-file \"$OUT\""
