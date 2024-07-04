#!/bin/bash

# Enable strict mode for error handling
set -e
set -o pipefail

# Base directory of the script
BASE_DIR=$(dirname "$0")

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
# run_non_critical "install_node"
run_non_critical "install_pwsh"
run_non_critical "install_vscode"
run_non_critical "save_docker"

echo "All tasks completed successfully."

# Reset DEBIAN_FRONTEND to its default value (optional)
unset DEBIAN_FRONTEND
