#!/bin/bash

# Enable strict mode for error handling
set -e
set -o pipefail

# Define the base directory explicitly, since we can't rely on dirname "$0"
BASE_DIR="/tmp/install-apps"
mkdir -p "$BASE_DIR"

# Set the log file path and ensure permissions
LOGFILE="$BASE_DIR/install-apps.log"
sudo touch "$LOGFILE"
sudo chmod 0666 "$LOGFILE"

# Fetch and source all functions
source <(curl --silent "https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/v2/functions-all.sh")

# Set the DEBIAN_FRONTEND to noninteractive
export DEBIAN_FRONTEND=noninteractive

# Run critical functions
update_software
install_software
install_updates
configure_userenv

# Function to run non-critical functions and handle errors
run_non_critical() {
    local func=$1
    $func || log_error "$func"
}

# Run non-critical functions
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
remove_tmpfiles

echo "All tasks completed successfully."

# Reset DEBIAN_FRONTEND to its default value (optional)
unset DEBIAN_FRONTEND
