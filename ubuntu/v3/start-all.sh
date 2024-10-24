#!/bin/bash

# Enable strict mode for error handling
set -e
set -o pipefail

# Directory where logs and temporary files will be stored
BASE_DIR="$HOME/install-apps"

# Log file for storing all outputs and errors
LOGFILE="$BASE_DIR/install-apps_$(date +%Y%m%d_%H%M%S).log"

# Ensure the base directory exists
mkdir -p "$BASE_DIR"

# Set the log file path and ensure permissions
touch "$LOGFILE"
chmod 0644 "$LOGFILE" # Restricting permissions to prevent potential security issues

# Enable trap after LOGFILE is defined
trap 'echo "An error occurred. Check $LOGFILE for details." >&2' ERR

# Utility functions
log() {
    local message="$1"
    local level="${2:-INFO}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$LOGFILE"
}

log_error() {
    log "$1" "ERROR"
}

error_exit() {
    log "Error occurred. Exiting." "ERROR"
    exit 1
}

run_command() {
    local cmd="$1"
    log "Running command: $cmd"
    eval "$cmd" || {
        log_error "Command failed: $cmd"
        error_exit
    }
}

download_file() {
    local url="$1"
    local dest="$2"
    log "Downloading $url to $dest"
    curl --silent --fail "$url" -o "$dest" || {
        log_error "Failed to download $url"
        error_exit
    }
    chmod 644 "$dest" || {
        log_error "Failed to set permissions for $dest"
        error_exit
    }
    log "Downloaded $url to $dest successfully."
}

# Function to safely source external scripts with error handling
source_external_script() {
    local url=$1
    local tmp_file="/tmp/temp_script.sh"

    # Download the script and check for errors
    if ! curl --silent --fail "$url" -o "$tmp_file"; then
        echo -e "${ORANGE_RED}Failed to download script from $url${NC}"
        log_error "Failed to download script from $url"
        exit 1
    fi

    # Source the script if download was successful
    source "$tmp_file"
    rm -f "$tmp_file"
}

# Source the configuration file with global variables using source_external_script
source_external_script "https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/v2/config.sh"

# Fetch and source critical and non-critical functions
source_external_script "https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/v2/critical-functions.sh"
source_external_script "https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/v2/non-critical-functions.sh"

# Set the DEBIAN_FRONTEND to noninteractive
export DEBIAN_FRONTEND=noninteractive
log "DEBIAN_FRONTEND set to noninteractive"

# Run critical functions
log "Starting critical function execution."
update_software || log_error "update_software"
install_software || log_error "install_software"
install_updates || log_error "install_updates"
configure_userenv || log_error "configure_userenv"

# Function to run non-critical functions and handle errors
run_non_critical() {
    local func=$1
    $func || log_error "$func"
}

# Run non-critical functions
log "Starting non-critical function execution."
run_non_critical "remove_rhythmbox"
run_non_critical "configure_dotnet"
run_non_critical "generate_ssh_keys"
run_non_critical "install_gh"
run_non_critical "install_nvm"
run_non_critical "install_pwsh"
run_non_critical "install_vscode"
run_non_critical "save_docker"

# Functions related to building and configuring nano
run_non_critical "remove_nano"
run_non_critical "clone_nano_syntax"
run_non_critical "download_nano"
run_non_critical "build_nano"
run_non_critical "install_nano"
run_non_critical "configure_nano"
run_non_critical "set_default_editor"

# Clean up .tmp files in /tmp
remove_tmpfiles || log_error "remove_tmpfiles"

log "All tasks completed successfully."
echo "All tasks completed successfully."

# Run completion builder script
source_external_script "https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/v2/completion_builder.sh"

# Reset DEBIAN_FRONTEND to its default value (optional)
unset DEBIAN_FRONTEND
log "DEBIAN_FRONTEND reset to default"
