# Another NixOS Manager

> **Available languages**: [English (current)](README.md) | [Italiano](README.it.md)

A comprehensive bash script for managing NixOS systems, handling updates, rebuilds, testing, cleaning, and major version upgrades.

## Features

- **System Updates**: update channels and rebuild in one command
- **Safe Testing**: test configurations before making them permanent
- **Version Upgrades**: safely upgrade to major NixOS releases with automatic testing
- **System Cleaning**: remove old generations and optimize the Nix store
- **Rollback Support**: easy rollback to previous generations
- **Custom Configurations**: support for custom configuration file paths
- **Interactive & Non-interactive Modes**: suitable for both manual use and automation
- **Dry Run Mode**: preview actions without executing them
- **Validation**: check configuration syntax before rebuilding

## Requirements

- **NixOS**: this script is designed specifically for NixOS
- **Root privileges**: most operations require sudo/root access
- **Standard NixOS tools**: nixos-rebuild, nix-channel, nix-collect-garbage (included in NixOS)

## Installation

1. Download the script:
   ```bash
   cd /path/to/your/scripts
   git clone https://github.com/palumbou/another_bucket_of_tools.git
   cd another_bucket_of_tools/another_nixos_manager
   ```

2. Make it executable:
   ```bash
   chmod +x another_nixos_manager.sh
   ```

3. (Optional) Create a symlink for easy access:
   ```bash
   sudo ln -s $(pwd)/another_nixos_manager.sh /usr/local/bin/nixos-manager
   ```

## Usage

### Basic Commands

```bash
# Show help and available commands
./another_nixos_manager.sh --help

# Show system information
./another_nixos_manager.sh info

# Update system (update channels + rebuild)
sudo ./another_nixos_manager.sh update

# Test configuration before applying
sudo ./another_nixos_manager.sh test

# Clean old generations (default: older than 7 days)
sudo ./another_nixos_manager.sh clean

# Clean generations older than 30 days
sudo ./another_nixos_manager.sh clean 30

# Aggressively clean all old generations
sudo ./another_nixos_manager.sh clean-all

# List all system generations
sudo ./another_nixos_manager.sh list

# Rollback to previous generation
sudo ./another_nixos_manager.sh rollback

# Validate configuration syntax
sudo ./another_nixos_manager.sh validate
```

### Using Custom Configuration

```bash
# Use a custom configuration file
sudo ./another_nixos_manager.sh -c /path/to/custom/configuration.nix update

# Test custom configuration
sudo ./another_nixos_manager.sh -c /path/to/custom/configuration.nix test
```

### Rebuild Actions

The `rebuild` command supports different actions:

```bash
# Switch: build and activate, make it default for boot
sudo ./another_nixos_manager.sh rebuild switch

# Boot: build and make default for boot, but don't activate now
sudo ./another_nixos_manager.sh rebuild boot

# Test: build and activate, but don't make it default for boot
sudo ./another_nixos_manager.sh rebuild test

# Build: just build, don't activate or change boot default
sudo ./another_nixos_manager.sh rebuild build
```

### Major Version Upgrades

Upgrade to a new major NixOS version with automatic testing:

```bash
# Upgrade from 24.05 to 24.11
sudo ./another_nixos_manager.sh upgrade 24.11

# Upgrade with custom configuration
sudo ./another_nixos_manager.sh -c /path/to/config.nix upgrade 25.05
```

The upgrade process:
1. Backs up your current generation (for rollback)
2. Updates the channel to the new version
3. Validates your configuration with the new version
4. Tests the new configuration
5. Asks for confirmation before making it permanent
6. Automatically rolls back if any step fails

### Advanced Options

```bash
# Dry run: see what would be done without doing it
sudo ./another_nixos_manager.sh --dry-run update

# Verbose mode: show detailed output
sudo ./another_nixos_manager.sh --verbose update

# Non-interactive mode: assume yes to all prompts
sudo ./another_nixos_manager.sh --yes update

# Combine options
sudo ./another_nixos_manager.sh -c /path/to/config.nix --verbose --yes update
```

## Common Workflows

### Regular System Maintenance

```bash
# Weekly maintenance routine
sudo ./another_nixos_manager.sh update     # Update system
sudo ./another_nixos_manager.sh clean      # Clean old generations
```

### Testing Configuration Changes

```bash
# After editing /etc/nixos/configuration.nix
sudo ./another_nixos_manager.sh validate   # Check syntax
sudo ./another_nixos_manager.sh test       # Test without making permanent

# If test passes and you confirm, then apply permanently:
sudo ./another_nixos_manager.sh rebuild switch
```

### Upgrading to New NixOS Release

```bash
# Check current version
./another_nixos_manager.sh info

# Upgrade to new version (e.g., 24.11)
sudo ./another_nixos_manager.sh upgrade 24.11

# If something goes wrong, rollback
sudo ./another_nixos_manager.sh rollback
```

### Custom Configuration Development

```bash
# Working on a custom configuration file
sudo ./another_nixos_manager.sh -c ~/nixos-test/configuration.nix validate
sudo ./another_nixos_manager.sh -c ~/nixos-test/configuration.nix test

# Once satisfied, you can copy it to /etc/nixos/
```

## Options Reference

| Option | Description |
|--------|-------------|
| `-c, --config PATH` | Use custom configuration file (default: /etc/nixos/configuration.nix) |
| `-n, --dry-run` | Show what would be done without executing |
| `-v, --verbose` | Show detailed output from commands |
| `-y, --yes` | Non-interactive mode, assume yes to all prompts |
| `-h, --help` | Show help message |

## Commands Reference

| Command | Description | Requires Root |
|---------|-------------|---------------|
| `info` | Show system information | No |
| `update` | Update channels and rebuild system | Yes |
| `rebuild [action]` | Rebuild with action (switch/boot/test/build) | Yes |
| `test` | Test configuration without making it default | Yes |
| `clean [days]` | Remove generations older than specified days (default: 7) | Yes |
| `clean-all` | Remove all old generations | Yes |
| `list` | List all system generations | Yes |
| `rollback [gen]` | Rollback to previous or specific generation | Yes |
| `upgrade VERSION` | Upgrade to major NixOS version | Yes |
| `validate` | Validate configuration syntax | Yes |

## Safety Features

- **Configuration Validation**: Always validates syntax before rebuilding
- **Test Mode**: Test configurations without making them permanent
- **Automatic Rollback**: Major upgrades rollback automatically if tests fail
- **Generation Preservation**: Old generations are kept for easy rollback
- **Interactive Confirmations**: Prompts before major operations (can be disabled with `--yes`)
- **Dry Run Mode**: Preview changes without applying them

## Troubleshooting

### Configuration validation fails

```bash
# Check syntax errors in your configuration
sudo ./another_nixos_manager.sh validate

# Use verbose mode to see detailed error messages
sudo ./another_nixos_manager.sh --verbose validate
```

### System won't boot after update

Boot into a previous generation from the GRUB menu, then:

```bash
# List available generations
sudo ./another_nixos_manager.sh list

# Rollback to a specific generation
sudo ./another_nixos_manager.sh rollback 123
```

### Major upgrade failed

The script automatically attempts to rollback. If needed, manually rollback:

```bash
sudo ./another_nixos_manager.sh rollback
```

### Low disk space after many updates

```bash
# Clean old generations aggressively
sudo ./another_nixos_manager.sh clean-all

# This removes all old generations and optimizes the store
```

## Automation

### Cron Job for Regular Updates

Add to root's crontab (`sudo crontab -e`):

```bash
# Update system every Sunday at 2 AM
0 2 * * 0 /path/to/another_nixos_manager.sh --yes update

# Clean old generations every month
0 3 1 * * /path/to/another_nixos_manager.sh --yes clean
```

### Systemd Timer (Preferred Method)

Create `/etc/nixos/nixos-update.timer`:

```ini
[Unit]
Description=Weekly NixOS Update

[Timer]
OnCalendar=weekly
Persistent=true

[Install]
WantedBy=timers.target
```

Create `/etc/nixos/nixos-update.service`:

```ini
[Unit]
Description=NixOS System Update

[Service]
Type=oneshot
ExecStart=/path/to/another_nixos_manager.sh --yes update
```

Enable in your configuration.nix:

```nix
systemd.timers.nixos-update = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "weekly";
    Persistent = true;
  };
};

systemd.services.nixos-update = {
  serviceConfig = {
    Type = "oneshot";
    ExecStart = "/path/to/another_nixos_manager.sh --yes update";
  };
};
```

## License

This project is licensed under Creative Commons Attribution-NonCommercial 4.0 International License - see the [LICENSE](../LICENSE) file in the parent directory for details.

---

This script is part of the [another_bucket_of_tools](https://github.com/palumbou/another_bucket_of_tools) collection.
