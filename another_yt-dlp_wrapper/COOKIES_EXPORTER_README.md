# Another yt-dlp Cookies Exporter

> **Available languages**: [English (current)](COOKIES_EXPORTER_README.md) | [Italiano](COOKIES_EXPORTER_README.it.md)

This script exports cookies from Chrome/Chromium or Firefox browsers to a Netscape format file that can be used with yt-dlp.

## Features

- **Multi-browser support**: Chrome, Chromium, and Firefox
- **Multi-distribution support**: NixOS, Debian-based, Fedora-based, and Arch Linux
- **No external dependencies**: Uses only Python's built-in sqlite3 module
- **Profile support**: Export from specific browser profiles
- **Domain filtering**: Exports only cookies needed for authentication

## Requirements

### All distributions (except NixOS)
- **Python 3**: Required for cookie extraction
- **sqlite3**: Usually included with Python

Installation:
```bash
# Debian/Ubuntu/Linux Mint
sudo apt install python3

# Fedora/RHEL/CentOS
sudo dnf install python3

# Arch Linux/Manjaro
sudo pacman -S python
```

### NixOS
**Automatic dependency management**: If Python 3 or sqlite3 are missing, the script automatically starts a temporary `nix-shell` with the required packages. No permanent installation or configuration.nix changes needed!

## Usage

### Basic Usage

Export cookies from the default Chrome profile:
```bash
./another_yt-dlp_cookies_exporter.sh
```

### Specify Output File

```bash
./another_yt-dlp_cookies_exporter.sh cookies.txt
```

### Select Browser

Use Chrome (default):
```bash
BROWSER="chrome" ./another_yt-dlp_cookies_exporter.sh
```

Use Firefox:
```bash
BROWSER="firefox" ./another_yt-dlp_cookies_exporter.sh
```

### Select Browser Profile

For Chrome/Chromium:
```bash
CHROME_PROFILE="Profile 1" ./another_yt-dlp_cookies_exporter.sh cookies.txt
```

Common Chrome profiles:
- `Default` (default profile)
- `Profile 1`
- `Profile 2`

To find your Chrome profiles:
```bash
ls ~/.config/google-chrome/
# or for Chromium
ls ~/.config/chromium/
```

For Firefox:
```bash
FIREFOX_PROFILE="xxxxxxxx.default" ./another_yt-dlp_cookies_exporter.sh cookies.txt
```

To find your Firefox profile:
```bash
ls ~/.mozilla/firefox/
```

### Via Main Wrapper Script

The easiest way is to call it from the main wrapper:

```bash
# Export cookies interactively
./another_yt-dlp_wrapper.sh --export-cookies
```

Then use the exported cookies:
```bash
./another_yt-dlp_wrapper.sh -n -u <URL> --cookies-file cookies.txt
```

## Environment Variables

- `BROWSER`: Browser to export from (`chrome`, `chromium`, `firefox`) - default: `chrome`
- `CHROME_PROFILE`: Chrome profile name - default: `Default`
- `FIREFOX_PROFILE`: Firefox profile name or pattern - default: auto-detect

## How It Works

1. Locates the browser's cookie database (SQLite format)
2. Creates a temporary copy to avoid locking issues
3. Uses Python's built-in sqlite3 module to read cookies
4. Filters cookies for specific domains (e.g., youtube.com, google.com)
5. Exports in Netscape cookie format compatible with yt-dlp
6. Sets restrictive permissions (600) on the output file

## Supported Browser Locations

### Chrome/Chromium
- `~/.config/google-chrome/<profile>/Cookies`
- `~/.config/chromium/<profile>/Cookies`
- `~/.var/app/com.google.Chrome/config/google-chrome/<profile>/Cookies` (Flatpak)
- `~/.var/app/org.chromium.Chromium/config/chromium/<profile>/Cookies` (Flatpak)

### Firefox
- `~/.mozilla/firefox/<profile>/cookies.sqlite`
- `~/.var/app/org.mozilla.firefox/.mozilla/firefox/<profile>/cookies.sqlite` (Flatpak)

## Important Notes

1. **Close your browser** before running this script. An open browser locks the cookie database.

2. **Cookies contain sensitive data**. Keep the exported file secure:
   - Don't share the cookie file
   - Don't commit it to version control
   - Delete it after use
   - File permissions are automatically set to 600 (owner read/write only)

3. **Domain filtering**: The script only exports cookies for specified domains (youtube.com, google.com, accounts.google.com by default).

4. **Authentication**: Use exported cookies to access private videos, members-only content, or bypass age restrictions.

## Using Exported Cookies

### With yt-dlp directly
```bash
yt-dlp --cookies cookies.txt <URL>
```

### With the wrapper script
```bash
./another_yt-dlp_wrapper.sh -n -u <URL> --cookies-file cookies.txt
```

## Troubleshooting

### "Close your browser before running"
The cookie database is locked while the browser is open. Close all browser windows and try again.

### "Cookie database not found"
- Verify the browser profile name with the `ls` commands shown above
- Check that you've used the browser and logged into websites
- Ensure the browser has created the cookie database

### "HTTP Error 429: Too Many Requests"
This error is handled automatically in the main wrapper script with the `--extractor-args` option. The wrapper now uses alternative player clients to avoid rate limits.

### Permission errors
- Ensure you have read access to the browser's configuration directory
- Cookie files are typically readable by the user who runs the browser

## Example Workflow

1. Log into your account in your browser

2. Export cookies:
```bash
./another_yt-dlp_cookies_exporter.sh cookies.txt
```

3. Use cookies to download content:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=..." --cookies-file cookies.txt
```

4. Delete cookies file when done:
```bash
rm cookies.txt
```

## Security Note

The exported cookie file contains your authentication data. Always:
- Keep it secure and private
- Don't share it with others
- Don't commit it to version control systems
- Delete it after use
- Be aware that the file permissions are set to 600 automatically

## License

This script is part of the [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools) collection and follows the same license.
