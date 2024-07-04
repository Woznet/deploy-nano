#!/bin/bash

install_updates() {
    echo "Starting full upgrade..."
    sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y || { log_error "install_updates - sudo full-upgrade"; error_exit; }
    echo "Full upgrade completed successfully."
}

install_updates
