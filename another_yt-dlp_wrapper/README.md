# Another yt-dlp wrapper

> **Available languages**: [English (current)](README.md) | [Italiano](README.it.md)

A bash script that wraps around yt-dlp to manage media streams from various sites, organizing content efficiently.

> **Note**: This is simply a wrapper script that executes commands from the [yt-dlp](https://github.com/yt-dlp/yt-dlp) program. This script does not add any download functionality beyond what yt-dlp already provides, but focuses on organization and automation.

## Features

This script offers the following capabilities:

1. **Download Media Content**
   - Download single videos, entire channels, or playlists
   - Automatically downloads at the highest available quality
   - Preserves original video titles as filenames
   - Organizes content by type in separate folders (videos, shorts, live streams)
   - Supports downloading both manual and auto-generated subtitles in multiple languages
   - Automatically downloads thumbnails for all videos
   - Automatically creates description files with video URLs and full descriptions
   - Saves complete metadata in JSON format for each video

2. **Multiple Operation Modes**
   - Interactive mode with guided prompts and configuration preview
   - Command-line mode for scripting and automation
   - Smart URL detection for videos, channels, and playlists
   - Shows equivalent command line for easy automation setup

3. **Efficient Management**
   - Skips existing videos to avoid duplicates (never overwrites already downloaded videos)
   - Creates organized directory structure automatically
   - Resumes interrupted downloads
   - Batch processing with input file support
   - Comprehensive logging system for debugging and tracking operations

4. **Channel Information Files**
   - Automatically creates `channel_info.txt` files in each channel directory
   - Records channel metadata (name, ID, description, follower count)
   - Logs download configuration and history with timestamps
   - Tracks all download sessions for audit and reference purposes

5. **Authentication Support**
   - Extract cookies automatically from your browser (Chrome, Firefox, Edge, Safari, etc.)
   - Use custom cookie files for authentication
   - Access private videos, members-only content, and age-restricted videos
   - Built-in guide for cookie setup and usage

## Requirements

### Required Dependencies

- `bash` - The shell environment for running the script
- `yt-dlp` - The core video downloading utility
- `date` - For timestamp generation
- `echo` - For output display  
- `head` - For limiting output lines
- `sed` - For URL and text processing
- `tr` - For character transformation
- `cut` - For string manipulation
- `mkdir` - For directory creation
- `grep` - For pattern searching in files
- `tail` - For extracting last lines from files
- `xargs` - For trimming whitespace
- `dirname` - For extracting directory paths
- `find` - For locating files in directory trees

All of these utilities are typically pre-installed on most Linux distributions. The only external dependency you may need to install manually is `yt-dlp`.

### Optional Dependencies

- `jq` - JSON processor for better parsing of video metadata (highly recommended)
  - If not installed, the script will use basic `grep` and `sed` for JSON parsing

## Installation

1. Clone this repository or download the script:
   ```bash
   git clone https://github.com/palumbou/another_bucket_of_tools.git
   cd another_bucket_of_tools/another_yt-dlp_wrapper
   ```

2. Make the script executable:
   ```bash
   chmod +x another_yt-dlp_wrapper.sh
   ```

3. Install dependencies if not already present:
   ```bash
   # For yt-dlp (recommended method)
   pip install -U yt-dlp
   
   # Alternative methods for yt-dlp:
   # On Debian/Ubuntu
   sudo apt install yt-dlp
   
   # On Fedora
   sudo dnf install yt-dlp
   
   # On Arch Linux
   sudo pacman -Syu yt-dlp
   
   # On Nix/NixOS
   nix-env -iA nixpkgs.yt-dlp
   
   # On macOS with brew
   brew install yt-dlp
   ```

## Usage

### Interactive Mode

Simply run the script without arguments to use interactive mode:

```bash
./another_yt-dlp_wrapper.sh
```

You'll be prompted to:
1. Choose input type (single URL or text file with multiple URLs)
2. Enter a media URL or path to a text file with URLs (one per line)
3. Specify an output directory (or use the current directory)
4. Choose subtitle preferences (manual and/or auto-generated)
5. Select which content types to download (videos, shorts, live streams)
6. Choose download speed mode (normal, slow, or fast) for rate limiting
7. Review the configuration summary with equivalent command line before downloading begins

The interactive mode provides guided assistance and shows you the equivalent non-interactive command that you could use for automation or future reference.

#### Download Speed Options

The script offers three download speed modes to balance performance with service rate limits:

- **Normal mode** (default): Balanced speed with 1-3 second delays between requests
- **Slow mode**: More conservative with 5-10 second delays to avoid rate limits (recommended for large downloads)
- **Fast mode**: No delays between requests (use with caution, may trigger service limits)

#### Configuration Summary

Before starting the download, the interactive mode displays:
- All your selected options
- The types of content that will be downloaded
- The chosen download speed mode
- **The equivalent command line** that you could use to repeat this operation non-interactively

### Command-Line Mode

For automated usage or scripting:

```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" -o ~/Videos
```

### Available Options

```
Options:
  -h, --help                Show this help message and exit
  -o, --output-dir DIR      Set output directory (default: current directory)
  -u, --url URL             Media URL (video, channel, or playlist)
  -f, --file FILE           Input file with URLs (one per line)
  -q, --quiet               Show less output
  -s, --silent              Show no output except errors
  -v, --verbose             Show more detailed output
  -n, --non-interactive     Run in non-interactive mode (requires --url or --file)
  --subs                    Download manually created subtitles
  --auto-subs               Download auto-generated subtitles
  --sub-langs LANGS         Subtitle languages to download (comma-separated, e.g., 'en,it')
                            Use 'all' for all available languages (default)
  --log FILE                Save all output to a log file
  --no-videos               Skip regular videos
  --no-shorts               Skip shorts
  --no-live                 Skip live streams/recordings
  --only-videos             Download only regular videos
  --only-shorts             Download only shorts
  --only-live               Download only live streams/recordings
  --slow                    Enable slower download mode (5-10 sec delay) to avoid rate limits
  --fast                    Disable rate limiting delays (may trigger service limits)

Authentication options:
  --cookies-from-browser BROWSER
                            Extract cookies from browser (chrome, firefox, edge, safari, etc.)
  --cookies-file FILE       Use cookies from a Netscape format cookie file
  --cookie-guide            Show detailed guide for cookie authentication

Note: Thumbnails and descriptions (with URLs) are automatically downloaded for all videos.
```

### Downloaded Files Structure

For each video downloaded, the script creates the following files:
- `video_title.mp4` - The video file in MP4 format
- `video_title.jpg` (or `.webp`) - The video thumbnail image
- `video_title.description.txt` - A text file containing the video URL and full description
- `video_title.info.json` - Complete metadata in JSON format (channel, uploader, duration, views, etc.)
- `video_title.srt` - Subtitle files (if `--subs` or `--auto-subs` is enabled)

Example of `video_title.description.txt` content:
```
Video URL: https://www.youtube.com/watch?v=XXXXX

Description:
----------------------------------------
This is the full video description as it appears on YouTube.
It can contain multiple lines, links, timestamps, and other information.
```

### Authentication

The script supports authentication through cookies, which allows you to:
- Download private or unlisted videos
- Access members-only content
- Bypass age restrictions
- Download videos from channels you're subscribed to

#### Method 1: Extract Cookies from Browser (Recommended)

The easiest method is to automatically extract cookies from your browser:

```bash
# Extract cookies from Chrome
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXXX" --cookies-from-browser chrome

# Extract cookies from Firefox
./another_yt-dlp_wrapper.sh -n -u "https://youtube.com/watch?v=XXXXX" --cookies-from-browser firefox
```

Supported browsers: `chrome`, `chromium`, `firefox`, `edge`, `safari`, `opera`, `brave`, `vivaldi`

**Requirements**: You must be logged into YouTube in the specified browser.

#### Method 2: Use a Cookie File

Alternatively, you can export cookies to a file and use them:

1. Install a browser extension to export cookies:
   - **Chrome/Edge**: "Get cookies.txt LOCALLY" or "cookies.txt"
   - **Firefox**: "cookies.txt"

2. Log into YouTube in your browser

3. Navigate to youtube.com and export cookies using the extension

4. Save the file (e.g., `youtube_cookies.txt`)

5. Use the cookies file:
   ```bash
   ./another_yt-dlp_wrapper.sh -n -u "URL" --cookies-file ~/youtube_cookies.txt
   ```

**Security Note**: Keep your cookies file secure as it contains authentication data!

#### Getting Help

For a complete step-by-step guide on cookie authentication, run:
```bash
./another_yt-dlp_wrapper.sh --cookie-guide
```

### Scheduling with Cron

For automated downloads on a schedule using cron, combine the `-n`, `-s`, and `-o` options:

```bash
# Example cron entry to download a channel daily at 3 AM
0 3 * * * /path/to/another_yt-dlp_wrapper.sh -n -s -u "https://example.com/@ChannelName" -o /path/to/videos/
```

The flags used for cron jobs:
- `-n` (non-interactive): required to run without user input
- `-s` (silent): suppresses all output except errors, ideal for cron
- `-o` (output directory): specifies where to save downloaded videos

## Examples

Download a single video:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX"
```

Download all videos from a channel:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/ChannelName" -o ~/Videos
```

Download a playlist:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/playlist?list=XXXX"
```

## Use Case: Local Media Archive with Automatic Updates

You can create a local archive of your favorite channels that stays automatically up-to-date:

1. First, create an initial download of all your favorite channels/playlists:
   ```bash
   ./another_yt-dlp_wrapper.sh -n -f my_favorite_channels.txt -o ~/MediaArchive --subs --log ~/logs/media_initial.log
   ```

2. Set up a cron job to periodically check for and download new videos (this example runs daily at 2 AM):
   ```bash
   # Add this to your crontab (run 'crontab -e' to edit)
   0 2 * * * /path/to/another_yt-dlp_wrapper.sh -n -s -f /path/to/my_favorite_channels.txt -o /path/to/MediaArchive --log /path/to/logs/media_update_$(date +\%Y\%m\%d).log
   ```

This setup will:
- Download the complete history of your favorite channels initially
- Check daily for new videos and add only those to your collection
- Organize everything by content type (videos, shorts, and live streams in separate folders)
- Maintain logs of each update process
- Since yt-dlp skips already downloaded videos, only new content will be added

### Content Organization

The script organizes all downloaded content by type:
- Regular videos go into `/channel_name/videos/`
- Shorts go into `/channel_name/shorts/`
- Live streams and recordings go into `/channel_name/lives/`
- Channel information is stored in `/channel_name/channel_info.txt`

Each video is accompanied by:
- Its thumbnail image (`.jpg` or `.webp`)
- A description file (`.description.txt`) containing the video URL and full description
- A metadata file (`.info.json`) with complete video information

You can customize which content types to download with the following options:
```bash
# Download only regular videos
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/ChannelName" --only-videos

# Download everything except shorts
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/ChannelName" --no-shorts
```

### Channel Information Files

The script automatically creates a `channel_info.txt` file in each channel directory containing:

- **Channel Metadata**: Name, ID, URL, description, and follower count
- **Download Configuration**: Which content types were downloaded, subtitle settings, rate limiting mode, and the exact command used
- **Download History**: Timestamps of all download sessions (format: YYYY-MM-DD HH:MM:SS)

Example `channel_info.txt` content:
```
=== CHANNEL INFORMATION ===
Download Date: 2024-01-15 14:30:22
Original URL: https://example.com/@ChannelName

Channel Name: Example Channel
Channel ID: UC1234567890abcdef
Channel URL: https://example.com/@ChannelName
Description: This is an example channel description...

=== DOWNLOAD CONFIGURATION ===
Output Directory: /home/user/videos/Example_Channel
Download Videos: true
Download Shorts: true
Download Live: true
Download Subtitles: Yes
Subtitle Languages: all
Rate Limiting Mode: normal
Command Used: ./another_yt-dlp_wrapper.sh -n -u "https://example.com/@ChannelName" -o ~/Videos --subs

=== DOWNLOAD HISTORY ===
Previous Downloads:
Last Download: 2024-01-15 14:30:22
Last Download: 2024-01-16 09:15:33
```

This information is invaluable for:
- **Audit Trail**: Track when downloads occurred and what was configured
- **Troubleshooting**: Debug issues with specific download configurations
- **Archive Management**: Understand the scope and history of your media collection
- **Automation**: Reference exact settings used for successful downloads

### Rate Limiting Protection

The script includes comprehensive rate limiting protection to avoid potential service limits and ensure stable downloads. Three modes are available:

- **Normal mode** (default): balanced protection with 1-3 second delays between requests
  - `--sleep-interval 1` (1 second delay between requests)
  - `--max-sleep-interval 3` (maximum 3 seconds if yt-dlp increases delays)
  - `--retry-sleep 5` (5 seconds between retry attempts)
  - `--retries 3` and `--fragment-retries 3`

- **Slow mode** (`--slow`): conservative approach with 5-10 second delays, ideal for large batch downloads
  - `--sleep-interval 5` (5 seconds delay between requests)
  - `--max-sleep-interval 10` (maximum 10 seconds)
  - `--retry-sleep 10` (10 seconds between retry attempts)
  - `--retries 5` and `--fragment-retries 5`

- **Fast mode** (`--fast`): minimal delays for faster downloads, use with caution for large operations
  - `--sleep-interval 0` (no delays between requests)
  - No retry delays (may trigger service rate limits)

Examples:
```bash
# Use slow mode for large channel downloads to be more respectful to the service
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/LargeChannel" --slow

# Use fast mode for single videos when you need speed
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --fast
```

**Recommendation**: use the default normal mode for most operations, switch to `--slow` for large batch downloads or if you encounter any service limitations.

## Additional Examples

This section provides comprehensive examples covering various use cases, from basic downloads to advanced scenarios like complete channel archiving and synchronization.

### Complete Channel Download

Download an entire channel with all content types and subtitles:
```bash
# Complete channel download with subtitles and logging
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/ChannelName" \
  -o ~/MediaArchive \
  --subs --auto-subs \
  --sub-langs en,it \
  --slow \
  --log ~/logs/channel_download.log
```

### Channel Synchronization

Synchronize an existing channel directory (download only new content):
```bash
# Daily sync - only downloads new videos since last run
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/ChannelName" \
  -o ~/MediaArchive \
  --subs \
  --slow \
  --silent \
  --log ~/logs/sync_$(date +%Y%m%d).log
```

### Basic Usage Examples

Download videos with manually created subtitles:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --subs
```

Download videos with auto-generated subtitles:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --auto-subs
```

Download videos with both types of subtitles:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --subs --auto-subs
```

Download videos with specific subtitle languages:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --subs --sub-langs en,it
```

Download only regular videos (no shorts or live streams):
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/ChannelName" --only-videos
```

Download only shorts:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/ChannelName" --only-shorts
```

Download videos and live streams, but skip shorts:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/c/ChannelName" --no-shorts
```

Download videos from a list of URLs in a file:
```bash
./another_yt-dlp_wrapper.sh -n -f channels.txt
```

Enable comprehensive logging to a file:
```bash
./another_yt-dlp_wrapper.sh -n -u "https://example.com/watch?v=XXXX" --log download-logs.txt
```

### Using an Input File

You can create a text file with media URLs (one per line) to download multiple videos, channels, or playlists in a single operation. For example:

```
# My favorite channels (lines starting with # are ignored)
https://example.com/c/Channel1
https://example.com/c/Channel2

# Playlist
https://example.com/playlist?list=XXXX
https://example.com/playlist?list=YYYY

# Individual videos
https://example.com/watch?v=VIDEO1
https://example.com/watch?v=VIDEO2
```

Then download all of them with:
```bash
./another_yt-dlp_wrapper.sh -n -f my_channels.txt -o ~/Videos --subs
```

## License

This project is licensed under Creative Commons Attribution-NonCommercial 4.0 International License - see the [LICENSE](../LICENSE) file in the parent directory for details.

## Acknowledgments

- This script uses [yt-dlp](https://github.com/yt-dlp/yt-dlp), an excellent media downloading utility.

---

This script is part of the [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools) collection.
