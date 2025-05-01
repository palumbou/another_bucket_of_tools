# Another Bing Image Of The Day

> **Available languages**: [English (current)](README.md) | [Italiano](README.it.md)

A bash script that downloads the daily Bing wallpaper image and its associated metadata based on your selected locale.

## Features

This script offers the following capabilities:

1. **Download Bing Image of the Day**
   - Downloads the current Bing Image of the Day for your selected locale.
   - Saves the image with a date-based filename prefix in the specified output directory.
   - Improved error handling for more reliable downloads.

2. **Save Image Metadata**
   - Creates a metadata text file alongside each image, containing:
     - Image title
     - Copyright information
     - Image description
     - Start and end dates
     - And other metadata from Bing
   - Supports JSON parsing with jq (if installed) for more reliable metadata extraction.

3. **Locale Selection**
   - Choose from a comprehensive list of locale options (57+ different locales).
   - Automatic locale detection based on IP address using multiple fallback services.
   - The system remembers your locale preference between runs.

4. **Configurable Output Directories**
   - Specify a primary output directory for images and metadata.
   - Optionally specify a secondary "wallpaper" directory for desktop backgrounds.
   - Configuration menu for easily setting directories.

5. **Command-line Support**
   - Run interactively with an enhanced menu interface.
   - Use command-line parameters for automation and scripting.
   - Silent mode option for completely quiet operation in scripts.

6. **Persistent Configuration**
   - Save preferences in the `env.conf` configuration file.
   - Override saved settings via command-line parameters when needed.

## Installation

1. Download the script:
   ```bash
   git clone https://github.com/palumbou/another_bucket_of_tools.git
   cd another_bucket_of_tools/another_bing_image_of_the_day_downloader
   ```

2. Make the script executable:
   ```bash
   chmod u+x another_bing_image_of_the_day_downloader.sh
   ```

3. Run the script:
   ```bash
   ./another_bing_image_of_the_day_downloader.sh
   ```

## Usage

### Interactive Mode

Simply run the script without parameters:

```bash
./another_bing_image_of_the_day_downloader.sh
```

This will display the main menu with options to:
1. Download today's image
2. Change locale
3. Configuration (set output directories)
4. Exit

### Command-Line Options

The script supports the following command-line options:

```
Usage: ./another_bing_image_of_the_day_downloader.sh [options]

Options:
  -o, --output PATH       Specify the output directory for images and info files
  -w, --wallpaper PATH    Specify a second directory to save image as wallpaper
  -l, --locale LOCALE     Specify the locale to use (e.g., en-US, it-IT, etc.)
  -q, --quiet             Quiet mode, minimal output
  -s, --silent            Silent mode, no output at all (implies --quiet)
  -h, --help              Display this help message and exit

Examples:
  ./another_bing_image_of_the_day_downloader.sh --output ~/Pictures/BingImages
  ./another_bing_image_of_the_day_downloader.sh --wallpaper ~/Pictures/Wallpapers
  ./another_bing_image_of_the_day_downloader.sh --locale it-IT
  ./another_bing_image_of_the_day_downloader.sh --silent
  ./another_bing_image_of_the_day_downloader.sh -o ~/Pictures/BingImages -w ~/Pictures/Wallpapers -l en-GB
```

### Configuration File

The script uses an `env.conf` file to store persistent configuration:

```bash
LOCALE=en-US
LOCALE_AUTO=false  # Set to true if using auto-detected locale
# Uncomment and set these values to specify default directories
# OUTPUT_DIR=/path/to/your/images
# WALLPAPER_DIR=/path/to/your/wallpaper
```

You can edit this file manually or let the script update it when you change settings through the interactive menu.

## Wallpaper Integration

When using the wallpaper directory option (-w or WALLPAPER_DIR in env.conf), the script:

1. Copies the downloaded image to the specified directory as `bing_wallpaper.jpg`
2. Creates a `bing_wallpaper.txt` file containing just the image title

This makes it easy to integrate with desktop environments or scripts that set the daily wallpaper.

## Example Use Cases

### Using with Hyprland

You can easily set up Hyprland to download and use the Bing image of the day as your wallpaper by adding to your `hyprland.conf`:

```
# Download Bing image of the day as wallpaper at startup
exec-once = /path/to/another_bing_image_of_the_day_downloader.sh -q -w ~/.config/hypr/wallpapers
```

Then in your `hyprpaper.conf`, simply add:

```
preload = ~/.config/hypr/wallpapers/bing_wallpaper.jpg
wallpaper = eDP-1,~/.config/hypr/wallpapers/bing_wallpaper.jpg
```

### Using with Hyprlock

For Hyprlock, you can simply reference the same image file directly in your `hyprlock.conf`:

```
background {
    # ...other configurations...
    path = ~/.config/hypr/wallpapers/bing_wallpaper.jpg
}
```

This way, both Hyprland and Hyprlock will use the same image file that gets updated every time you start your Hyprland session.

## Locale Support

The script supports 57+ different locales including:

- English (various regions)
- European languages (German, French, Spanish, Italian, etc.)
- Asian languages (Japanese, Chinese, Korean, etc.)
- And many more

Use the "auto" option to automatically detect your locale based on your IP address.

## Requirements

- Bash shell
- curl
- Internet connection
- Basic Unix utilities (grep, sed, etc.)
- Optional: jq for enhanced metadata parsing

## License

This project is licensed under Creative Commons Attribution-NonCommercial 4.0 International License - see the [LICENSE](../LICENSE) file in the parent directory for details.

---

This script is part of the [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools) collection.