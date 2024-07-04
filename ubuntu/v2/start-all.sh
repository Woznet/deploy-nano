#!/bin/bash

# Enable strict mode for error handling
# set -e
set -o pipefail

# Define the base directory explicitly, since we can't rely on dirname "$0"
BASE_DIR="/tmp/install-apps"
sudo mkdir -p "$BASE_DIR"

# Set the log file path
LOGFILE="$BASE_DIR/install-apps.log"

# Fetch and source all functions
source <(curl -s "https://raw.githubusercontent.com/Woznet/deploy-nano/main/ubuntu/v2/functions-all.sh")

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

echo "All tasks completed successfully."

# Reset DEBIAN_FRONTEND to its default value (optional)
unset DEBIAN_FRONTEND
