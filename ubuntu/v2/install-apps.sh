#!/bin/bash

# Enable strict mode for error handling
set -e
set -o pipefail

# Base directory of the script
BASE_DIR=$(dirname "$0")

# Scripts directory
SCRIPTS_DIR="$BASE_DIR/install-apps"

# Source utility functions
source "$BASE_DIR/prereq/error_exit.sh"
source "$BASE_DIR/prereq/log_error.sh"

# Set the DEBIAN_FRONTEND to noninteractive
export DEBIAN_FRONTEND=noninteractive

# Run critical functions
source "$SCRIPTS_DIR/critical/update_software.sh"
source "$SCRIPTS_DIR/critical/install_software.sh"
source "$SCRIPTS_DIR/critical/install_updates.sh"
source "$SCRIPTS_DIR/critical/configure_userenv.sh"

# Function to run non-critical functions and handle errors
run_non_critical() {
    local script="$SCRIPTS_DIR/non-critical/$1.sh"
    if [ -f "$script" ]; then
        source "$script" || log_error "$1"
    else
        echo "Script $script not found." >&2
        log_error "$1 script not found"
    fi
}

# Run non-critical functions
run_non_critical "remove_rhythmbox"
run_non_critical "configure_dotnet"
run_non_critical "generate_ssh_keys"
run_non_critical "install_gh"
run_non_critical "install_node"
run_non_critical "install_nvm"
run_non_critical "install_pwsh"
run_non_critical "install_vscode"
run_non_critical "save_docker"

echo "All tasks completed successfully."

# Reset DEBIAN_FRONTEND to its default value (optional)
# unset DEBIAN_FRONTEND
