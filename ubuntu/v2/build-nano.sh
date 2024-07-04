#!/bin/bash

# Enable strict mode for error handling
set -e
set -o pipefail

# Base directory of the script
BASE_DIR=$(dirname "$0")

# Scripts directory
SCRIPTS_DIR="$BASE_DIR/build-nano"

# Source utility functions
source "$BASE_DIR/prereq/error_exit.sh"
source "$BASE_DIR/prereq/log_error.sh"

# Run functions
source "$SCRIPTS_DIR/remove_nano.sh"
source "$SCRIPTS_DIR/clone_nano_syntax.sh"
source "$SCRIPTS_DIR/download_nano.sh"
source "$SCRIPTS_DIR/build_nano.sh"
source "$SCRIPTS_DIR/install_nano.sh"
source "$SCRIPTS_DIR/configure_nano.sh"
source "$SCRIPTS_DIR/set_default_editor.sh"

echo "Nano build and configuration completed successfully."
