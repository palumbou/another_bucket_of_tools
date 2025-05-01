# Another Bucket of Tools

> **Available languages**: [English (current)](README.md) | [Italiano](README.it.md)

A collection of shell scripts developed with the assistance of AI to recreate commonly available utilities with custom enhancements tailored to my specific needs.

## Introduction

The internet is filled with various utility scripts for different purposes, but I often found myself wanting specific features or modifications that weren't available in existing solutions. Rather than settling for what was available, I decided to create my own versions of these tools.

**Another Bucket of Tools** was born from my desire to:
1. Learn how to effectively write and refine prompts for LLM AI models
2. Create customized versions of common utilities that better fit my workflow
3. Improve my understanding of shell scripting and Linux systems

Each script in this repository is the result of carefully crafted queries to AI language models, designed to help me learn how to formulate the most effective prompts possible when interacting with LLM-based AI systems. These experiments in prompt engineering have produced practical, efficient tools while helping me understand how to better communicate with AI assistants.

## Available Tools

Currently, this repository contains the following tools:

### 1. Another Bing Image of the Day Downloader

A script that downloads the daily Bing wallpaper image with the following features:
- Automatic locale detection based on IP address
- Multiple output directory support (one for archive, one for active wallpaper)
- Support for 57 different locales
- Saves metadata information along with the image
- Interactive and command-line modes
- Configuration via config file or command-line arguments

**Location**: [/another_bing_image_of_the_day_downloader](./another_bing_image_of_the_day_downloader)

### 2. Another One Bites the Dust

A comprehensive system cleaning utility that:
- Cleans cache files from browsers and system directories
- Removes old log files
- Deletes temporary files based on age
- Empties trash directories
- Cleans package manager caches (apt, dnf, pacman, nix)
- Removes backup files
- Cleans Docker resources
- Features dry-run mode to preview changes
- Shows space recovered after cleaning
- Supports interactive and non-interactive modes

**Location**: [/another_one_bites_the_dust](./another_one_bites_the_dust)

## Usage

Each tool includes its own README with detailed usage instructions, and the scripts themselves contain help information accessible via the `--help` flag.

## Contributing

Feel free to fork this repository and adapt these tools to your own needs. If you have improvements that might be beneficial to others, pull requests are welcome.

## Disclaimer

These scripts are provided as-is, without any warranty. Always read the script documentation and understand what a script does before running it on your system. Some scripts (especially the cleaner utility) can permanently delete files from your system.