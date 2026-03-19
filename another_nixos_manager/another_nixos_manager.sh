#!/usr/bin/env bash
set -euo pipefail

# another_nixos_manager.sh
# A comprehensive NixOS system management tool
# Handles: updates, rebuilds, testing, cleaning, and major version upgrades

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
DEFAULT_CONFIG_PATH="/etc/nixos/configuration.nix"
CONFIG_PATH="$DEFAULT_CONFIG_PATH"
DRY_RUN=false
VERBOSE=false
INTERACTIVE=true

# Function to print colored messages
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Function to display banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║           Another NixOS Manager                          ║"
    echo "║     Comprehensive NixOS System Management Tool           ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check if running on NixOS
check_nixos() {
    if [ ! -f /etc/NIXOS ]; then
        log_error "This script must be run on NixOS"
        exit 1
    fi
}

# Function to check if running as root/sudo
check_privileges() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script requires root privileges. Please run with sudo."
        exit 1
    fi
}

# Function to validate configuration file
validate_config() {
    local config="$1"
    
    if [ ! -f "$config" ]; then
        log_error "Configuration file not found: $config"
        exit 1
    fi
    
    log_info "Validating configuration file: $config"
    
    # Test configuration syntax
    if $DRY_RUN; then
        nixos-rebuild dry-build -I nixos-config="$config" &>/dev/null
    else
        nixos-rebuild dry-build -I nixos-config="$config" &>/dev/null || {
            log_error "Configuration validation failed"
            return 1
        }
    fi
    
    log_success "Configuration is valid"
    return 0
}

# Function to get current NixOS version
get_current_version() {
    nixos-version | cut -d' ' -f1
}

# Function to get current channel
get_current_channel() {
    nix-channel --list | grep nixos | awk '{print $2}'
}

# Function to update channels
update_channels() {
    log_step "Updating NixOS channels..."
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would run: nix-channel --update"
        return 0
    fi
    
    nix-channel --update || {
        log_error "Failed to update channels"
        return 1
    }
    
    log_success "Channels updated successfully"
    return 0
}

# Function to rebuild system
rebuild_system() {
    local action="$1"  # switch, boot, test, build
    local config="${2:-$CONFIG_PATH}"
    
    log_step "Rebuilding system (action: $action)..."
    log_info "Using configuration: $config"
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would run: nixos-rebuild $action -I nixos-config=$config"
        return 0
    fi
    
    local cmd="nixos-rebuild $action -I nixos-config=$config"
    
    if $VERBOSE; then
        $cmd || {
            log_error "Rebuild failed"
            return 1
        }
    else
        $cmd &>/dev/null || {
            log_error "Rebuild failed (use --verbose for details)"
            return 1
        }
    fi
    
    log_success "System rebuilt successfully with action: $action"
    return 0
}

# Function to test new configuration
test_configuration() {
    local config="${1:-$CONFIG_PATH}"
    
    log_step "Testing new configuration..."
    
    # First validate
    validate_config "$config" || return 1
    
    # Then test (activates but doesn't make it default)
    rebuild_system "test" "$config" || return 1
    
    if $INTERACTIVE; then
        echo ""
        log_info "Configuration has been activated temporarily"
        log_info "Your system is now running the new configuration"
        log_info "If you reboot, it will go back to the previous configuration"
        echo ""
        read -p "Does everything work correctly? (y/n): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_success "Test passed"
            return 0
        else
            log_warning "Test marked as failed by user"
            return 1
        fi
    else
        log_success "Test build completed (non-interactive mode)"
        return 0
    fi
}

# Function to perform full system update
full_update() {
    local config="${1:-$CONFIG_PATH}"
    
    log_step "Performing full system update..."
    
    # Update channels
    update_channels || return 1
    
    # Validate configuration
    validate_config "$config" || return 1
    
    # Test first if interactive
    if $INTERACTIVE; then
        log_info "Testing configuration first..."
        test_configuration "$config" || {
            log_error "Test failed. Aborting update."
            return 1
        }
    fi
    
    # Apply update
    rebuild_system "switch" "$config" || return 1
    
    log_success "Full system update completed"
    return 0
}

# Function to clean system
clean_system() {
    local aggressive="${1:-false}"
    local days="${2:-7}"
    
    log_step "Cleaning system..."
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would collect garbage"
        return 0
    fi
    
    # Remove old generations
    if [ "$aggressive" = "true" ]; then
        log_info "Aggressive cleaning: removing all old generations"
        nix-collect-garbage -d || {
            log_error "Failed to collect garbage"
            return 1
        }
    else
        log_info "Standard cleaning: removing generations older than $days days"
        nix-collect-garbage --delete-older-than "${days}d" || {
            log_error "Failed to collect garbage"
            return 1
        }
    fi
    
    # Optimize nix store
    log_info "Optimizing nix store..."
    nix-store --optimize || {
        log_warning "Store optimization had issues but continuing..."
    }
    
    log_success "System cleaned successfully"
    return 0
}

# Function to list generations
list_generations() {
    log_info "System generations:"
    echo ""
    nix-env --list-generations --profile /nix/var/nix/profiles/system
    echo ""
}

# Function to rollback to previous generation
rollback_system() {
    local generation="${1:-}"
    
    if [ -n "$generation" ]; then
        log_step "Rolling back to generation $generation..."
        
        if $DRY_RUN; then
            log_info "[DRY RUN] Would rollback to generation $generation"
            return 0
        fi
        
        nixos-rebuild switch --rollback --profile-name "system-$generation" || {
            log_error "Failed to rollback to generation $generation"
            return 1
        }
    else
        log_step "Rolling back to previous generation..."
        
        if $DRY_RUN; then
            log_info "[DRY RUN] Would rollback to previous generation"
            return 0
        fi
        
        nixos-rebuild switch --rollback || {
            log_error "Failed to rollback"
            return 1
        }
    fi
    
    log_success "Rollback completed"
    return 0
}

# Function to upgrade to major version
upgrade_major_version() {
    local target_version="$1"
    local config="${2:-$CONFIG_PATH}"
    
    local current_version=$(get_current_version)
    local current_channel=$(get_current_channel)
    
    log_step "Major version upgrade: $current_version -> $target_version"
    log_warning "This is a major operation. Make sure you have backups!"
    
    if $INTERACTIVE; then
        echo ""
        read -p "Continue with major version upgrade? (y/n): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Upgrade cancelled by user"
            return 1
        fi
    fi
    
    # Backup current generation
    log_info "Current generation will be preserved for rollback"
    list_generations
    
    # Update channel to new version
    log_step "Updating channel to nixos-$target_version..."
    
    if $DRY_RUN; then
        log_info "[DRY RUN] Would update channel to nixos-$target_version"
        log_info "[DRY RUN] Would rebuild and test system"
        return 0
    fi
    
    nix-channel --add "https://nixos.org/channels/nixos-$target_version" nixos || {
        log_error "Failed to add new channel"
        return 1
    }
    
    # Update channels
    update_channels || {
        log_error "Failed to update to new channel"
        return 1
    }
    
    # Validate configuration with new channel
    log_step "Validating configuration with new NixOS version..."
    validate_config "$config" || {
        log_error "Configuration is not compatible with new version"
        log_info "Reverting channel..."
        nix-channel --add "$current_channel" nixos
        nix-channel --update
        return 1
    }
    
    # Test the new configuration
    log_step "Testing new version..."
    test_configuration "$config" || {
        log_error "Test failed with new version"
        log_info "Reverting channel..."
        nix-channel --add "$current_channel" nixos
        nix-channel --update
        rebuild_system "switch" "$config"
        return 1
    }
    
    # If test passed, make it permanent
    log_step "Applying new version permanently..."
    rebuild_system "switch" "$config" || {
        log_error "Failed to apply new version"
        log_info "You can rollback using: sudo $(basename $0) --rollback"
        return 1
    }
    
    log_success "Major version upgrade completed: $current_version -> $target_version"
    log_info "New version: $(get_current_version)"
    log_warning "Please reboot your system to complete the upgrade"
    
    return 0
}

# Function to show system information
show_system_info() {
    echo ""
    log_info "NixOS System Information"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Version:        $(get_current_version)"
    echo "Channel:        $(get_current_channel)"
    echo "Configuration:  $CONFIG_PATH"
    echo "Current user:   $USER ($(id -u))"
    echo ""
    echo "Last 5 generations:"
    nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -n 5
    echo ""
}

# Function to display help
show_help() {
    show_banner
    cat << EOF
Usage: $(basename $0) [OPTIONS] COMMAND

A comprehensive NixOS system management tool.

COMMANDS:
    update              Update channels and rebuild system
    rebuild [ACTION]    Rebuild system with specified action
                        Actions: switch (default), boot, test, build
    test                Test configuration without making it default
    clean [DAYS]        Clean old generations (default: older than 7 days)
    clean-all           Aggressively clean all old generations
    list                List all system generations
    rollback [GEN]      Rollback to previous or specified generation
    upgrade VERSION     Upgrade to major NixOS version (e.g., 24.11)
    info                Show system information
    validate            Validate configuration file

OPTIONS:
    -c, --config PATH   Use custom configuration file
                        (default: /etc/nixos/configuration.nix)
    -n, --dry-run       Show what would be done without doing it
    -v, --verbose       Show detailed output
    -y, --yes           Non-interactive mode (assume yes)
    -h, --help          Show this help message

EXAMPLES:
    # Standard system update
    sudo $(basename $0) update

    # Update with custom configuration
    sudo $(basename $0) -c /path/to/config.nix update

    # Test configuration before applying
    sudo $(basename $0) test

    # Clean old generations (default: 7 days)
    sudo $(basename $0) clean

    # Clean generations older than 30 days
    sudo $(basename $0) clean 30

    # Upgrade to NixOS 24.11
    sudo $(basename $0) upgrade 24.11

    # Rollback to previous generation
    sudo $(basename $0) rollback

    # Show system info
    $(basename $0) info

    # Dry run of update
    sudo $(basename $0) --dry-run update

EOF
}

# Main execution
main() {
    # Check if running on NixOS
    check_nixos
    
    # Parse command line arguments
    local command=""
    local command_arg=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--config)
                CONFIG_PATH="$2"
                shift 2
                ;;
            -n|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -y|--yes)
                INTERACTIVE=false
                shift
                ;;
            update|rebuild|test|clean|clean-all|list|rollback|upgrade|info|validate)
                command="$1"
                shift
                # Check if there's an argument for the command
                if [[ $# -gt 0 && ! $1 =~ ^- ]]; then
                    command_arg="$1"
                    shift
                fi
                ;;
            *)
                log_error "Unknown option or command: $1"
                echo ""
                show_help
                exit 1
                ;;
        esac
    done
    
    # Show banner unless we're just showing info
    if [ "$command" != "info" ]; then
        show_banner
    fi
    
    # If no command specified, show help
    if [ -z "$command" ]; then
        show_help
        exit 0
    fi
    
    # Commands that don't need root
    if [ "$command" = "info" ]; then
        show_system_info
        exit 0
    fi
    
    # All other commands need root
    check_privileges
    
    # Execute command
    case $command in
        update)
            full_update "$CONFIG_PATH"
            ;;
        rebuild)
            local action="${command_arg:-switch}"
            rebuild_system "$action" "$CONFIG_PATH"
            ;;
        test)
            test_configuration "$CONFIG_PATH"
            ;;
        clean)
            clean_system false "$command_arg"
            ;;
        clean-all)
            clean_system true
            ;;
        list)
            list_generations
            ;;
        rollback)
            rollback_system "$command_arg"
            ;;
        upgrade)
            if [ -z "$command_arg" ]; then
                log_error "Please specify target version (e.g., 24.11)"
                exit 1
            fi
            upgrade_major_version "$command_arg" "$CONFIG_PATH"
            ;;
        validate)
            validate_config "$CONFIG_PATH"
            ;;
        *)
            log_error "Unknown command: $command"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
